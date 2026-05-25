import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../application/project_providers.dart';
import '../../domain/entities/skill.dart';
import 'project_form_support.dart';

class SkillFormScreen extends ConsumerStatefulWidget {
  const SkillFormScreen({super.key, this.skill});

  final Skill? skill;

  @override
  ConsumerState<SkillFormScreen> createState() => _SkillFormScreenState();
}

class _SkillFormScreenState extends ConsumerState<SkillFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _category;
  late final TextEditingController _items;
  late final TextEditingController _displayOrder;
  bool _isPublished = true;
  bool _isSaving = false;
  String? _error;

  bool get _isEditing => widget.skill != null;

  @override
  void initState() {
    super.initState();
    final skill = widget.skill;
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
                      onChanged: (value) =>
                          setState(() => _isPublished = value),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                ProjectFormActions(
                  isSaving: _isSaving,
                  canSubmit: !_isSaving,
                  hasUnsavedChanges: false,
                  submitLabel: _isEditing ? 'Save Changes' : 'Create Skill',
                  onCancel: () => Navigator.of(context).pop(false),
                  onSubmit: _save,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _isSaving = true;
      _error = null;
    });

    try {
      final repository = ref.read(skillRepositoryProvider);
      final skill = Skill(
        id: widget.skill?.id,
        category: _category.text.trim(),
        items: splitTechStack(_items.text),
        displayOrder: int.parse(_displayOrder.text.trim()),
        isPublished: _isPublished,
      );
      if (_isEditing) {
        await repository.updateSkill(skill);
      } else {
        await repository.createSkill(skill);
      }
      ref.invalidate(skillsProvider);
      if (mounted) {
        Navigator.of(context).pop(true);
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
}
