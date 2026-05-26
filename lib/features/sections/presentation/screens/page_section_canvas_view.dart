import 'package:flutter/material.dart';

import '../../../../shared/ui/admin_components.dart';
import '../../domain/entities/page_section.dart';
import '../../domain/entities/page_section_readiness.dart';

class PageSectionCanvasView extends StatelessWidget {
  const PageSectionCanvasView({
    super.key,
    required this.sections,
    required this.onEdit,
    required this.onPreview,
    required this.onDuplicate,
    required this.onDelete,
    required this.onTogglePublished,
    required this.onReorder,
  });

  final List<PageSection> sections;
  final ValueChanged<PageSection> onEdit;
  final ValueChanged<PageSection> onPreview;
  final ValueChanged<PageSection> onDuplicate;
  final ValueChanged<PageSection> onDelete;
  final ValueChanged<PageSection> onTogglePublished;
  final void Function(
    PageSectionPlacement placement,
    int oldIndex,
    int newIndex,
  )
  onReorder;

  @override
  Widget build(BuildContext context) {
    if (sections.isEmpty) {
      return const Center(child: Text('No custom page sections yet.'));
    }
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        for (final placement in PageSectionPlacement.values)
          _PlacementLane(
            placement: placement,
            sections: _sectionsFor(placement),
            onEdit: onEdit,
            onPreview: onPreview,
            onDuplicate: onDuplicate,
            onDelete: onDelete,
            onTogglePublished: onTogglePublished,
            onReorder: onReorder,
          ),
      ],
    );
  }

  List<PageSection> _sectionsFor(PageSectionPlacement placement) {
    return sections
        .where((section) => section.placement == placement)
        .toList(growable: false);
  }
}

class _PlacementLane extends StatelessWidget {
  const _PlacementLane({
    required this.placement,
    required this.sections,
    required this.onEdit,
    required this.onPreview,
    required this.onDuplicate,
    required this.onDelete,
    required this.onTogglePublished,
    required this.onReorder,
  });

  final PageSectionPlacement placement;
  final List<PageSection> sections;
  final ValueChanged<PageSection> onEdit;
  final ValueChanged<PageSection> onPreview;
  final ValueChanged<PageSection> onDuplicate;
  final ValueChanged<PageSection> onDelete;
  final ValueChanged<PageSection> onTogglePublished;
  final void Function(
    PageSectionPlacement placement,
    int oldIndex,
    int newIndex,
  )
  onReorder;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: AdminPanel(
        title: placement.label,
        subtitle: '${sections.length} sections in this page position',
        child: sections.isEmpty
            ? const Text('No sections in this lane.')
            : ReorderableListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: sections.length,
                onReorderItem: (oldIndex, newIndex) =>
                    onReorder(placement, oldIndex, newIndex),
                itemBuilder: (context, index) {
                  final section = sections[index];
                  return _SectionCanvasCard(
                    key: ValueKey(section.id ?? section.sectionKey),
                    section: section,
                    onEdit: onEdit,
                    onPreview: onPreview,
                    onDuplicate: onDuplicate,
                    onDelete: onDelete,
                    onTogglePublished: onTogglePublished,
                  );
                },
              ),
      ),
    );
  }
}

class _SectionCanvasCard extends StatelessWidget {
  const _SectionCanvasCard({
    super.key,
    required this.section,
    required this.onEdit,
    required this.onPreview,
    required this.onDuplicate,
    required this.onDelete,
    required this.onTogglePublished,
  });

  final PageSection section;
  final ValueChanged<PageSection> onEdit;
  final ValueChanged<PageSection> onPreview;
  final ValueChanged<PageSection> onDuplicate;
  final ValueChanged<PageSection> onDelete;
  final ValueChanged<PageSection> onTogglePublished;

  @override
  Widget build(BuildContext context) {
    final readiness = assessPageSectionReadiness(section);
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            const Icon(Icons.drag_indicator),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    section.title,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      AdminStatusChip(label: section.sectionType.label),
                      AdminStatusChip(label: section.tone.label),
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
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Preview',
              onPressed: () => onPreview(section),
              icon: const Icon(Icons.visibility_outlined),
            ),
            IconButton(
              tooltip: 'Edit',
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
              tooltip: 'Duplicate as draft',
              onPressed: () => onDuplicate(section),
              icon: const Icon(Icons.copy_outlined),
            ),
            IconButton(
              tooltip: 'Delete',
              onPressed: section.id == null ? null : () => onDelete(section),
              icon: const Icon(Icons.delete_outline),
            ),
          ],
        ),
      ),
    );
  }
}
