import 'page_section.dart';
import 'page_section_template_payloads.dart';

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
    name: 'Featured Case Study',
    description: 'A recruiter-facing case-study spotlight before projects.',
    section: PageSection(
      sectionKey: 'featured-case-study',
      title: 'Featured System Build',
      eyebrow: 'Case Study',
      body:
          'Use this to highlight one strong build with problem, architecture, and outcome.',
      placement: PageSectionPlacement.beforeProjects,
      sectionType: PageSectionType.contentGrid,
      layout: PageSectionLayout.grid,
      tone: PageSectionTone.panel,
      density: PageSectionDensity.standard,
      alignment: PageSectionAlignment.left,
      contentJson: featuredCaseStudyContent,
      designJson: signalDesign,
    ),
  ),
  PageSectionTemplate(
    name: 'Proof Metrics',
    description: 'Compact KPI row for performance, shipping, or system stats.',
    section: PageSection(
      sectionKey: 'proof-metrics',
      title: 'Operating Metrics',
      eyebrow: 'Telemetry',
      body: 'Use short numbers and labels. Keep it honest and easy to scan.',
      placement: PageSectionPlacement.afterHero,
      sectionType: PageSectionType.metricStrip,
      layout: PageSectionLayout.grid,
      tone: PageSectionTone.ink,
      density: PageSectionDensity.compact,
      alignment: PageSectionAlignment.center,
      contentJson: metricContent,
      designJson: signalDesign,
    ),
  ),
  PageSectionTemplate(
    name: 'Technical Stack Matrix',
    description: 'A structured capability map for tools and system domains.',
    section: PageSection(
      sectionKey: 'technical-stack-matrix',
      title: 'Technical Stack Matrix',
      eyebrow: 'Capability Map',
      body:
          'Group your engineering depth by system layer instead of buzzwords.',
      placement: PageSectionPlacement.beforeSkills,
      sectionType: PageSectionType.contentGrid,
      layout: PageSectionLayout.grid,
      tone: PageSectionTone.minimal,
      density: PageSectionDensity.standard,
      alignment: PageSectionAlignment.left,
      contentJson: stackMatrixContent,
      designJson: minimalDesign,
    ),
  ),
  PageSectionTemplate(
    name: 'AI Lab',
    description:
        'A focused lab callout for agents, automation, and prototypes.',
    section: PageSection(
      sectionKey: 'ai-lab-signal',
      title: 'Agentic Systems Lab',
      eyebrow: 'Lab',
      body:
          'Use this before the Lab section to frame experiments as engineering research.',
      placement: PageSectionPlacement.beforeLab,
      sectionType: PageSectionType.callout,
      layout: PageSectionLayout.split,
      tone: PageSectionTone.studio,
      density: PageSectionDensity.standard,
      alignment: PageSectionAlignment.left,
      contentJson: aiLabContent,
      designJson: signalDesign,
    ),
  ),
  PageSectionTemplate(
    name: 'WebRTC System Map',
    description: 'Architecture-panel template for peer-to-peer systems.',
    section: PageSection(
      sectionKey: 'webrtc-system-map',
      title: 'Decentralized System Map',
      eyebrow: 'Architecture',
      body: 'Show signaling, peers, state sync, and failure handling.',
      placement: PageSectionPlacement.beforeProjects,
      sectionType: PageSectionType.contentGrid,
      layout: PageSectionLayout.rail,
      tone: PageSectionTone.ink,
      density: PageSectionDensity.standard,
      alignment: PageSectionAlignment.left,
      contentJson: webrtcMapContent,
      designJson: signalDesign,
    ),
  ),
  PageSectionTemplate(
    name: 'Resume CTA',
    description: 'High-signal callout before the contact route.',
    section: PageSection(
      sectionKey: 'resume-cta',
      title: 'Review the full engineering profile',
      eyebrow: 'Resume',
      body: 'Use this CTA for direct conversion without visual noise.',
      placement: PageSectionPlacement.beforeContact,
      sectionType: PageSectionType.cta,
      layout: PageSectionLayout.banner,
      tone: PageSectionTone.signal,
      density: PageSectionDensity.spacious,
      alignment: PageSectionAlignment.center,
      contentJson: resumeCtaContent,
      designJson: signalDesign,
    ),
  ),
];

PageSection sectionFromTemplate(
  PageSectionTemplate template, {
  PageSectionPlacement? placement,
  int? displayOrder,
}) {
  return _draftCopy(
    template.section.copyWith(placement: placement, displayOrder: displayOrder),
  );
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
