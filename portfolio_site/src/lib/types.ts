export type Project = {
  id: string;
  title: string;
  slug: string;
  description: string;
  tech_stack: string[];
  github_url: string | null;
  live_url: string | null;
  image_url: string | null;
  is_published: boolean;
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

export type SiteConfig = {
  id: 'global';
  name: string;
  headline: string;
  bio: string;
  resume_url: string | null;
  github_url: string | null;
  linkedin_url: string | null;
  email: string | null;
  updated_at: string | null;
};
