import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio_admin/features/sections/domain/entities/page_section.dart';
import 'package:portfolio_admin/features/sections/presentation/screens/page_builder_inspector.dart';
import 'package:portfolio_admin/features/sections/presentation/screens/page_builder_selection.dart';
import 'package:portfolio_admin/features/sections/presentation/screens/page_section_canvas_view.dart';
import 'package:portfolio_admin/features/sections/presentation/screens/page_section_editable_preview_section.dart';
import 'package:portfolio_admin/features/sections/presentation/screens/page_section_list_support.dart';
import 'package:portfolio_admin/shared/ui/admin_shell.dart';

void main() {
  testWidgets('selecting custom section updates inspector', (tester) async {
    tester.view.physicalSize = const Size(1400, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    var selection = const PageBuilderSelection.none();
    final section = _section();

    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) {
            return Scaffold(
              body: Row(
                children: [
                  Expanded(
                    child: PageSectionCanvasView(
                      sections: [section],
                      selection: selection,
                      onSelectionChanged: (value) =>
                          setState(() => selection = value),
                      onAddAtPlacement: (_) {},
                      onEdit: (_) {},
                      onPreview: (_) {},
                      onDuplicate: (_) {},
                      onDelete: (_) {},
                      onTogglePublished: (_) {},
                      onReorder: (_, _, _) {},
                    ),
                  ),
                  SizedBox(
                    width: 420,
                    child: ListView(
                      children: [
                        PageBuilderInspector(
                          selection: selection,
                          section: selectedPageSection([
                            section,
                          ], selection.sectionId),
                          isSaving: false,
                          isDeploying: false,
                          onNavigate: (_) {},
                          onCreateAtPlacement: (_) {},
                          onSave: (_) async {},
                          onSaveAndDeploy: (_) async {},
                          onEditAdvanced: (_) {},
                          onPreview: (_) {},
                          onDuplicate: (_) {},
                          onDelete: (_) {},
                          onTogglePublished: (_) {},
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );

    expect(find.text('Nothing selected'), findsOneWidget);
    await tester.tap(find.byType(EditablePageSectionPreview));
    await tester.pump();

    expect(find.text('demo-section'), findsWidgets);
    expect(find.text('Section Key'), findsOneWidget);
    expect(find.text('Blocks'), findsOneWidget);
  });

  testWidgets('selecting built-in band exposes navigation shortcut', (
    tester,
  ) async {
    AdminSection? navigatedTo;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BuiltInSectionInspector(
            section: BuiltInPageSection.projects,
            onNavigate: (section) => navigatedTo = section,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Projects'));
    expect(navigatedTo, AdminSection.projects);
  });
}

PageSection _section() {
  return const PageSection(
    id: 'section-1',
    sectionKey: 'demo-section',
    title: 'Demo Section',
    contentJson: {
      'schemaVersion': 2,
      'blocks': [
        {'type': 'callout', 'title': 'Proof', 'copy': 'Inspectable block.'},
      ],
    },
    designJson: {'accent': 'signal'},
    isPublished: true,
  );
}
