import 'package:flutter/material.dart';

import '../../../../shared/ui/admin_components.dart';
import '../../domain/entities/page_section.dart';
import '../../domain/entities/page_section_readiness.dart';

class PageSectionPreviewToolbar extends StatelessWidget {
  const PageSectionPreviewToolbar({
    super.key,
    required this.section,
    required this.readiness,
    required this.onEdit,
    required this.onPreview,
    required this.onDuplicate,
    required this.onDelete,
    required this.onTogglePublished,
  });

  final PageSection section;
  final PageSectionReadiness readiness;
  final ValueChanged<PageSection> onEdit;
  final ValueChanged<PageSection> onPreview;
  final ValueChanged<PageSection> onDuplicate;
  final ValueChanged<PageSection> onDelete;
  final ValueChanged<PageSection> onTogglePublished;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        border: Border(bottom: BorderSide(color: Color(0xFFC7D2CC))),
      ),
      child: Row(
        children: [
          const Icon(Icons.drag_indicator),
          const SizedBox(width: 8),
          Expanded(
            child: _SectionMeta(section: section, readiness: readiness),
          ),
          IconButton(
            tooltip: 'Open full preview',
            onPressed: () => onPreview(section),
            icon: const Icon(Icons.open_in_full),
          ),
          IconButton(
            tooltip: 'Edit section',
            onPressed: () => onEdit(section),
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            tooltip: section.isPublished ? 'Unpublish' : 'Publish',
            onPressed: () => onTogglePublished(section),
            icon: Icon(
              section.isPublished
                  ? Icons.visibility_off_outlined
                  : Icons.publish_outlined,
            ),
          ),
          IconButton(
            tooltip: 'Duplicate',
            onPressed: () => onDuplicate(section),
            icon: const Icon(Icons.copy_outlined),
          ),
          IconButton(
            tooltip: 'Delete section',
            onPressed: section.id == null ? null : () => onDelete(section),
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
    );
  }
}

class BuiltInPageBand extends StatelessWidget {
  const BuiltInPageBand({super.key, required this.label, required this.title});

  final String label;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFC7D2CC)),
        color: const Color(0xFFEAF3F1),
      ),
      child: Row(
        children: [
          AdminStatusChip(label: label, tone: AdminStatusTone.info),
          const SizedBox(width: 12),
          Expanded(
            child: Text(title, style: Theme.of(context).textTheme.titleSmall),
          ),
        ],
      ),
    );
  }
}

class EmptyPreviewDropZone extends StatelessWidget {
  const EmptyPreviewDropZone({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFD7DFDA)),
        color: const Color(0xFFFBFDFC),
      ),
      child: Text(
        'No custom section ${label.toLowerCase()}.',
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }
}

class _SectionMeta extends StatelessWidget {
  const _SectionMeta({required this.section, required this.readiness});

  final PageSection section;
  final PageSectionReadiness readiness;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(section.title, style: Theme.of(context).textTheme.titleSmall),
        AdminStatusChip(label: section.placement.label),
        AdminStatusChip(label: section.sectionType.label),
        AdminStatusChip(
          label: section.isPublished ? 'Published' : 'Draft',
          tone: section.isPublished
              ? AdminStatusTone.success
              : AdminStatusTone.warning,
        ),
        AdminStatusChip(
          label: readiness.isReady
              ? 'Ready'
              : '${readiness.messages.length} issues',
          tone: readiness.isReady
              ? AdminStatusTone.success
              : AdminStatusTone.danger,
        ),
      ],
    );
  }
}
