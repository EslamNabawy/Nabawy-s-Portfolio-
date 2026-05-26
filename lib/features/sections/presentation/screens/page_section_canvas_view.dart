import 'package:flutter/material.dart';

import '../../domain/entities/page_section.dart';
import 'page_builder_selection.dart';
import 'page_section_editable_preview_section.dart';
import 'page_section_preview_widgets.dart';

class PageSectionCanvasView extends StatelessWidget {
  const PageSectionCanvasView({
    super.key,
    required this.sections,
    required this.selection,
    required this.onSelectionChanged,
    required this.onAddAtPlacement,
    required this.onEdit,
    required this.onPreview,
    required this.onDuplicate,
    required this.onDelete,
    required this.onTogglePublished,
    required this.onReorder,
  });

  final List<PageSection> sections;
  final PageBuilderSelection selection;
  final ValueChanged<PageBuilderSelection> onSelectionChanged;
  final ValueChanged<PageSectionPlacement> onAddAtPlacement;
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
        BuiltInPageBand(
          selected: selection.isBuiltIn(BuiltInPageSection.hero),
          label: 'Hero',
          title: 'Public hero and primary proof summary',
          onTap: () => onSelectionChanged(
            const PageBuilderSelection.builtIn(BuiltInPageSection.hero),
          ),
        ),
        _PlacementPreviewLane(
          placement: PageSectionPlacement.afterHero,
          sections: _sectionsFor(PageSectionPlacement.afterHero),
          selection: selection,
          onSelectionChanged: onSelectionChanged,
          onAddAtPlacement: onAddAtPlacement,
          onEdit: onEdit,
          onPreview: onPreview,
          onDuplicate: onDuplicate,
          onDelete: onDelete,
          onTogglePublished: onTogglePublished,
          onReorder: onReorder,
        ),
        const BuiltInPageBand(
          selected: false,
          label: 'System Signal',
          title: 'Static proof band rendered by the portfolio template',
          onTap: null,
        ),
        _PlacementPreviewLane(
          placement: PageSectionPlacement.beforeProjects,
          sections: _sectionsFor(PageSectionPlacement.beforeProjects),
          selection: selection,
          onSelectionChanged: onSelectionChanged,
          onAddAtPlacement: onAddAtPlacement,
          onEdit: onEdit,
          onPreview: onPreview,
          onDuplicate: onDuplicate,
          onDelete: onDelete,
          onTogglePublished: onTogglePublished,
          onReorder: onReorder,
        ),
        BuiltInPageBand(
          selected: selection.isBuiltIn(BuiltInPageSection.projects),
          label: 'Projects',
          title: 'Published project dossier grid',
          onTap: () => onSelectionChanged(
            const PageBuilderSelection.builtIn(BuiltInPageSection.projects),
          ),
        ),
        _PlacementPreviewLane(
          placement: PageSectionPlacement.beforeLab,
          sections: _sectionsFor(PageSectionPlacement.beforeLab),
          selection: selection,
          onSelectionChanged: onSelectionChanged,
          onAddAtPlacement: onAddAtPlacement,
          onEdit: onEdit,
          onPreview: onPreview,
          onDuplicate: onDuplicate,
          onDelete: onDelete,
          onTogglePublished: onTogglePublished,
          onReorder: onReorder,
        ),
        BuiltInPageBand(
          selected: selection.isBuiltIn(BuiltInPageSection.lab),
          label: 'Lab',
          title: 'Experiment cards',
          onTap: () => onSelectionChanged(
            const PageBuilderSelection.builtIn(BuiltInPageSection.lab),
          ),
        ),
        _PlacementPreviewLane(
          placement: PageSectionPlacement.beforeSkills,
          sections: _sectionsFor(PageSectionPlacement.beforeSkills),
          selection: selection,
          onSelectionChanged: onSelectionChanged,
          onAddAtPlacement: onAddAtPlacement,
          onEdit: onEdit,
          onPreview: onPreview,
          onDuplicate: onDuplicate,
          onDelete: onDelete,
          onTogglePublished: onTogglePublished,
          onReorder: onReorder,
        ),
        BuiltInPageBand(
          selected: selection.isBuiltIn(BuiltInPageSection.skills),
          label: 'Skills',
          title: 'Capability matrix',
          onTap: () => onSelectionChanged(
            const PageBuilderSelection.builtIn(BuiltInPageSection.skills),
          ),
        ),
        _PlacementPreviewLane(
          placement: PageSectionPlacement.beforeContact,
          sections: _sectionsFor(PageSectionPlacement.beforeContact),
          selection: selection,
          onSelectionChanged: onSelectionChanged,
          onAddAtPlacement: onAddAtPlacement,
          onEdit: onEdit,
          onPreview: onPreview,
          onDuplicate: onDuplicate,
          onDelete: onDelete,
          onTogglePublished: onTogglePublished,
          onReorder: onReorder,
        ),
        BuiltInPageBand(
          selected: selection.isBuiltIn(BuiltInPageSection.contact),
          label: 'Contact',
          title: 'Conversion links',
          onTap: () => onSelectionChanged(
            const PageBuilderSelection.builtIn(BuiltInPageSection.contact),
          ),
        ),
      ],
    );
  }

  List<PageSection> _sectionsFor(PageSectionPlacement placement) => sections
      .where((section) => section.placement == placement)
      .toList(growable: false);
}

class _PlacementPreviewLane extends StatelessWidget {
  const _PlacementPreviewLane({
    required this.placement,
    required this.sections,
    required this.selection,
    required this.onSelectionChanged,
    required this.onAddAtPlacement,
    required this.onEdit,
    required this.onPreview,
    required this.onDuplicate,
    required this.onDelete,
    required this.onTogglePublished,
    required this.onReorder,
  });

  final PageSectionPlacement placement;
  final List<PageSection> sections;
  final PageBuilderSelection selection;
  final ValueChanged<PageBuilderSelection> onSelectionChanged;
  final ValueChanged<PageSectionPlacement> onAddAtPlacement;
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
      return EmptyPreviewDropZone(
        label: placement.label,
        selected: selection.isEmptyPlacement(placement),
        onSelect: () =>
            onSelectionChanged(PageBuilderSelection.emptyPlacement(placement)),
        onAdd: () => onAddAtPlacement(placement),
      );
    }
    return Column(
      children: [
        ReorderableListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: sections.length,
          onReorderItem: (oldIndex, newIndex) =>
              onReorder(placement, oldIndex, newIndex),
          itemBuilder: (context, index) {
            final section = sections[index];
            return EditablePageSectionPreview(
              key: ValueKey(section.id ?? section.sectionKey),
              section: section,
              selected: selection.isCustom(section),
              onSelect: (value) => onSelectionChanged(
                PageBuilderSelection.customSection(
                  value.id ?? value.sectionKey,
                ),
              ),
              onEdit: onEdit,
              onPreview: onPreview,
              onDuplicate: onDuplicate,
              onDelete: onDelete,
              onTogglePublished: onTogglePublished,
            );
          },
        ),
        AddSectionInsertionPoint(
          label: placement.label,
          onPressed: () => onAddAtPlacement(placement),
        ),
      ],
    );
  }
}
