import 'package:flutter/material.dart';

import '../../../../shared/ui/admin_components.dart';
import '../../domain/entities/page_section.dart';
import '../../domain/entities/page_section_readiness.dart';

class PageSectionTableView extends StatelessWidget {
  const PageSectionTableView({
    super.key,
    required this.sections,
    required this.onEdit,
    required this.onPreview,
    required this.onDuplicate,
    required this.onDelete,
    required this.onTogglePublished,
  });

  final List<PageSection> sections;
  final ValueChanged<PageSection> onEdit;
  final ValueChanged<PageSection> onPreview;
  final ValueChanged<PageSection> onDuplicate;
  final ValueChanged<PageSection> onDelete;
  final ValueChanged<PageSection> onTogglePublished;

  @override
  Widget build(BuildContext context) {
    if (sections.isEmpty) {
      return const Center(child: Text('No custom page sections yet.'));
    }
    return Card(
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Order')),
              DataColumn(label: Text('Title')),
              DataColumn(label: Text('Placement')),
              DataColumn(label: Text('Type')),
              DataColumn(label: Text('Tone')),
              DataColumn(label: Text('Status')),
              DataColumn(label: Text('Readiness')),
              DataColumn(label: Text('Actions')),
            ],
            rows: [
              for (final section in sections)
                DataRow(
                  selected: section.isPublished,
                  cells: [
                    DataCell(Text(section.displayOrder.toString())),
                    DataCell(SizedBox(width: 220, child: Text(section.title))),
                    DataCell(Text(section.placement.label)),
                    DataCell(Text(section.sectionType.label)),
                    DataCell(Text(section.tone.label)),
                    DataCell(_StatusChip(section: section)),
                    DataCell(_ReadinessChip(section: section)),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
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
                            tooltip: section.isPublished
                                ? 'Unpublish'
                                : 'Publish',
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
                            onPressed: section.id == null
                                ? null
                                : () => onDelete(section),
                            icon: const Icon(Icons.delete_outline),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.section});

  final PageSection section;

  @override
  Widget build(BuildContext context) {
    return AdminStatusChip(
      label: section.isPublished ? 'Published' : 'Draft',
      tone: section.isPublished
          ? AdminStatusTone.success
          : AdminStatusTone.warning,
    );
  }
}

class _ReadinessChip extends StatelessWidget {
  const _ReadinessChip({required this.section});

  final PageSection section;

  @override
  Widget build(BuildContext context) {
    final readiness = assessPageSectionReadiness(section);
    return AdminStatusChip(
      label: readiness.isReady
          ? 'Ready'
          : '${readiness.messages.length} issues',
      tone: readiness.isReady
          ? AdminStatusTone.success
          : AdminStatusTone.danger,
    );
  }
}
