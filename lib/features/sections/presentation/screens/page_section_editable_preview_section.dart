import 'package:flutter/material.dart';

import '../../domain/entities/page_section.dart';
import '../../domain/entities/page_section_readiness.dart';
import 'page_section_preview.dart';
import 'page_section_preview_widgets.dart';

class EditablePageSectionPreview extends StatelessWidget {
  const EditablePageSectionPreview({
    super.key,
    required this.section,
    required this.selected,
    required this.onSelect,
    required this.onEdit,
    required this.onPreview,
    required this.onDuplicate,
    required this.onDelete,
    required this.onTogglePublished,
  });

  final PageSection section;
  final bool selected;
  final ValueChanged<PageSection> onSelect;
  final ValueChanged<PageSection> onEdit;
  final ValueChanged<PageSection> onPreview;
  final ValueChanged<PageSection> onDuplicate;
  final ValueChanged<PageSection> onDelete;
  final ValueChanged<PageSection> onTogglePublished;

  @override
  Widget build(BuildContext context) {
    final readiness = assessPageSectionReadiness(section);
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: InkWell(
        onTap: () => onSelect(section),
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(
              color: selected
                  ? const Color(0xFF00836B)
                  : const Color(0xFFC7D2CC),
              width: selected ? 2 : 1,
            ),
            color: Colors.white,
          ),
          child: Column(
            children: [
              PageSectionPreviewToolbar(
                section: section,
                readiness: readiness,
                selected: selected,
                onEdit: onEdit,
                onPreview: onPreview,
                onDuplicate: onDuplicate,
                onDelete: onDelete,
                onTogglePublished: onTogglePublished,
              ),
              PageSectionPreview(section: section),
            ],
          ),
        ),
      ),
    );
  }
}
