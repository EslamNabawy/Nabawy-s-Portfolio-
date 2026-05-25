alter table public.projects
  add column if not exists short_description text,
  add column if not exists role text,
  add column if not exists impact text,
  add column if not exists architecture_notes text,
  add column if not exists case_study_markdown text,
  add column if not exists featured boolean not null default false;

create table if not exists public.project_images (
  id uuid primary key default gen_random_uuid(),
  project_id uuid not null references public.projects(id) on delete cascade,
  image_url text not null check (length(trim(image_url)) > 0),
  alt_text text,
  display_order integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists project_images_project_id_order_idx
  on public.project_images(project_id, display_order);

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists set_project_images_updated_at on public.project_images;
create trigger set_project_images_updated_at
before update on public.project_images
for each row
execute function public.set_updated_at();

insert into public.project_images (project_id, image_url, alt_text, display_order)
select
  projects.id,
  projects.image_url,
  projects.title || ' primary screenshot',
  0
from public.projects
where projects.image_url is not null
  and length(trim(projects.image_url)) > 0
  and not exists (
    select 1
    from public.project_images
    where project_images.project_id = projects.id
      and project_images.image_url = projects.image_url
  );

alter table public.project_images enable row level security;

drop policy if exists "project_images_public_read_published" on public.project_images;
drop policy if exists "project_images_admin_select_all" on public.project_images;
drop policy if exists "project_images_admin_insert_all" on public.project_images;
drop policy if exists "project_images_admin_update_all" on public.project_images;
drop policy if exists "project_images_admin_delete_all" on public.project_images;

create policy "project_images_public_read_published"
on public.project_images
for select
to anon
using (
  exists (
    select 1
    from public.projects
    where projects.id = project_images.project_id
      and projects.is_published = true
  )
);

create policy "project_images_admin_select_all"
on public.project_images
for select
to authenticated
using (true);

create policy "project_images_admin_insert_all"
on public.project_images
for insert
to authenticated
with check (true);

create policy "project_images_admin_update_all"
on public.project_images
for update
to authenticated
using (true)
with check (true);

create policy "project_images_admin_delete_all"
on public.project_images
for delete
to authenticated
using (true);

grant select on public.project_images to anon;
grant select, insert, update, delete on public.project_images to authenticated;

notify pgrst, 'reload schema';
