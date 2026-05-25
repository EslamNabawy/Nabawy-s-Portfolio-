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
  });
}
