export type ProjectImage = {
  id: string;
  project_id: string;
  image_url: string;
  alt_text: string | null;
  display_order: number;
  created_at: string | null;
  updated_at: string | null;
};

export type Project = {
  id: string;
  title: string;
  slug: string;
  description: string;
  short_description: string | null;
  role: string | null;
  impact: string | null;
  architecture_notes: string | null;
  case_study_markdown: string | null;
  tech_stack: string[];
  project_images: ProjectImage[] | null;
  github_url: string | null;
  live_url: string | null;
  image_url: string | null;
  is_published: boolean;
  featured: boolean;
  display_order: number;
  created_at: string | null;
  updated_at: string | null;
};

export type Skill = {
  id: string;
  category: string;
  items: string[];
  display_order: number;
  is_published: boolean;
  updated_at: string | null;
};

export type ExperimentStatus = 'prototype' | 'active' | 'archived';

export type Experiment = {
  id: string;
  title: string;
  slug: string;
  status: ExperimentStatus;
  category: string;
  summary: string;
  writeup_markdown: string | null;
  media_url: string | null;
  github_url: string | null;
  live_url: string | null;
  display_order: number;
  is_published: boolean;
  created_at: string | null;
  updated_at: string | null;
};

export type PublicDesignVariant =
  | 'command_center'
  | 'clean_dossier'
  | 'terminal_ops'
  | 'signal_studio'
  | 'system_forge';

export type SiteThemeConfig = {
  accentColor?: 'signal' | 'cyan' | 'amber' | 'oxide';
  backgroundMode?: 'grid' | 'clean' | 'terminal' | 'studio' | 'forge';
  surfaceStyle?: 'flat' | 'panel' | 'glass' | 'elevated';
  radius?: 'sharp' | 'compact' | 'standard' | 'soft';
  borderWeight?: 'thin' | 'standard' | 'bold';
  density?: 'compact' | 'standard' | 'spacious';
  motionIntensity?: 'none' | 'reduced' | 'standard' | 'expressive';
  heroTreatment?: 'console' | 'dossier' | 'terminal' | 'studio' | 'forge';
};

export type SiteConfig = {
  id: 'global';
  name: string;
  headline: string;
  bio: string;
  resume_url: string | null;
  github_url: string | null;
  linkedin_url: string | null;
  email: string | null;
  design_variant: PublicDesignVariant;
  theme_json: SiteThemeConfig;
  updated_at: string | null;
};

export type PageSectionPlacement =
  | 'after_hero'
  | 'before_projects'
  | 'before_lab'
  | 'before_skills'
  | 'before_contact';

export type PageSectionType =
  | 'content_grid'
  | 'metric_strip'
  | 'timeline'
  | 'callout'
  | 'cta';

export type PageSectionLayout = 'stack' | 'split' | 'grid' | 'rail' | 'banner';
export type PageSectionTone = 'panel' | 'ink' | 'signal' | 'studio' | 'minimal';
export type PageSectionDensity = 'compact' | 'standard' | 'spacious';
export type PageSectionAlignment = 'left' | 'center';

export type SectionBlockType =
  | 'heroText'
  | 'cardGrid'
  | 'metricStrip'
  | 'timeline'
  | 'media'
  | 'ctaRow'
  | 'callout'
  | 'architecturePanel';

export type SectionBlockItem = {
  label?: string;
  title?: string;
  copy?: string;
  url?: string;
};

export type SectionBlockAction = {
  label?: string;
  url?: string;
};

export type SectionBlock = {
  type: SectionBlockType;
  label?: string;
  title?: string;
  copy?: string;
  url?: string;
  mediaUrl?: string;
  altText?: string;
  caption?: string;
  items?: SectionBlockItem[];
  actions?: SectionBlockAction[];
};

export type PageSection = {
  id: string;
  section_key: string;
  title: string;
  eyebrow: string | null;
  body: string | null;
  placement: PageSectionPlacement;
  section_type: PageSectionType;
  layout: PageSectionLayout;
  tone: PageSectionTone;
  density: PageSectionDensity;
  alignment: PageSectionAlignment;
  content_json: Record<string, unknown>;
  design_json: Record<string, unknown>;
  display_order: number;
  is_published: boolean;
  created_at: string | null;
  updated_at: string | null;
};
