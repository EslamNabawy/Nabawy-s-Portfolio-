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
    required this.onPublishAll,
    required this.onUnpublishAll,
  });

  final SectionListViewMode view;
  final bool isSaving;
  final ValueChanged<SectionListViewMode> onViewChanged;
  final VoidCallback onRefresh;
  final VoidCallback onCreate;
  final VoidCallback onTemplate;
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
              label: Text('Canvas'),
              icon: Icon(Icons.view_quilt_outlined),
            ),
            ButtonSegment(
              value: SectionListViewMode.table,
              label: Text('Table'),
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
          label: 'Templates',
          icon: Icons.dashboard_customize_outlined,
          onPressed: isSaving ? null : onTemplate,
        ),
        CommandButton(
          label: 'Publish Drafts',
          icon: Icons.publish_outlined,
          onPressed: isSaving ? null : onPublishAll,
        ),
        CommandButton(
          label: 'Unpublish All',
          icon: Icons.visibility_off_outlined,
          onPressed: isSaving ? null : onUnpublishAll,
        ),
        CommandButton(
          label: 'New Section',
          icon: Icons.add,
          primary: true,
          onPressed: isSaving ? null : onCreate,
        ),
      ],
    );
  }
}
