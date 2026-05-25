import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio_admin/features/sections/domain/entities/page_section.dart';

void main() {
  test('PageSection parses Supabase row and serializes save payload', () {
    final section = PageSection.fromJson(const {
      'id': 'aa5bb6fe-2650-46bf-a90a-dff4f6f311a7',
      'section_key': 'systems-proof',
      'title': 'Systems Proof',
      'eyebrow': 'Custom Section',
      'body': 'Evidence-heavy section managed from the dashboard.',
      'placement': 'before_projects',
      'section_type': 'content_grid',
      'layout': 'grid',
      'tone': 'signal',
      'density': 'spacious',
      'alignment': 'center',
      'content_json': {
        'items': [
          {'label': '01', 'title': 'Signal', 'copy': 'Validated model.'},
        ],
      },
      'design_json': {'accent': 'cyan'},
      'display_order': 3,
      'is_published': true,
      'created_at': '2026-05-26T10:00:00Z',
      'updated_at': '2026-05-26T11:00:00Z',
    });

    expect(section.placement, PageSectionPlacement.beforeProjects);
    expect(section.sectionType, PageSectionType.contentGrid);
    expect(section.layout, PageSectionLayout.grid);
    expect(section.tone, PageSectionTone.signal);
    expect(section.alignment, PageSectionAlignment.center);
    expect(section.contentJson['items'], isA<List<Object?>>());

    final json = section.toJson();
    expect(json['section_key'], 'systems-proof');
    expect(json['placement'], 'before_projects');
    expect(json['tone'], 'signal');
    expect(json['is_published'], isTrue);
  });
}
