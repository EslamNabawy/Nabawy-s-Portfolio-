import 'package:flutter/material.dart';

import '../../../../core/utils/json_readers.dart';
import '../../../../shared/ui/admin_components.dart';
import '../../../deployment/domain/entities/deployment_result.dart';
import '../../domain/entities/page_section.dart';
import '../../domain/entities/page_section_readiness.dart';
import 'page_section_blocks_inspector.dart';
import 'page_section_inspector_controls.dart';

class PageSectionInspector extends StatefulWidget {
  const PageSectionInspector({
    super.key,
    required this.section,
    required this.isSaving,
    required this.isDeploying,
    required this.onSave,
    required this.onSaveAndDeploy,
    required this.onEditAdvanced,
    required this.onPreview,
    required this.onDuplicate,
    required this.onDelete,
    required this.onTogglePublished,
    this.deploymentProgress,
    this.deploymentResult,
    this.deploymentError,
  });

  final PageSection? section;
  final bool isSaving;
  final bool isDeploying;
  final Future<void> Function(PageSection section) onSave;
  final Future<void> Function(PageSection section) onSaveAndDeploy;
  final ValueChanged<PageSection> onEditAdvanced;
  final ValueChanged<PageSection> onPreview;
  final ValueChanged<PageSection> onDuplicate;
  final ValueChanged<PageSection> onDelete;
  final ValueChanged<PageSection> onTogglePublished;
  final DeploymentProgress? deploymentProgress;
  final DeploymentResult? deploymentResult;
  final String? deploymentError;

  @override
  State<PageSectionInspector> createState() => _PageSectionInspectorState();
}

class _PageSectionInspectorState extends State<PageSectionInspector> {
  final _formKey = GlobalKey<FormState>();
  final _sectionKey = TextEditingController();
  final _title = TextEditingController();
  final _eyebrow = TextEditingController();
  final _body = TextEditingController();
  JsonMap _contentJson = const <String, Object?>{};
  JsonMap _designJson = const <String, Object?>{};
  PageSectionPlacement _placement = PageSectionPlacement.afterHero;
  PageSectionType _sectionType = PageSectionType.contentGrid;
  PageSectionLayout _layout = PageSectionLayout.stack;
  PageSectionTone _tone = PageSectionTone.panel;
  PageSectionDensity _density = PageSectionDensity.standard;
  PageSectionAlignment _alignment = PageSectionAlignment.left;

  @override
  void initState() {
    super.initState();
    _load(widget.section);
  }

  @override
  void didUpdateWidget(PageSectionInspector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_identity(oldWidget.section) != _identity(widget.section)) {
      _load(widget.section);
    }
  }

  @override
  void dispose() {
    _sectionKey.dispose();
    _title.dispose();
    _eyebrow.dispose();
    _body.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final section = widget.section;
    if (section == null) {
      return const AdminPanel(
        title: 'Inspector',
        subtitle: 'Select a custom section in the page preview.',
        child: AdminStatusChip(label: 'Nothing selected'),
      );
    }
    final readiness = assessPageSectionReadiness(_draft(section));
    return Form(
      key: _formKey,
      child: AdminPanel(
        title: 'Inspector',
        subtitle: section.sectionKey,
        actions: [
          AdminStatusChip(
            label: section.isPublished ? 'Published' : 'Draft',
            tone: section.isPublished
                ? AdminStatusTone.success
                : AdminStatusTone.warning,
          ),
        ],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PageSectionIdentityFields(
              sectionKey: _sectionKey,
              title: _title,
              eyebrow: _eyebrow,
              body: _body,
            ),
            const SizedBox(height: 14),
            PageSectionDesignFields(
              placement: _placement,
              sectionType: _sectionType,
              layout: _layout,
              tone: _tone,
              density: _density,
              alignment: _alignment,
              onPlacementChanged: (value) => setState(() => _placement = value),
              onTypeChanged: (value) => setState(() => _sectionType = value),
              onLayoutChanged: (value) => setState(() => _layout = value),
              onToneChanged: (value) => setState(() => _tone = value),
              onDensityChanged: (value) => setState(() => _density = value),
              onAlignmentChanged: (value) => setState(() => _alignment = value),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: section.isPublished,
              title: const Text('Published'),
              onChanged: _busy
                  ? null
                  : (_) => widget.onTogglePublished(section),
            ),
            const Divider(height: 24),
            PageSectionBlocksInspector(
              key: ValueKey(_identity(section)),
              contentJson: _contentJson,
              onChanged: (value) => setState(() => _contentJson = value),
            ),
            const SizedBox(height: 14),
            ValidationList(messages: readiness.messages),
            const SizedBox(height: 14),
            PageSectionInspectorActions(
              busy: _busy,
              isDeploying: widget.isDeploying,
              section: section,
              onSave: () => _save(section),
              onSaveAndDeploy: () => _saveAndDeploy(section),
              onEditAdvanced: widget.onEditAdvanced,
              onPreview: widget.onPreview,
              onDuplicate: widget.onDuplicate,
              onDelete: widget.onDelete,
            ),
            PageSectionDeploymentFeedback(
              progress: widget.deploymentProgress,
              result: widget.deploymentResult,
              error: widget.deploymentError,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save(PageSection section) async {
    if (_formKey.currentState?.validate() != true) {
      return;
    }
    await widget.onSave(_draft(section));
  }

  Future<void> _saveAndDeploy(PageSection section) async {
    if (_formKey.currentState?.validate() != true) {
      return;
    }
    await widget.onSaveAndDeploy(_draft(section));
  }

  PageSection _draft(PageSection section) {
    return PageSection(
      id: section.id,
      sectionKey: _sectionKey.text.trim(),
      title: _title.text.trim(),
      eyebrow: _optional(_eyebrow.text),
      body: _optional(_body.text),
      placement: _placement,
      sectionType: _sectionType,
      layout: _layout,
      tone: _tone,
      density: _density,
      alignment: _alignment,
      contentJson: _contentJson,
      designJson: _designJson,
      displayOrder: section.displayOrder,
      isPublished: section.isPublished,
      createdAt: section.createdAt,
      updatedAt: section.updatedAt,
    );
  }

  void _load(PageSection? section) {
    _sectionKey.text = section?.sectionKey ?? '';
    _title.text = section?.title ?? '';
    _eyebrow.text = section?.eyebrow ?? '';
    _body.text = section?.body ?? '';
    _contentJson = section?.contentJson ?? const <String, Object?>{};
    _designJson = section?.designJson ?? const <String, Object?>{};
    _placement = section?.placement ?? PageSectionPlacement.afterHero;
    _sectionType = section?.sectionType ?? PageSectionType.contentGrid;
    _layout = section?.layout ?? PageSectionLayout.stack;
    _tone = section?.tone ?? PageSectionTone.panel;
    _density = section?.density ?? PageSectionDensity.standard;
    _alignment = section?.alignment ?? PageSectionAlignment.left;
  }

  bool get _busy => widget.isSaving || widget.isDeploying;
}

String _identity(PageSection? section) =>
    section?.id ?? section?.sectionKey ?? '';

String? _optional(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}
