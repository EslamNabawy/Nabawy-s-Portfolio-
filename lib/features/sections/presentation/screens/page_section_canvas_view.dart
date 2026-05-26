import 'package:flutter/material.dart';

import '../../domain/entities/page_section.dart';
import '../../domain/entities/page_section_readiness.dart';
import 'page_section_preview.dart';
import 'page_section_preview_widgets.dart';

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
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        const BuiltInPageBand(
          label: 'Hero',
          title: 'Public hero and primary proof summary',
        ),
        _PlacementPreviewLane(
          placement: PageSectionPlacement.afterHero,
          sections: _sectionsFor(PageSectionPlacement.afterHero),
          onEdit: onEdit,
          onPreview: onPreview,
          onDuplicate: onDuplicate,
          onDelete: onDelete,
          onTogglePublished: onTogglePublished,
          onReorder: onReorder,
        ),
        const BuiltInPageBand(
          label: 'System Signal',
          title: 'Static proof band rendered by the portfolio template',
        ),
        _PlacementPreviewLane(
          placement: PageSectionPlacement.beforeProjects,
          sections: _sectionsFor(PageSectionPlacement.beforeProjects),
          onEdit: onEdit,
          onPreview: onPreview,
          onDuplicate: onDuplicate,
          onDelete: onDelete,
          onTogglePublished: onTogglePublished,
          onReorder: onReorder,
        ),
        const BuiltInPageBand(
          label: 'Projects',
          title: 'Published project dossier grid',
        ),
        _PlacementPreviewLane(
          placement: PageSectionPlacement.beforeLab,
          sections: _sectionsFor(PageSectionPlacement.beforeLab),
          onEdit: onEdit,
          onPreview: onPreview,
          onDuplicate: onDuplicate,
          onDelete: onDelete,
          onTogglePublished: onTogglePublished,
          onReorder: onReorder,
        ),
        const BuiltInPageBand(label: 'Lab', title: 'Experiment cards'),
        _PlacementPreviewLane(
          placement: PageSectionPlacement.beforeSkills,
          sections: _sectionsFor(PageSectionPlacement.beforeSkills),
          onEdit: onEdit,
          onPreview: onPreview,
          onDuplicate: onDuplicate,
          onDelete: onDelete,
          onTogglePublished: onTogglePublished,
          onReorder: onReorder,
        ),
        const BuiltInPageBand(label: 'Skills', title: 'Capability matrix'),
        _PlacementPreviewLane(
          placement: PageSectionPlacement.beforeContact,
          sections: _sectionsFor(PageSectionPlacement.beforeContact),
          onEdit: onEdit,
          onPreview: onPreview,
          onDuplicate: onDuplicate,
          onDelete: onDelete,
          onTogglePublished: onTogglePublished,
          onReorder: onReorder,
        ),
        const BuiltInPageBand(label: 'Contact', title: 'Conversion links'),
      ],
    );
  }

  List<PageSection> _sectionsFor(PageSectionPlacement placement) {
    return sections
        .where((section) => section.placement == placement)
        .toList(growable: false);
  }
}

class _PlacementPreviewLane extends StatelessWidget {
  const _PlacementPreviewLane({
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
    if (sections.isEmpty) {
      return EmptyPreviewDropZone(label: placement.label);
    }
    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sections.length,
      onReorderItem: (oldIndex, newIndex) =>
          onReorder(placement, oldIndex, newIndex),
      itemBuilder: (context, index) {
        final section = sections[index];
        return _EditablePreviewSection(
          key: ValueKey(section.id ?? section.sectionKey),
          section: section,
          onEdit: onEdit,
          onPreview: onPreview,
          onDuplicate: onDuplicate,
          onDelete: onDelete,
          onTogglePublished: onTogglePublished,
        );
      },
    );
  }
}

class _EditablePreviewSection extends StatelessWidget {
  const _EditablePreviewSection({
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFF00836B), width: 1.5),
          color: Colors.white,
        ),
        child: Column(
          children: [
            PageSectionPreviewToolbar(
              section: section,
              readiness: readiness,
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
    );
  }
}
