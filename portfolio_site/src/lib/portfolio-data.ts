import type { Experiment, PageSection, Project, SiteConfig, Skill } from './types';
import { readSectionBlocks, validateSectionBlocks } from './section-blocks';
import { staticPortfolioData } from './static-portfolio-data';
import { normalizeThemeConfig } from './theme';

const projectSelect = '*, project_images(*)';
const placeholderSupabaseKey = 'replace-with-your-publishable-or-anon-key';

export type PortfolioData = {
  config: SiteConfig;
  projects: Project[];
  skills: Skill[];
  experiments: Experiment[];
  sections: PageSection[];
};

export async function getPortfolioData(): Promise<PortfolioData> {
  if (!hasSupabaseConfig()) {
    return normalizePortfolioData(staticPortfolioData);
  }

  const { supabase } = await import('./supabase');
  if (!supabase) {
    return normalizePortfolioData(staticPortfolioData);
  }

  const [configResult, skillsResult, projectsResult, experimentsResult, sectionsResult] =
    await Promise.all([
      supabase.from('site_config').select('*').eq('id', 'global').single(),
      supabase
        .from('skills')
        .select('*')
        .eq('is_published', true)
        .order('display_order', { ascending: true }),
      supabase
        .from('projects')
        .select(projectSelect)
        .eq('is_published', true)
        .order('featured', { ascending: false })
        .order('display_order', { ascending: true })
        .order('created_at', { ascending: false }),
      supabase
        .from('experiments')
        .select('*')
        .eq('is_published', true)
        .order('display_order', { ascending: true })
        .order('created_at', { ascending: false }),
      supabase
        .from('page_sections')
        .select('*')
        .eq('is_published', true)
        .order('placement', { ascending: true })
        .order('display_order', { ascending: true })
        .order('created_at', { ascending: false }),
    ]);

  const errors = [
    ['site_config.global', configResult.error],
    ['published skills', skillsResult.error],
    ['published projects', projectsResult.error],
    ['published experiments', experimentsResult.error],
    ['published page sections', sectionsResult.error],
  ].filter(([, error]) => error);

  if (errors.length > 0) {
    console.warn(
      `Supabase portfolio data unavailable; using static portfolio data. ${errors
        .map(([label, error]) => `${label}: ${(error as { message: string }).message}`)
        .join(' | ')}`,
    );
    return normalizePortfolioData(staticPortfolioData);
  }

  return normalizePortfolioData({
    config: configResult.data as SiteConfig,
    skills: (skillsResult.data ?? []) as Skill[],
    projects: (projectsResult.data ?? []) as Project[],
    experiments: (experimentsResult.data ?? []) as Experiment[],
    sections: (sectionsResult.data ?? []) as PageSection[],
  });
}

export async function getPublishedProjects(): Promise<Project[]> {
  if (!hasSupabaseConfig()) {
    return normalizePortfolioData(staticPortfolioData).projects;
  }

  const { supabase } = await import('./supabase');
  if (!supabase) {
    return normalizePortfolioData(staticPortfolioData).projects;
  }

  const { data, error } = await supabase
    .from('projects')
    .select(projectSelect)
    .eq('is_published', true)
    .order('featured', { ascending: false })
    .order('display_order', { ascending: true });

  if (error) {
    console.warn(
      `Supabase project paths unavailable; using static portfolio data. ${error.message}`,
    );
    return normalizePortfolioData(staticPortfolioData).projects;
  }

  return normalizePortfolioData({
    ...staticPortfolioData,
    projects: (data ?? []) as Project[],
  }).projects;
}

export async function getPublishedExperiments(): Promise<Experiment[]> {
  if (!hasSupabaseConfig()) {
    return normalizePortfolioData(staticPortfolioData).experiments;
  }

  const { supabase } = await import('./supabase');
  if (!supabase) {
    return normalizePortfolioData(staticPortfolioData).experiments;
  }

  const { data, error } = await supabase
    .from('experiments')
    .select('*')
    .eq('is_published', true)
    .order('display_order', { ascending: true })
    .order('created_at', { ascending: false });

  if (error) {
    console.warn(
      `Supabase experiment paths unavailable; using static portfolio data. ${error.message}`,
    );
    return normalizePortfolioData(staticPortfolioData).experiments;
  }

  return normalizePortfolioData({
    ...staticPortfolioData,
    experiments: (data ?? []) as Experiment[],
  }).experiments;
}

export function validatePublishedProject(project: Project): void {
  const missing = [
    ['title', project.title],
    ['slug', project.slug],
    ['description', project.description],
    ['image', getProjectHeroImage(project)],
  ].filter(([, value]) => typeof value !== 'string' || value.trim().length === 0);

  if (missing.length > 0) {
    throw new Error(
      `Published project "${project.id}" is missing: ${missing
        .map(([field]) => field)
        .join(', ')}`,
    );
  }
  if (!/^[a-z0-9]+(?:-[a-z0-9]+)*$/.test(project.slug)) {
    throw new Error(`Published project "${project.title}" has invalid slug "${project.slug}".`);
  }
  if (!Array.isArray(project.tech_stack) || project.tech_stack.length === 0) {
    throw new Error(`Published project "${project.title}" must include tech_stack.`);
  }
  for (const image of project.project_images ?? []) {
    if (!image.image_url?.trim()) {
      throw new Error(`Published project "${project.title}" has a gallery image without image_url.`);
    }
  }
}

export function getProjectHeroImage(project: Project): string {
  const primaryImage = project.image_url?.trim();
  if (primaryImage) {
    return primaryImage;
  }
  return project.project_images?.find((image) => image.image_url.trim().length > 0)?.image_url ?? '';
}

export function validatePublishedExperiment(experiment: Experiment): void {
  const missing = [
    ['title', experiment.title],
    ['slug', experiment.slug],
    ['category', experiment.category],
    ['summary', experiment.summary],
  ].filter(([, value]) => typeof value !== 'string' || value.trim().length === 0);

  if (missing.length > 0) {
    throw new Error(
      `Published experiment "${experiment.id}" is missing: ${missing
        .map(([field]) => field)
        .join(', ')}`,
    );
  }
  if (!/^[a-z0-9]+(?:-[a-z0-9]+)*$/.test(experiment.slug)) {
    throw new Error(
      `Published experiment "${experiment.title}" has invalid slug "${experiment.slug}".`,
    );
  }
  if (!['prototype', 'active', 'archived'].includes(experiment.status)) {
    throw new Error(`Published experiment "${experiment.title}" has invalid status.`);
  }
}

function normalizeProject(project: Project): Project {
  const projectImages = [...(project.project_images ?? [])]
    .sort((left, right) => left.display_order - right.display_order)
    .map((image) => ({
      ...image,
      image_url: resolveAssetUrl(image.image_url),
    }));
  return {
    ...project,
    image_url: project.image_url ? resolveAssetUrl(project.image_url) : project.image_url,
    project_images: projectImages,
  };
}

function validateSiteConfig(config: SiteConfig): void {
  if (!config?.name || !config.headline || !config.bio) {
    throw new Error('site_config.global must include name, headline, and bio.');
  }
  if (
    ![
      'command_center',
      'clean_dossier',
      'terminal_ops',
      'signal_studio',
      'system_forge',
    ].includes(config.design_variant)
  ) {
    throw new Error('site_config.global has an invalid design_variant.');
  }
}

function normalizeSiteConfig(config: SiteConfig): SiteConfig {
  return {
    ...config,
    resume_url: config.resume_url ? resolveAssetUrl(config.resume_url) : config.resume_url,
    theme_json: normalizeThemeConfig(config.theme_json),
  };
}

function normalizePortfolioData(data: PortfolioData): PortfolioData {
  const config = normalizeSiteConfig(data.config);
  const skills = [...data.skills].sort((left, right) => left.display_order - right.display_order);
  const projects = [...data.projects]
    .map(normalizeProject)
    .sort((left, right) => {
      if (left.featured !== right.featured) {
        return left.featured ? -1 : 1;
      }
      if (left.display_order !== right.display_order) {
        return left.display_order - right.display_order;
      }
      return new Date(right.created_at ?? 0).getTime() - new Date(left.created_at ?? 0).getTime();
    });
  const experiments = [...data.experiments].sort(
    (left, right) => left.display_order - right.display_order,
  );
  const sections = [...data.sections].sort((left, right) => {
    if (left.placement !== right.placement) {
      return left.placement.localeCompare(right.placement);
    }
    if (left.display_order !== right.display_order) {
      return left.display_order - right.display_order;
    }
    return new Date(right.created_at ?? 0).getTime() - new Date(left.created_at ?? 0).getTime();
  });

  validateSiteConfig(config);
  for (const item of skills) {
    validateSkill(item);
  }
  for (const item of projects) {
    validatePublishedProject(item);
  }
  for (const item of experiments) {
    validatePublishedExperiment(item);
  }
  for (const item of sections) {
    validatePublishedPageSection(item);
  }

  return { config, projects, skills, experiments, sections };
}

function validateSkill(skill: Skill): void {
  if (!skill.category || !Array.isArray(skill.items) || skill.items.length === 0) {
    throw new Error(`Published skill "${skill.id}" must include category and items.`);
  }
}

function validatePublishedPageSection(section: PageSection): void {
  const missing = [
    ['section_key', section.section_key],
    ['title', section.title],
  ].filter(([, value]) => typeof value !== 'string' || value.trim().length === 0);

  if (missing.length > 0) {
    throw new Error(
      `Published page section "${section.id}" is missing: ${missing
        .map(([field]) => field)
        .join(', ')}`,
    );
  }
  if (!/^[a-z0-9]+(?:-[a-z0-9]+)*$/.test(section.section_key)) {
    throw new Error(`Published page section "${section.title}" has invalid section_key.`);
  }
  if (!['after_hero', 'before_projects', 'before_lab', 'before_skills', 'before_contact'].includes(section.placement)) {
    throw new Error(`Published page section "${section.title}" has invalid placement.`);
  }
  if (!['content_grid', 'metric_strip', 'timeline', 'callout', 'cta'].includes(section.section_type)) {
    throw new Error(`Published page section "${section.title}" has invalid section_type.`);
  }
  validateSectionBlocks(
    section.title,
    readSectionBlocks(section.content_json),
  );
}

function hasSupabaseConfig(): boolean {
  const dataSource = import.meta.env.PORTFOLIO_DATA_SOURCE?.trim().toLowerCase();
  const url = import.meta.env.SUPABASE_URL?.trim();
  const anonKey = import.meta.env.SUPABASE_ANON_KEY?.trim();
  return Boolean(dataSource === 'supabase' && url && anonKey && anonKey !== placeholderSupabaseKey);
}

function resolveAssetUrl(value: string): string {
  const url = value.trim();
  if (
    !url ||
    url.startsWith('http://') ||
    url.startsWith('https://') ||
    url.startsWith('mailto:') ||
    url.startsWith('#') ||
    url.startsWith('/')
  ) {
    return url;
  }

  const baseUrl = import.meta.env.BASE_URL || '/';
  const base = baseUrl.endsWith('/') ? baseUrl : `${baseUrl}/`;
  return `${base}${url.replace(/^\.\//, '')}`;
}
