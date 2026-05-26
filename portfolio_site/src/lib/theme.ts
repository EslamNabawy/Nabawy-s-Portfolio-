import type { SiteThemeConfig } from './types';

const defaults: Required<SiteThemeConfig> = {
  accentColor: 'signal',
  backgroundMode: 'grid',
  surfaceStyle: 'panel',
  radius: 'compact',
  borderWeight: 'standard',
  density: 'standard',
  motionIntensity: 'standard',
  heroTreatment: 'console',
  heroLayout: 'split',
  sectionOrder: 'recruiter_first',
  projectCardStyle: 'proof',
  showFeaturedProjectPanel: true,
};

const tokenValues = {
  accentColor: ['signal', 'cyan', 'amber', 'oxide'],
  backgroundMode: ['grid', 'clean', 'terminal', 'studio', 'forge'],
  surfaceStyle: ['flat', 'panel', 'glass', 'elevated'],
  radius: ['sharp', 'compact', 'standard', 'soft'],
  borderWeight: ['thin', 'standard', 'bold'],
  density: ['compact', 'standard', 'spacious'],
  motionIntensity: ['none', 'reduced', 'standard', 'expressive'],
  heroTreatment: ['console', 'dossier', 'terminal', 'studio', 'forge'],
  heroLayout: ['split', 'statement', 'compact'],
  sectionOrder: ['recruiter_first', 'projects_first'],
  projectCardStyle: ['proof', 'visual', 'compact'],
} as const;

export function normalizeThemeConfig(theme: unknown): Required<SiteThemeConfig> {
  if (theme === null || typeof theme !== 'object') {
    return defaults;
  }
  const source = theme as Record<string, unknown>;
  return {
    accentColor: readToken(source, 'accentColor'),
    backgroundMode: readToken(source, 'backgroundMode'),
    surfaceStyle: readToken(source, 'surfaceStyle'),
    radius: readToken(source, 'radius'),
    borderWeight: readToken(source, 'borderWeight'),
    density: readToken(source, 'density'),
    motionIntensity: readToken(source, 'motionIntensity'),
    heroTreatment: readToken(source, 'heroTreatment'),
    heroLayout: readToken(source, 'heroLayout'),
    sectionOrder: readToken(source, 'sectionOrder'),
    projectCardStyle: readToken(source, 'projectCardStyle'),
    showFeaturedProjectPanel:
      typeof source.showFeaturedProjectPanel === 'boolean'
        ? source.showFeaturedProjectPanel
        : defaults.showFeaturedProjectPanel,
  };
}

export function themeClass(theme: SiteThemeConfig): string {
  const normalized = normalizeThemeConfig(theme);
  return [
    `theme-bg-${normalized.backgroundMode}`,
    `theme-surface-${normalized.surfaceStyle}`,
    `theme-motion-${normalized.motionIntensity}`,
    `theme-hero-${normalized.heroTreatment}`,
    `theme-hero-layout-${normalized.heroLayout}`,
    `theme-section-order-${normalized.sectionOrder}`,
    `theme-project-cards-${normalized.projectCardStyle}`,
    normalized.showFeaturedProjectPanel
      ? 'theme-featured-panel-on'
      : 'theme-featured-panel-off',
  ].join(' ');
}

export function themeStyleAttribute(theme: SiteThemeConfig): string {
  const normalized = normalizeThemeConfig(theme);
  return [
    `--theme-accent:${accent(normalized.accentColor)}`,
    `--theme-radius:${radius(normalized.radius)}`,
    `--theme-border:${border(normalized.borderWeight)}`,
    `--theme-section-y:${sectionPadding(normalized.density)}`,
  ].join(';');
}

function readToken<Key extends keyof typeof tokenValues>(
  source: Record<string, unknown>,
  key: Key,
): Required<SiteThemeConfig>[Key] {
  const value = source[key];
  const allowed = tokenValues[key] as readonly string[];
  return typeof value === 'string' && allowed.includes(value)
    ? (value as Required<SiteThemeConfig>[Key])
    : defaults[key];
}

function accent(value: Required<SiteThemeConfig>['accentColor']): string {
  return {
    signal: '#00836b',
    cyan: '#21d3be',
    amber: '#b86105',
    oxide: '#a83a2a',
  }[value];
}

function radius(value: Required<SiteThemeConfig>['radius']): string {
  return {
    sharp: '0px',
    compact: '6px',
    standard: '10px',
    soft: '16px',
  }[value];
}

function border(value: Required<SiteThemeConfig>['borderWeight']): string {
  return {
    thin: '1px',
    standard: '1.5px',
    bold: '2px',
  }[value];
}

function sectionPadding(value: Required<SiteThemeConfig>['density']): string {
  return {
    compact: '44px',
    standard: '56px',
    spacious: '76px',
  }[value];
}
