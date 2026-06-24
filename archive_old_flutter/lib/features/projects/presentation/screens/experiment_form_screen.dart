import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../deployment/presentation/controllers/cms_deployment_state.dart';
import '../../../deployment/presentation/widgets/deployment_automation_panel.dart';
import '../../application/project_providers.dart';
import '../../domain/entities/experiment.dart';
import 'experiment_form_meta_section.dart';
import 'project_form_support.dart';

class ExperimentFormScreen extends ConsumerStatefulWidget {
  const ExperimentFormScreen({super.key, this.experiment});

  final Experiment? experiment;

  @override
  ConsumerState<ExperimentFormScreen> createState() =>
      _ExperimentFormScreenState();
}

class _ExperimentFormScreenState extends ConsumerState<ExperimentFormScreen>
    with CmsDeploymentState<ExperimentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _slug;
  late final TextEditingController _category;
  late final TextEditingController _summary;
  late final TextEditingController _writeup;
  late final TextEditingController _mediaUrl;
  late final TextEditingController _githubUrl;
  late final TextEditingController _liveUrl;
  late final TextEditingController _displayOrder;
  late Experiment? _experiment;
  ExperimentStatus _status = ExperimentStatus.prototype;
  bool _isPublished = false;
  bool _isSaving = false;
  bool _deployAfterSave = false;
  String? _error;

  bool get _isEditing => _experiment != null;

  bool get _canDeploySavedChanges {
    return _isPublished ||
        (_experiment?.isPublished ?? widget.experiment?.isPublished ?? false);
  }

  @override
  void initState() {
    super.initState();
    final experiment = widget.experiment;
    _experiment = experiment;
    _title = TextEditingController(text: experiment?.title ?? '');
    _slug = TextEditingController(text: experiment?.slug ?? '');
    _category = TextEditingController(text: experiment?.category ?? '');
    _summary = TextEditingController(text: experiment?.summary ?? '');
    _writeup = TextEditingController(text: experiment?.writeupMarkdown ?? '');
    _mediaUrl = TextEditingController(text: experiment?.mediaUrl ?? '');
    _githubUrl = TextEditingController(text: experiment?.githubUrl ?? '');
    _liveUrl = TextEditingController(text: experiment?.liveUrl ?? '');
    _displayOrder = TextEditingController(
      text: (experiment?.displayOrder ?? 0).toString(),
    );
    _status = experiment?.status ?? ExperimentStatus.prototype;
    _isPublished = experiment?.isPublished ?? false;
  }

  @override
  void dispose() {
    for (final controller in [
      _title,
      _slug,
      _category,
      _summary,
      _writeup,
      _mediaUrl,
      _githubUrl,
      _liveUrl,
      _displayOrder,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Experiment' : 'New Lab Experiment'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 920),
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                if (_error != null) ...[
                  ErrorPanel(message: _error!),
                  const SizedBox(height: 16),
                ],
                _ExperimentContentSection(
                  title: _title,
                  slug: _slug,
                  category: _category,
                  summary: _summary,
                  writeup: _writeup,
                  onTitleChanged: _syncSlug,
                ),
                const SizedBox(height: 16),
                ExperimentMetaSection(
                  status: _status,
                  mediaUrl: _mediaUrl,
                  githubUrl: _githubUrl,
                  liveUrl: _liveUrl,
                  displayOrder: _displayOrder,
                  isPublished: _isPublished,
                  onStatusChanged: (value) => setState(() => _status = value),
                  onPublishedChanged: _setPublished,
                ),
                const SizedBox(height: 16),
                DeploymentAutomationPanel(
                  enabled: _canDeploySavedChanges,
                  disabledReason:
                      'Draft-only experiment changes do not need deploy.',
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
                  submitLabel: _isEditing
                      ? 'Save Changes'
                      : 'Create Experiment',
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
      _setError(
        'Only published or previously published experiments need deploy.',
      );
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
      final repository = ref.read(experimentRepositoryProvider);
      final experiment = _experimentFromFields();
      final saved = _isEditing
          ? await repository.updateExperiment(experiment)
          : await repository.createExperiment(experiment);
      _experiment = saved;
      ref.invalidate(experimentsProvider);
      if (mounted) {
        setState(() => _isSaving = false);
        if (deployAfterSave) {
          await runCmsDeployment(
            message:
                'Deployment requested after saving experiment "${saved.title}".',
          );
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

  Experiment _experimentFromFields() {
    return Experiment(
      id: _experiment?.id,
      title: _title.text.trim(),
      slug: _slug.text.trim(),
      status: _status,
      category: _category.text.trim(),
      summary: _summary.text.trim(),
      writeupMarkdown: optionalText(_writeup.text),
      mediaUrl: optionalText(_mediaUrl.text),
      githubUrl: optionalText(_githubUrl.text),
      liveUrl: optionalText(_liveUrl.text),
      displayOrder: int.parse(_displayOrder.text.trim()),
      isPublished: _isPublished,
    );
  }

  void _syncSlug(String value) {
    if (_slug.text.trim().isNotEmpty || _isEditing) {
      return;
    }
    _slug.text = value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
  }

  void _setPublished(bool value) {
    setState(() {
      _isPublished = value;
      if (!_canDeploySavedChanges) {
        _deployAfterSave = false;
      }
    });
  }

  void _setDeployAfterSave(bool value) {
    setState(() => _deployAfterSave = value && _canDeploySavedChanges);
  }

  void _setError(String message) {
    if (mounted) {
      setState(() => _error = message);
    }
  }
}

class _ExperimentContentSection extends StatelessWidget {
  const _ExperimentContentSection({
    required this.title,
    required this.slug,
    required this.category,
    required this.summary,
    required this.writeup,
    required this.onTitleChanged,
  });

  final TextEditingController title;
  final TextEditingController slug;
  final TextEditingController category;
  final TextEditingController summary;
  final TextEditingController writeup;
  final ValueChanged<String> onTitleChanged;

  @override
  Widget build(BuildContext context) {
    return ProjectFormSection(
      title: 'Experiment Dossier',
      children: [
        TextFormField(
          controller: title,
          decoration: const InputDecoration(labelText: 'Title'),
          validator: requiredField('Title'),
          onChanged: onTitleChanged,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: slug,
          decoration: const InputDecoration(labelText: 'Slug'),
          validator: validateSlug,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: category,
          decoration: const InputDecoration(labelText: 'Category'),
          validator: requiredField('Category'),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: summary,
          maxLines: 3,
          decoration: const InputDecoration(labelText: 'Summary'),
          validator: requiredField('Summary'),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: writeup,
          minLines: 6,
          maxLines: 12,
          decoration: const InputDecoration(labelText: 'Writeup Markdown'),
        ),
      ],
    );
  }
}
