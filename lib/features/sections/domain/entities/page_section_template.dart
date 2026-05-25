import 'page_section.dart';

final class PageSectionTemplate {
  const PageSectionTemplate({
    required this.name,
    required this.description,
    required this.section,
  });

  final String name;
  final String description;
  final PageSection section;
}

const pageSectionTemplates = <PageSectionTemplate>[
  PageSectionTemplate(
    name: 'Proof Grid',
    description: 'Three evidence cards for systems, constraints, and outcomes.',
    section: PageSection(
      sectionKey: 'systems-proof',
      title: 'Engineering Proof, Not Decoration',
      eyebrow: 'Proof Layer',
      body:
          'Use this section to show technical judgment, operational detail, and measurable outcomes before recruiters hit the project grid.',
      placement: PageSectionPlacement.beforeProjects,
      sectionType: PageSectionType.contentGrid,
      layout: PageSectionLayout.grid,
      tone: PageSectionTone.panel,
      density: PageSectionDensity.standard,
      alignment: PageSectionAlignment.left,
      contentJson: _proofGridContent,
      designJson: _signalDesign,
    ),
  ),
  PageSectionTemplate(
    name: 'Metric Strip',
    description: 'Compact KPI row for performance, shipping, or system stats.',
    section: PageSection(
      sectionKey: 'system-metrics',
      title: 'Operating Metrics',
      eyebrow: 'Telemetry',
      body: 'Use short numbers and labels. Keep it honest and easy to scan.',
      placement: PageSectionPlacement.afterHero,
      sectionType: PageSectionType.metricStrip,
      layout: PageSectionLayout.grid,
      tone: PageSectionTone.ink,
      density: PageSectionDensity.compact,
      alignment: PageSectionAlignment.center,
      contentJson: _metricContent,
      designJson: _signalDesign,
    ),
  ),
  PageSectionTemplate(
    name: 'Process Timeline',
    description:
        'A focused timeline for method, delivery, or architecture flow.',
    section: PageSection(
      sectionKey: 'build-process',
      title: 'How I Build Systems',
      eyebrow: 'Execution Model',
      body: 'A structured view of how ideas move from architecture to release.',
      placement: PageSectionPlacement.beforeSkills,
      sectionType: PageSectionType.timeline,
      layout: PageSectionLayout.rail,
      tone: PageSectionTone.minimal,
      density: PageSectionDensity.standard,
      alignment: PageSectionAlignment.left,
      contentJson: _timelineContent,
      designJson: _minimalDesign,
    ),
  ),
  PageSectionTemplate(
    name: 'Contact CTA',
    description: 'High-signal callout before the contact route.',
    section: PageSection(
      sectionKey: 'availability-signal',
      title: 'Need a builder who can reason across product, systems, and UI?',
      eyebrow: 'Availability',
      body:
          'Use this CTA for direct conversion without turning the portfolio into a landing page.',
      placement: PageSectionPlacement.beforeContact,
      sectionType: PageSectionType.cta,
      layout: PageSectionLayout.banner,
      tone: PageSectionTone.signal,
      density: PageSectionDensity.spacious,
      alignment: PageSectionAlignment.center,
      contentJson: _ctaContent,
      designJson: _signalDesign,
    ),
  ),
];

PageSection sectionFromTemplate(PageSectionTemplate template) {
  return _draftCopy(template.section);
}

PageSection duplicateSection(PageSection section) {
  return _draftCopy(
    PageSection(
      sectionKey: '${section.sectionKey}-copy',
      title: '${section.title} Copy',
      eyebrow: section.eyebrow,
      body: section.body,
      placement: section.placement,
      sectionType: section.sectionType,
      layout: section.layout,
      tone: section.tone,
      density: section.density,
      alignment: section.alignment,
      contentJson: section.contentJson,
      designJson: section.designJson,
      displayOrder: section.displayOrder + 1,
    ),
  );
}

PageSection _draftCopy(PageSection section) {
  return PageSection(
    sectionKey: section.sectionKey,
    title: section.title,
    eyebrow: section.eyebrow,
    body: section.body,
    placement: section.placement,
    sectionType: section.sectionType,
    layout: section.layout,
    tone: section.tone,
    density: section.density,
    alignment: section.alignment,
    contentJson: Map<String, Object?>.unmodifiable(section.contentJson),
    designJson: Map<String, Object?>.unmodifiable(section.designJson),
    displayOrder: section.displayOrder,
  );
}

const _proofGridContent = <String, Object?>{
  'items': [
    {
      'label': '01',
      'title': 'Architecture',
      'copy': 'Clear boundaries, typed data contracts, and release-safe flows.',
    },
    {
      'label': '02',
      'title': 'Execution',
      'copy':
          'Fast iteration with validation, deployment, and operational feedback.',
    },
    {
      'label': '03',
      'title': 'Signal',
      'copy': 'Projects are presented as evidence, not just screenshots.',
    },
  ],
};

const _metricContent = <String, Object?>{
  'items': [
    {
      'label': 'SSG',
      'title': 'Static-first',
      'copy': 'No public runtime DB dependency.',
    },
    {
      'label': 'RLS',
      'title': 'Hardened CMS',
      'copy': 'Admin write boundary with public read.',
    },
    {
      'label': '0 USD',
      'title': 'Monthly Infra',
      'copy': 'Designed around free deployment limits.',
    },
  ],
};

const _timelineContent = <String, Object?>{
  'items': [
    {
      'label': '01',
      'title': 'Model',
      'copy': 'Define the system boundary and data shape.',
    },
    {
      'label': '02',
      'title': 'Build',
      'copy': 'Implement lower layers before the surface.',
    },
    {
      'label': '03',
      'title': 'Verify',
      'copy': 'Analyze, test, build, and deploy deliberately.',
    },
  ],
};

const _ctaContent = <String, Object?>{
  'actions': [
    {'label': 'Contact', 'url': '#contact'},
    {'label': 'Review Systems', 'url': '#projects'},
  ],
};

const _signalDesign = <String, Object?>{
  'accent': 'signal',
  'mediaUrl': '',
  'caption': '',
};
const _minimalDesign = <String, Object?>{
  'accent': 'minimal',
  'mediaUrl': '',
  'caption': '',
};
