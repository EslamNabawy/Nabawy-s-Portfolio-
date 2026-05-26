import '../../domain/entities/page_section.dart';

enum BuiltInPageSection {
  hero('Hero', 'Edit identity, headline, bio, resume, and contact links.'),
  projects(
    'Projects',
    'Manage project dossiers, screenshots, and publish state.',
  ),
  lab('Lab', 'Manage experiments, prototypes, and research notes.'),
  skills('Skills', 'Manage the capability matrix and skill groups.'),
  contact('Contact', 'Edit direct conversion links and resume metadata.');

  const BuiltInPageSection(this.label, this.description);

  final String label;
  final String description;
}

enum PageBuilderSelectionKind { none, builtIn, customSection, emptyPlacement }

final class PageBuilderSelection {
  const PageBuilderSelection._({
    required this.kind,
    this.builtIn,
    this.sectionId,
    this.placement,
  });

  const PageBuilderSelection.none()
    : this._(kind: PageBuilderSelectionKind.none);

  const PageBuilderSelection.builtIn(BuiltInPageSection section)
    : this._(kind: PageBuilderSelectionKind.builtIn, builtIn: section);

  const PageBuilderSelection.customSection(String id)
    : this._(kind: PageBuilderSelectionKind.customSection, sectionId: id);

  const PageBuilderSelection.emptyPlacement(PageSectionPlacement placement)
    : this._(
        kind: PageBuilderSelectionKind.emptyPlacement,
        placement: placement,
      );

  final PageBuilderSelectionKind kind;
  final BuiltInPageSection? builtIn;
  final String? sectionId;
  final PageSectionPlacement? placement;

  bool isBuiltIn(BuiltInPageSection section) => builtIn == section;

  bool isCustom(PageSection section) {
    return sectionId == (section.id ?? section.sectionKey);
  }

  bool isEmptyPlacement(PageSectionPlacement value) => placement == value;
}
