create table if not exists public.page_sections (
  id uuid primary key default gen_random_uuid(),
  section_key text not null unique check (section_key ~ '^[a-z0-9]+(-[a-z0-9]+)*$'),
  title text not null check (length(trim(title)) > 0),
  eyebrow text,
  body text,
  placement text not null default 'after_hero' check (
    placement in (
      'after_hero',
      'before_projects',
      'before_lab',
      'before_skills',
      'before_contact'
    )
  ),
  section_type text not null default 'content_grid' check (
    section_type in (
      'content_grid',
      'metric_strip',
      'timeline',
      'callout',
      'cta'
    )
  ),
  layout text not null default 'stack' check (
    layout in ('stack', 'split', 'grid', 'rail', 'banner')
  ),
  tone text not null default 'panel' check (
    tone in ('panel', 'ink', 'signal', 'studio', 'minimal')
  ),
  density text not null default 'standard' check (
    density in ('compact', 'standard', 'spacious')
  ),
  alignment text not null default 'left' check (alignment in ('left', 'center')),
  content_json jsonb not null default '{}' check (jsonb_typeof(content_json) = 'object'),
  design_json jsonb not null default '{}' check (jsonb_typeof(design_json) = 'object'),
  display_order integer not null default 0,
  is_published boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists page_sections_public_order_idx
  on public.page_sections(is_published, placement, display_order, created_at desc);

drop trigger if exists set_page_sections_updated_at on public.page_sections;
create trigger set_page_sections_updated_at
before update on public.page_sections
for each row
execute function public.set_updated_at();

alter table public.page_sections enable row level security;

revoke all on public.page_sections from anon, authenticated;
grant select on public.page_sections to anon, authenticated;
grant select, insert, update, delete on public.page_sections to authenticated;

drop policy if exists "page_sections_public_select_published" on public.page_sections;
drop policy if exists "page_sections_admin_select_all" on public.page_sections;
drop policy if exists "page_sections_admin_insert" on public.page_sections;
drop policy if exists "page_sections_admin_update" on public.page_sections;
drop policy if exists "page_sections_admin_delete" on public.page_sections;

create policy "page_sections_public_select_published"
on public.page_sections
for select
to anon, authenticated
using (is_published = true);

create policy "page_sections_admin_select_all"
on public.page_sections
for select
to authenticated
using (exists (select 1 from public.admin_users where user_id = (select auth.uid())));

create policy "page_sections_admin_insert"
on public.page_sections
for insert
to authenticated
with check (exists (select 1 from public.admin_users where user_id = (select auth.uid())));

create policy "page_sections_admin_update"
on public.page_sections
for update
to authenticated
using (exists (select 1 from public.admin_users where user_id = (select auth.uid())))
with check (exists (select 1 from public.admin_users where user_id = (select auth.uid())));

create policy "page_sections_admin_delete"
on public.page_sections
for delete
to authenticated
using (exists (select 1 from public.admin_users where user_id = (select auth.uid())));

notify pgrst, 'reload schema';
