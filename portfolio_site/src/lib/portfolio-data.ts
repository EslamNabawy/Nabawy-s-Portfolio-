import { supabase } from './supabase';
import type { Experiment, PageSection, Project, SiteConfig, Skill } from './types';
import { readSectionBlocks, validateSectionBlocks } from './section-blocks';
import { normalizeThemeConfig } from './theme';

const projectSelect = '*, project_images(*)';

export type PortfolioData = {
  config: SiteConfig;
  projects: Project[];
  skills: Skill[];
  experiments: Experiment[];
  sections: PageSection[];
};

export async function getPortfolioData(): Promise<PortfolioData> {
  const [configResult, skillsResult, projectsResult, experimentsResult, sectionsResult] = await Promise.all([
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

  if (configResult.error) {
    throw new Error(`Failed to load site_config.global: ${configResult.error.message}`);
  }
  if (skillsResult.error) {
    throw new Error(`Failed to load published skills: ${skillsResult.error.message}`);
  }
  if (projectsResult.error) {
    throw new Error(`Failed to load published projects: ${projectsResult.error.message}`);
  }
  if (experimentsResult.error) {
    throw new Error(`Failed to load published experiments: ${experimentsResult.error.message}`);
  }
  if (sectionsResult.error) {
    throw new Error(`Failed to load published page sections: ${sectionsResult.error.message}`);
  }

  const config = normalizeSiteConfig(configResult.data as SiteConfig);
  const skills = (skillsResult.data ?? []) as Skill[];
  const projects = ((projectsResult.data ?? []) as Project[]).map(normalizeProject);
  const experiments = (experimentsResult.data ?? []) as Experiment[];
  const sections = (sectionsResult.data ?? []) as PageSection[];

  validateSiteConfig(config);
  for (const skill of skills) {
    validateSkill(skill);
  }
  for (const project of projects) {
    validatePublishedProject(project);
  }
  for (const experiment of experiments) {
    validatePublishedExperiment(experiment);
  }
  for (const section of sections) {
    validatePublishedPageSection(section);
  }

  return { config, projects, skills, experiments, sections };
}

export async function getPublishedProjects(): Promise<Project[]> {
  const { data, error } = await supabase
    .from('projects')
    .select(projectSelect)
    .eq('is_published', true)
    .order('featured', { ascending: false })
    .order('display_order', { ascending: true });

  if (error) {
    throw new Error(`Failed to load project static paths: ${error.message}`);
  }

  const projects = ((data ?? []) as Project[]).map(normalizeProject);
  for (const project of projects) {
    validatePublishedProject(project);
  }
  return projects;
}

export async function getPublishedExperiments(): Promise<Experiment[]> {
  const { data, error } = await supabase
    .from('experiments')
    .select('*')
    .eq('is_published', true)
    .order('display_order', { ascending: true })
    .order('created_at', { ascending: false });

  if (error) {
    throw new Error(`Failed to load experiment static paths: ${error.message}`);
  }

  const experiments = (data ?? []) as Experiment[];
  for (const experiment of experiments) {
    validatePublishedExperiment(experiment);
  }
  return experiments;
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
  const projectImages = [...(project.project_images ?? [])].sort(
    (left, right) => left.display_order - right.display_order,
  );
  return {
    ...project,
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
    theme_json: normalizeThemeConfig(config.theme_json),
  };
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
