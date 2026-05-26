import 'package:flutter/material.dart';

import '../../../../shared/ui/admin_components.dart';
import 'page_section_list_mode.dart';

class PageSectionListHeader extends StatelessWidget {
  const PageSectionListHeader({
    super.key,
    required this.view,
    required this.isSaving,
    required this.onViewChanged,
    required this.onRefresh,
    required this.onCreate,
    required this.onTemplate,
    required this.onDeploy,
    required this.onPublishAll,
    required this.onUnpublishAll,
  });

  final SectionListViewMode view;
  final bool isSaving;
  final ValueChanged<SectionListViewMode> onViewChanged;
  final VoidCallback onRefresh;
  final VoidCallback onCreate;
  final VoidCallback onTemplate;
  final VoidCallback onDeploy;
  final VoidCallback onPublishAll;
  final VoidCallback onUnpublishAll;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SizedBox(
          width: 260,
          child: Text(
            'Page Sections',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        SegmentedButton<SectionListViewMode>(
          segments: const [
            ButtonSegment(
              value: SectionListViewMode.canvas,
              label: Text('Page Preview'),
              icon: Icon(Icons.preview_outlined),
            ),
            ButtonSegment(
              value: SectionListViewMode.table,
              label: Text('Data Table'),
              icon: Icon(Icons.table_rows_outlined),
            ),
          ],
          selected: {view},
          onSelectionChanged: (value) => onViewChanged(value.first),
        ),
        IconButton(
          tooltip: 'Refresh',
          onPressed: isSaving ? null : onRefresh,
          icon: const Icon(Icons.refresh),
        ),
        CommandButton(
          label: 'Add Template',
          icon: Icons.add,
          primary: true,
          onPressed: isSaving ? null : onCreate,
        ),
        CommandButton(
          label: 'Deploy',
          icon: Icons.rocket_launch_outlined,
          onPressed: isSaving ? null : onDeploy,
        ),
        PopupMenuButton<_SectionCommand>(
          tooltip: 'More section actions',
          enabled: !isSaving,
          onSelected: (command) {
            switch (command) {
              case _SectionCommand.templates:
                onTemplate();
              case _SectionCommand.publishDrafts:
                onPublishAll();
              case _SectionCommand.unpublishAll:
                onUnpublishAll();
            }
          },
          itemBuilder: (context) => const [
            PopupMenuItem(
              value: _SectionCommand.templates,
              child: Text('Start From Template'),
            ),
            PopupMenuItem(
              value: _SectionCommand.publishDrafts,
              child: Text('Publish All Drafts'),
            ),
            PopupMenuItem(
              value: _SectionCommand.unpublishAll,
              child: Text('Unpublish All Sections'),
            ),
          ],
        ),
      ],
    );
  }
}

enum _SectionCommand { templates, publishDrafts, unpublishAll }
