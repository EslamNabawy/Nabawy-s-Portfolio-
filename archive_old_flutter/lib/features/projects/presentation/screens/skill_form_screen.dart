import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../deployment/presentation/controllers/cms_deployment_state.dart';
import '../../../deployment/presentation/widgets/deployment_automation_panel.dart';
import '../../application/project_providers.dart';
import '../../domain/entities/skill.dart';
import 'project_form_support.dart';

class SkillFormScreen extends ConsumerStatefulWidget {
  const SkillFormScreen({super.key, this.skill});

  final Skill? skill;

  @override
  ConsumerState<SkillFormScreen> createState() => _SkillFormScreenState();
}

class _SkillFormScreenState extends ConsumerState<SkillFormScreen>
    with CmsDeploymentState<SkillFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _category;
  late final TextEditingController _items;
  late final TextEditingController _displayOrder;
  late Skill? _skill;
  bool _isPublished = true;
  bool _isSaving = false;
  bool _deployAfterSave = false;
  String? _error;

  bool get _isEditing => _skill != null;

  bool get _canDeploySavedChanges {
    return _isPublished ||
        (_skill?.isPublished ?? widget.skill?.isPublished ?? false);
  }

  @override
  void initState() {
    super.initState();
    final skill = widget.skill;
    _skill = skill;
    _category = TextEditingController(text: skill?.category ?? '');
    _items = TextEditingController(text: skill?.items.join(', ') ?? '');
    _displayOrder = TextEditingController(
      text: (skill?.displayOrder ?? 0).toString(),
    );
    _isPublished = skill?.isPublished ?? true;
  }

  @override
  void dispose() {
    _category.dispose();
    _items.dispose();
    _displayOrder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Skill Group' : 'New Skill Group'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                if (_error != null) ...[
                  ErrorPanel(message: _error!),
                  const SizedBox(height: 16),
                ],
                ProjectFormSection(
                  title: 'Skill Group',
                  children: [
                    TextFormField(
                      controller: _category,
                      decoration: const InputDecoration(labelText: 'Category'),
                      validator: requiredField('Category'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _items,
                      minLines: 3,
                      maxLines: 6,
                      decoration: const InputDecoration(
                        labelText: 'Items',
                        helperText: 'Comma-separated skill names.',
                      ),
                      validator: _validateItems,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _displayOrder,
                      decoration: const InputDecoration(
                        labelText: 'Display Order',
                      ),
                      keyboardType: TextInputType.number,
                      validator: validateDisplayOrder,
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: _isPublished,
                      title: const Text('Published'),
                      subtitle: const Text('Visible on the public portfolio.'),
                      onChanged: (value) => setState(() {
                        _isPublished = value;
                        if (!_canDeploySavedChanges) {
                          _deployAfterSave = false;
                        }
                      }),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                DeploymentAutomationPanel(
                  enabled: _canDeploySavedChanges,
                  disabledReason:
                      'Draft-only skill changes do not need deploy.',
                  deployAfterSave: _deployAfterSave,
                  isSaving: _isSaving,
                  isDeploying: isDeploying,
                  progress: deploymentProgress,
                  result: deploymentResult,
                  error: deploymentError,
                  onDeployAfterSaveChanged: _setDeployAfterSave,
                  onSaveAndDeploy: _saveAndDeploy,
                ),
                const SizedBox(height: 24),
                ProjectFormActions(
                  isSaving: _isSaving,
                  canSubmit: !_isSaving && !isDeploying,
                  hasUnsavedChanges: false,
                  submitLabel: _isEditing ? 'Save Changes' : 'Create Skill',
                  canCancel: !isDeploying,
                  onCancel: () => Navigator.of(context).pop(false),
                  onSubmit: _saveOnly,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveOnly() async {
    await _save(deployAfterSave: _deployAfterSave && _canDeploySavedChanges);
  }

  Future<void> _saveAndDeploy() async {
    if (!_canDeploySavedChanges) {
      _setError('Only published or previously published skills need deploy.');
      return;
    }
    await _save(deployAfterSave: true);
  }

  Future<void> _save({required bool deployAfterSave}) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _isSaving = true;
      _error = null;
      clearDeploymentFeedback();
    });

    try {
      final repository = ref.read(skillRepositoryProvider);
      final skill = Skill(
        id: _skill?.id,
        category: _category.text.trim(),
        items: splitTechStack(_items.text),
        displayOrder: int.parse(_displayOrder.text.trim()),
        isPublished: _isPublished,
      );
      final savedSkill = _isEditing
          ? await repository.updateSkill(skill)
          : await repository.createSkill(skill);
      _skill = savedSkill;
      ref.invalidate(skillsProvider);
      if (mounted) {
        setState(() => _isSaving = false);
        if (deployAfterSave) {
          await _deploySavedSkill(savedSkill);
        } else if (mounted) {
          Navigator.of(context).pop(true);
        }
      }
    } on AppException catch (error) {
      _setError(error.message);
    } catch (error) {
      _setError('Save failed: $error');
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _deploySavedSkill(Skill skill) async {
    await runCmsDeployment(
      message:
          'Deployment requested after saving skill group "${skill.category}".',
    );
  }

  String? _validateItems(String? value) {
    if (splitTechStack(value ?? '').isEmpty) {
      return 'Add at least one skill item.';
    }
    return null;
  }

  void _setError(String message) {
    if (mounted) {
      setState(() => _error = message);
    }
  }

  void _setDeployAfterSave(bool value) {
    setState(() => _deployAfterSave = value && _canDeploySavedChanges);
  }
}
