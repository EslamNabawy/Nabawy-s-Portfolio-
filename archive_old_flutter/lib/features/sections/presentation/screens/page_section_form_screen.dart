import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../deployment/presentation/controllers/cms_deployment_state.dart';
import '../../../deployment/presentation/widgets/deployment_automation_panel.dart';
import '../../../projects/presentation/screens/project_form_support.dart';
import '../../application/section_providers.dart';
import '../../domain/entities/page_section.dart';
import '../../domain/entities/page_section_readiness.dart';
import 'page_section_form_sections.dart';
import 'page_section_form_support.dart';
import 'page_section_live_preview.dart';
import 'page_section_readiness_panel.dart';
import 'page_section_structured_editor.dart';

class PageSectionFormScreen extends ConsumerStatefulWidget {
  const PageSectionFormScreen({super.key, this.section, this.initialSection});

  final PageSection? section;
  final PageSection? initialSection;

  @override
  ConsumerState<PageSectionFormScreen> createState() =>
      _PageSectionFormScreenState();
}

class _PageSectionFormScreenState extends ConsumerState<PageSectionFormScreen>
    with CmsDeploymentState<PageSectionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _sectionKey;
  late final TextEditingController _eyebrow;
  late final TextEditingController _body;
  late final TextEditingController _displayOrder;
  late final TextEditingController _contentJson;
  late final TextEditingController _designJson;
  late PageSection? _section;
  PageSectionPlacement _placement = PageSectionPlacement.afterHero;
  PageSectionType _sectionType = PageSectionType.contentGrid;
  PageSectionLayout _layout = PageSectionLayout.stack;
  PageSectionTone _tone = PageSectionTone.panel;
  PageSectionDensity _density = PageSectionDensity.standard;
  PageSectionAlignment _alignment = PageSectionAlignment.left;
  bool _isPublished = false;
  bool _isSaving = false;
  bool _deployAfterSave = false;
  String? _error;

  bool get _isEditing => _section != null;

  bool get _canDeploySavedChanges {
    return _isPublished || (_section?.isPublished ?? false);
  }

  @override
  void initState() {
    super.initState();
    final section = widget.section ?? widget.initialSection;
    _section = widget.section;
    _title = TextEditingController(text: section?.title ?? '');
    _sectionKey = TextEditingController(text: section?.sectionKey ?? '');
    _eyebrow = TextEditingController(text: section?.eyebrow ?? '');
    _body = TextEditingController(text: section?.body ?? '');
    _displayOrder = TextEditingController(
      text: (section?.displayOrder ?? 0).toString(),
    );
    _contentJson = TextEditingController(
      text: section == null
          ? defaultContentJson
          : prettyJson(section.contentJson),
    );
    _designJson = TextEditingController(
      text: section == null
          ? defaultDesignJson
          : prettyJson(section.designJson),
    );
    _placement = section?.placement ?? PageSectionPlacement.afterHero;
    _sectionType = section?.sectionType ?? PageSectionType.contentGrid;
    _layout = section?.layout ?? PageSectionLayout.stack;
    _tone = section?.tone ?? PageSectionTone.panel;
    _density = section?.density ?? PageSectionDensity.standard;
    _alignment = section?.alignment ?? PageSectionAlignment.left;
    _isPublished = section?.isPublished ?? false;
  }

  @override
  void dispose() {
    for (final controller in [
      _title,
      _sectionKey,
      _eyebrow,
      _body,
      _displayOrder,
      _contentJson,
      _designJson,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit Section' : 'New Section')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 980),
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                if (_error != null) ...[
                  ErrorPanel(message: _error!),
                  const SizedBox(height: 16),
                ],
                PageSectionIdentitySection(
                  title: _title,
                  sectionKey: _sectionKey,
                  eyebrow: _eyebrow,
                  body: _body,
                  displayOrder: _displayOrder,
                  isPublished: _isPublished,
                  onTitleChanged: _syncSectionKey,
                  onChanged: () => setState(() {}),
                  onPublishedChanged: _setPublished,
                ),
                const SizedBox(height: 16),
                PageSectionDesignSection(
                  placement: _placement,
                  sectionType: _sectionType,
                  layout: _layout,
                  tone: _tone,
                  density: _density,
                  alignment: _alignment,
                  onPlacementChanged: (value) =>
                      setState(() => _placement = value),
                  onTypeChanged: (value) =>
                      setState(() => _sectionType = value),
                  onLayoutChanged: (value) => setState(() => _layout = value),
                  onToneChanged: (value) => setState(() => _tone = value),
                  onDensityChanged: (value) => setState(() => _density = value),
                  onAlignmentChanged: (value) =>
                      setState(() => _alignment = value),
                ),
                const SizedBox(height: 16),
                PageSectionStructuredEditor(
                  contentJson: _contentJson,
                  designJson: _designJson,
                  onChanged: () => setState(() {}),
                ),
                const SizedBox(height: 16),
                PageSectionLivePreview(
                  title: _title,
                  sectionKey: _sectionKey,
                  eyebrow: _eyebrow,
                  body: _body,
                  placement: _placement,
                  sectionType: _sectionType,
                  layout: _layout,
                  tone: _tone,
                  density: _density,
                  alignment: _alignment,
                  contentJson: _contentJson,
                  designJson: _designJson,
                ),
                const SizedBox(height: 16),
                PageSectionReadinessPanel(
                  title: _title,
                  sectionKey: _sectionKey,
                  eyebrow: _eyebrow,
                  body: _body,
                  placement: _placement,
                  sectionType: _sectionType,
                  layout: _layout,
                  tone: _tone,
                  density: _density,
                  alignment: _alignment,
                  contentJson: _contentJson,
                  designJson: _designJson,
                  displayOrder: _displayOrder,
                  isPublished: _isPublished,
                ),
                const SizedBox(height: 16),
                PageSectionAdvancedJsonSection(
                  contentJson: _contentJson,
                  designJson: _designJson,
                  onChanged: () => setState(() {}),
                ),
                const SizedBox(height: 16),
                DeploymentAutomationPanel(
                  enabled: _canDeploySavedChanges,
                  disabledReason:
                      'Draft-only section changes do not need deploy.',
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
                  submitLabel: _isEditing ? 'Save Section' : 'Create Section',
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
      _setError('Only published or previously published sections need deploy.');
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
      final repository = ref.read(pageSectionRepositoryProvider);
      final section = _sectionFromFields();
      final readiness = assessPageSectionReadiness(section);
      if (section.isPublished && !readiness.isReady) {
        _setError('Fix publish readiness before saving as published.');
        return;
      }
      final saved = _isEditing
          ? await repository.updateSection(section)
          : await repository.createSection(section);
      _section = saved;
      ref.invalidate(pageSectionsProvider);
      if (mounted) {
        setState(() => _isSaving = false);
        if (deployAfterSave) {
          await runCmsDeployment(
            message:
                'Deployment requested after saving section "${saved.title}".',
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

  PageSection _sectionFromFields() {
    return PageSection(
      id: _section?.id,
      sectionKey: _sectionKey.text.trim(),
      title: _title.text.trim(),
      eyebrow: optionalText(_eyebrow.text),
      body: optionalText(_body.text),
      placement: _placement,
      sectionType: _sectionType,
      layout: _layout,
      tone: _tone,
      density: _density,
      alignment: _alignment,
      contentJson: parseJsonObjectText(_contentJson.text, 'Content JSON'),
      designJson: parseJsonObjectText(_designJson.text, 'Design JSON'),
      displayOrder: int.parse(_displayOrder.text.trim()),
      isPublished: _isPublished,
    );
  }

  void _syncSectionKey(String value) {
    if (_sectionKey.text.trim().isNotEmpty || _isEditing) {
      return;
    }
    _sectionKey.text = value
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
