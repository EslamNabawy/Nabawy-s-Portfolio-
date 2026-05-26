import 'package:flutter/material.dart';

import '../../../../shared/ui/admin_components.dart';
import '../../../projects/presentation/screens/project_form_support.dart';
import '../../domain/entities/page_section.dart';
import '../../domain/entities/page_section_readiness.dart';
import 'page_section_form_support.dart';

class PageSectionInspector extends StatefulWidget {
  const PageSectionInspector({
    super.key,
    required this.section,
    required this.isSaving,
    required this.onSave,
    required this.onEditAdvanced,
    required this.onPreview,
    required this.onDuplicate,
    required this.onDelete,
    required this.onTogglePublished,
  });

  final PageSection? section;
  final bool isSaving;
  final Future<void> Function(PageSection section) onSave;
  final ValueChanged<PageSection> onEditAdvanced;
  final ValueChanged<PageSection> onPreview;
  final ValueChanged<PageSection> onDuplicate;
  final ValueChanged<PageSection> onDelete;
  final ValueChanged<PageSection> onTogglePublished;

  @override
  State<PageSectionInspector> createState() => _PageSectionInspectorState();
}

class _PageSectionInspectorState extends State<PageSectionInspector> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _eyebrow = TextEditingController();
  final _body = TextEditingController();
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
            TextFormField(
              controller: _title,
              decoration: const InputDecoration(labelText: 'Title'),
              validator: requiredField('Title'),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _eyebrow,
              decoration: const InputDecoration(labelText: 'Eyebrow'),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _body,
              decoration: const InputDecoration(labelText: 'Body'),
              minLines: 3,
              maxLines: 6,
            ),
            const SizedBox(height: 14),
            SectionDropdown(
              label: 'Placement',
              value: _placement,
              values: PageSectionPlacement.values,
              labelFor: (value) => value.label,
              onChanged: (value) => setState(() => _placement = value),
            ),
            const SizedBox(height: 10),
            SectionDropdown(
              label: 'Type',
              value: _sectionType,
              values: PageSectionType.values,
              labelFor: (value) => value.label,
              onChanged: (value) => setState(() => _sectionType = value),
            ),
            const SizedBox(height: 10),
            SectionDropdown(
              label: 'Layout',
              value: _layout,
              values: PageSectionLayout.values,
              labelFor: (value) => value.label,
              onChanged: (value) => setState(() => _layout = value),
            ),
            const SizedBox(height: 10),
            SectionDropdown(
              label: 'Tone',
              value: _tone,
              values: PageSectionTone.values,
              labelFor: (value) => value.label,
              onChanged: (value) => setState(() => _tone = value),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: SectionDropdown(
                    label: 'Density',
                    value: _density,
                    values: PageSectionDensity.values,
                    labelFor: (value) => value.label,
                    onChanged: (value) => setState(() => _density = value),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SectionDropdown(
                    label: 'Align',
                    value: _alignment,
                    values: PageSectionAlignment.values,
                    labelFor: (value) => value.label,
                    onChanged: (value) => setState(() => _alignment = value),
                  ),
                ),
              ],
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: section.isPublished,
              title: const Text('Published'),
              onChanged: widget.isSaving
                  ? null
                  : (_) => widget.onTogglePublished(section),
            ),
            const Divider(height: 24),
            ValidationList(messages: readiness.messages),
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: widget.isSaving ? null : () => _save(section),
              icon: const Icon(Icons.save_outlined),
              label: const Text('Save Inspector Changes'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: widget.isSaving
                  ? null
                  : () => widget.onEditAdvanced(section),
              icon: const Icon(Icons.dashboard_customize_outlined),
              label: const Text('Open Builder'),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: () => widget.onPreview(section),
                  icon: const Icon(Icons.open_in_full),
                  label: const Text('Preview'),
                ),
                OutlinedButton.icon(
                  onPressed: () => widget.onDuplicate(section),
                  icon: const Icon(Icons.copy_outlined),
                  label: const Text('Duplicate'),
                ),
                OutlinedButton.icon(
                  onPressed: section.id == null
                      ? null
                      : () => widget.onDelete(section),
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Delete'),
                ),
              ],
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

  PageSection _draft(PageSection section) {
    return PageSection(
      id: section.id,
      sectionKey: section.sectionKey,
      title: _title.text.trim(),
      eyebrow: _optional(_eyebrow.text),
      body: _optional(_body.text),
      placement: _placement,
      sectionType: _sectionType,
      layout: _layout,
      tone: _tone,
      density: _density,
      alignment: _alignment,
      contentJson: section.contentJson,
      designJson: section.designJson,
      displayOrder: section.displayOrder,
      isPublished: section.isPublished,
      createdAt: section.createdAt,
      updatedAt: section.updatedAt,
    );
  }

  void _load(PageSection? section) {
    _title.text = section?.title ?? '';
    _eyebrow.text = section?.eyebrow ?? '';
    _body.text = section?.body ?? '';
    _placement = section?.placement ?? PageSectionPlacement.afterHero;
    _sectionType = section?.sectionType ?? PageSectionType.contentGrid;
    _layout = section?.layout ?? PageSectionLayout.stack;
    _tone = section?.tone ?? PageSectionTone.panel;
    _density = section?.density ?? PageSectionDensity.standard;
    _alignment = section?.alignment ?? PageSectionAlignment.left;
  }
}

String _identity(PageSection? section) =>
    section?.id ?? section?.sectionKey ?? '';

String? _optional(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}
