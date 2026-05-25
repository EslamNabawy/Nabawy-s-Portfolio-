import '../../../../core/utils/json_readers.dart';

enum PageSectionPlacement {
  afterHero('after_hero', 'After Hero'),
  beforeProjects('before_projects', 'Before Projects'),
  beforeLab('before_lab', 'Before Lab'),
  beforeSkills('before_skills', 'Before Skills'),
  beforeContact('before_contact', 'Before Contact');

  const PageSectionPlacement(this.value, this.label);

  final String value;
  final String label;

  static PageSectionPlacement fromJson(String value) {
    return values.firstWhere(
      (item) => item.value == value,
      orElse: () =>
          throw FormatException('Unknown section placement "$value".'),
    );
  }
}

enum PageSectionType {
  contentGrid('content_grid', 'Content Grid'),
  metricStrip('metric_strip', 'Metric Strip'),
  timeline('timeline', 'Timeline'),
  callout('callout', 'Callout'),
  cta('cta', 'CTA');

  const PageSectionType(this.value, this.label);

  final String value;
  final String label;

  static PageSectionType fromJson(String value) {
    return values.firstWhere(
      (item) => item.value == value,
      orElse: () => throw FormatException('Unknown section type "$value".'),
    );
  }
}

enum PageSectionLayout {
  stack('stack', 'Stack'),
  split('split', 'Split'),
  grid('grid', 'Grid'),
  rail('rail', 'Rail'),
  banner('banner', 'Banner');

  const PageSectionLayout(this.value, this.label);

  final String value;
  final String label;

  static PageSectionLayout fromJson(String value) {
    return values.firstWhere(
      (item) => item.value == value,
      orElse: () => throw FormatException('Unknown section layout "$value".'),
    );
  }
}

enum PageSectionTone {
  panel('panel', 'Panel'),
  ink('ink', 'Ink'),
  signal('signal', 'Signal'),
  studio('studio', 'Studio'),
  minimal('minimal', 'Minimal');

  const PageSectionTone(this.value, this.label);

  final String value;
  final String label;

  static PageSectionTone fromJson(String value) {
    return values.firstWhere(
      (item) => item.value == value,
      orElse: () => throw FormatException('Unknown section tone "$value".'),
    );
  }
}

enum PageSectionDensity {
  compact('compact', 'Compact'),
  standard('standard', 'Standard'),
  spacious('spacious', 'Spacious');

  const PageSectionDensity(this.value, this.label);

  final String value;
  final String label;

  static PageSectionDensity fromJson(String value) {
    return values.firstWhere(
      (item) => item.value == value,
      orElse: () => throw FormatException('Unknown section density "$value".'),
    );
  }
}

enum PageSectionAlignment {
  left('left', 'Left'),
  center('center', 'Center');

  const PageSectionAlignment(this.value, this.label);

  final String value;
  final String label;

  static PageSectionAlignment fromJson(String value) {
    return values.firstWhere(
      (item) => item.value == value,
      orElse: () =>
          throw FormatException('Unknown section alignment "$value".'),
    );
  }
}

final class PageSection {
  const PageSection({
    this.id,
    required this.sectionKey,
    required this.title,
    this.eyebrow,
    this.body,
    this.placement = PageSectionPlacement.afterHero,
    this.sectionType = PageSectionType.contentGrid,
    this.layout = PageSectionLayout.stack,
    this.tone = PageSectionTone.panel,
    this.density = PageSectionDensity.standard,
    this.alignment = PageSectionAlignment.left,
    this.contentJson = const <String, Object?>{},
    this.designJson = const <String, Object?>{},
    this.displayOrder = 0,
    this.isPublished = false,
    this.createdAt,
    this.updatedAt,
  });

  final String? id;
  final String sectionKey;
  final String title;
  final String? eyebrow;
  final String? body;
  final PageSectionPlacement placement;
  final PageSectionType sectionType;
  final PageSectionLayout layout;
  final PageSectionTone tone;
  final PageSectionDensity density;
  final PageSectionAlignment alignment;
  final JsonMap contentJson;
  final JsonMap designJson;
  final int displayOrder;
  final bool isPublished;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory PageSection.fromJson(JsonMap json) {
    return PageSection(
      id: readOptionalString(json, 'id'),
      sectionKey: readString(json, 'section_key'),
      title: readString(json, 'title'),
      eyebrow: readOptionalString(json, 'eyebrow'),
      body: readOptionalString(json, 'body'),
      placement: PageSectionPlacement.fromJson(readString(json, 'placement')),
      sectionType: PageSectionType.fromJson(readString(json, 'section_type')),
      layout: PageSectionLayout.fromJson(readString(json, 'layout')),
      tone: PageSectionTone.fromJson(readString(json, 'tone')),
      density: PageSectionDensity.fromJson(readString(json, 'density')),
      alignment: PageSectionAlignment.fromJson(readString(json, 'alignment')),
      contentJson: readJsonObject(json, 'content_json'),
      designJson: readJsonObject(json, 'design_json'),
      displayOrder: readInt(json, 'display_order'),
      isPublished: readBool(json, 'is_published'),
      createdAt: readOptionalDateTime(json, 'created_at'),
      updatedAt: readOptionalDateTime(json, 'updated_at'),
    );
  }

  JsonMap toJson() {
    return <String, Object?>{
      if (id != null) 'id': id,
      'section_key': sectionKey,
      'title': title,
      'eyebrow': eyebrow,
      'body': body,
      'placement': placement.value,
      'section_type': sectionType.value,
      'layout': layout.value,
      'tone': tone.value,
      'density': density.value,
      'alignment': alignment.value,
      'content_json': contentJson,
      'design_json': designJson,
      'display_order': displayOrder,
      'is_published': isPublished,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }
}
