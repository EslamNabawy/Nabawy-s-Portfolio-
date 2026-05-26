import 'package:flutter/material.dart';

import '../../../../shared/ui/admin_components.dart';
import '../../domain/entities/page_section.dart';

class PageSectionEditorSurface extends StatelessWidget {
  const PageSectionEditorSurface({
    super.key,
    required this.preview,
    required this.inspector,
  });

  final Widget preview;
  final Widget inspector;

  @override
  Widget build(BuildContext context) {
    return ResponsiveTwoPane(
      primary: preview,
      secondary: ListView(padding: EdgeInsets.zero, children: [inspector]),
    );
  }
}

class PageSectionErrorState extends StatelessWidget {
  const PageSectionErrorState({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

PageSection? selectedPageSection(
  List<PageSection> sections,
  String? selectedId,
) {
  if (selectedId == null) {
    return null;
  }
  for (final section in sections) {
    if (pageSectionIdentity(section) == selectedId) {
      return section;
    }
  }
  return null;
}

String pageSectionIdentity(PageSection section) =>
    section.id ?? section.sectionKey;

int nextPageSectionDisplayOrder(
  List<PageSection> sections,
  PageSectionPlacement placement,
) {
  var maxOrder = 0;
  for (final section in sections.where((item) => item.placement == placement)) {
    if (section.displayOrder > maxOrder) {
      maxOrder = section.displayOrder;
    }
  }
  return maxOrder + 10;
}

PageSection normalizePageSectionOrder(
  List<PageSection> sections,
  PageSection section,
) {
  final original = selectedPageSection(sections, pageSectionIdentity(section));
  final moved = original != null && original.placement != section.placement;
  return moved
      ? section.copyWith(
          displayOrder: nextPageSectionDisplayOrder(
            sections,
            section.placement,
          ),
        )
      : section;
}

Future<bool> confirmDeletePageSection(
  BuildContext context,
  PageSection section,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Delete section'),
      content: Text('Delete "${section.title}"? This cannot be undone.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
  return confirmed == true;
}
