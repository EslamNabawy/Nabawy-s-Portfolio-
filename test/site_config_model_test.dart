import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio_admin/features/settings/domain/entities/site_config.dart';

void main() {
  test('SiteConfig parses and serializes public design variant', () {
    final config = SiteConfig.fromJson(const {
      'id': 'global',
      'name': 'Eslam Nabawy',
      'headline': 'Software engineer',
      'bio': 'Builds reliable systems.',
      'design_variant': 'terminal_ops',
    });

    expect(config.designVariant, PublicDesignVariant.terminalOps);
    expect(config.toJson()['design_variant'], 'terminal_ops');
    expect(config.themeConfig.toJson()['accentColor'], 'signal');
  });

  test('SiteConfig supports signal studio design variant', () {
    final config = SiteConfig.fromJson(const {
      'id': 'global',
      'name': 'Eslam Nabawy',
      'headline': 'Software engineer',
      'bio': 'Builds reliable systems.',
      'design_variant': 'signal_studio',
    });

    expect(config.designVariant, PublicDesignVariant.signalStudio);
    expect(config.toJson()['design_variant'], 'signal_studio');
  });

  test('SiteConfig parses custom theme tokens', () {
    final config = SiteConfig.fromJson(const {
      'id': 'global',
      'name': 'Eslam Nabawy',
      'headline': 'Software engineer',
      'bio': 'Builds reliable systems.',
      'design_variant': 'system_forge',
      'theme_json': {
        'accentColor': 'amber',
        'backgroundMode': 'forge',
        'surfaceStyle': 'panel',
        'radius': 'sharp',
        'borderWeight': 'bold',
        'density': 'compact',
        'motionIntensity': 'standard',
        'heroTreatment': 'forge',
        'heroLayout': 'compact',
        'sectionOrder': 'projects_first',
        'projectCardStyle': 'visual',
        'showFeaturedProjectPanel': false,
      },
    });

    expect(config.designVariant, PublicDesignVariant.systemForge);
    expect(config.themeConfig.toJson()['heroTreatment'], 'forge');
    expect(config.themeConfig.toJson()['heroLayout'], 'compact');
    expect(config.themeConfig.toJson()['sectionOrder'], 'projects_first');
    expect(config.themeConfig.toJson()['projectCardStyle'], 'visual');
    expect(config.themeConfig.toJson()['showFeaturedProjectPanel'], false);
    expect(config.toJson()['theme_json'], isA<Map<String, Object?>>());
  });
}
