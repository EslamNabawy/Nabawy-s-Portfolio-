import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio_admin/features/settings/domain/entities/site_config.dart';
import 'package:portfolio_admin/features/settings/domain/entities/site_theme_preset.dart';
import 'package:portfolio_admin/features/settings/presentation/screens/design_studio_widgets.dart';

void main() {
  testWidgets('DesignPresetGrid selects System Forge preset', (tester) async {
    SiteThemePreset? selected;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DesignPresetGrid(
            selected: PublicDesignVariant.commandCenter,
            onSelected: (preset) => selected = preset,
          ),
        ),
      ),
    );

    await tester.tap(find.text('System Forge'));
    await tester.pump();

    expect(selected?.variantValue, 'system_forge');
  });
}
