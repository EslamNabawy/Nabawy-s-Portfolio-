import { supabase } from './supabase';
import type { Project, SiteConfig, Skill } from './types';

const projectSelect = '*, project_images(*)';

export type PortfolioData = {
  config: SiteConfig;
  projects: Project[];
  skills: Skill[];
};

export async function getPortfolioData(): Promise<PortfolioData> {
  const [configResult, skillsResult, projectsResult] = await Promise.all([
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

  const config = configResult.data as SiteConfig;
  const skills = (skillsResult.data ?? []) as Skill[];
  const projects = ((projectsResult.data ?? []) as Project[]).map(normalizeProject);

  validateSiteConfig(config);
  for (const skill of skills) {
    validateSkill(skill);
  }
  for (const project of projects) {
    validatePublishedProject(project);
  }

  return { config, projects, skills };
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
}

function validateSkill(skill: Skill): void {
  if (!skill.category || !Array.isArray(skill.items) || skill.items.length === 0) {
    throw new Error(`Published skill "${skill.id}" must include category and items.`);
  }
}
