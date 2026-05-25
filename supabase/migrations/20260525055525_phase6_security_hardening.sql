create table if not exists public.admin_users (
  user_id uuid primary key references auth.users(id) on delete cascade,
  created_at timestamptz not null default now()
);
insert into public.admin_users (user_id)
values ('57260064-9aaf-44e2-8562-788701a1040a')
on conflict (user_id) do nothing;
alter table public.admin_users enable row level security;
revoke all on public.admin_users from anon, authenticated;
grant select on public.admin_users to authenticated;
drop policy if exists "admin_users_self_select" on public.admin_users;
create policy "admin_users_self_select"
on public.admin_users
for select
to authenticated
using (user_id = (select auth.uid()));
create or replace function public.set_updated_at()
returns trigger
language plpgsql
set search_path = public
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;
do $$
begin
  if to_regprocedure('public.rls_auto_enable()') is not null then
    execute 'revoke execute on function public.rls_auto_enable() from public, anon, authenticated';
  end if;
end;
$$;
alter table public.projects enable row level security;
alter table public.skills enable row level security;
alter table public.site_config enable row level security;
alter table public.publish_log enable row level security;
alter table public.project_images enable row level security;
revoke all on public.projects from anon, authenticated;
revoke all on public.skills from anon, authenticated;
revoke all on public.site_config from anon, authenticated;
revoke all on public.publish_log from anon, authenticated;
revoke all on public.project_images from anon, authenticated;
grant select on public.projects to anon, authenticated;
grant select on public.skills to anon, authenticated;
grant select on public.site_config to anon, authenticated;
grant select on public.project_images to anon, authenticated;
grant select, insert, update, delete on public.projects to authenticated;
grant select, insert, update, delete on public.skills to authenticated;
grant select, insert, update, delete on public.site_config to authenticated;
grant select, insert, update, delete on public.publish_log to authenticated;
grant select, insert, update, delete on public.project_images to authenticated;
drop policy if exists "projects_public_select_published" on public.projects;
drop policy if exists "projects_authenticated_select_all" on public.projects;
drop policy if exists "projects_authenticated_insert" on public.projects;
drop policy if exists "projects_authenticated_update" on public.projects;
drop policy if exists "projects_authenticated_delete" on public.projects;
create policy "projects_public_select_published"
on public.projects
for select
to anon, authenticated
using (is_published = true);
create policy "projects_admin_select_all"
on public.projects
for select
to authenticated
using (exists (select 1 from public.admin_users where user_id = (select auth.uid())));
create policy "projects_admin_insert"
on public.projects
for insert
to authenticated
with check (exists (select 1 from public.admin_users where user_id = (select auth.uid())));
create policy "projects_admin_update"
on public.projects
for update
to authenticated
using (exists (select 1 from public.admin_users where user_id = (select auth.uid())))
with check (exists (select 1 from public.admin_users where user_id = (select auth.uid())));
create policy "projects_admin_delete"
on public.projects
for delete
to authenticated
using (exists (select 1 from public.admin_users where user_id = (select auth.uid())));
drop policy if exists "skills_public_select_published" on public.skills;
drop policy if exists "skills_authenticated_select_all" on public.skills;
drop policy if exists "skills_authenticated_insert" on public.skills;
drop policy if exists "skills_authenticated_update" on public.skills;
drop policy if exists "skills_authenticated_delete" on public.skills;
create policy "skills_public_select_published"
on public.skills
for select
to anon, authenticated
using (is_published = true);
create policy "skills_admin_select_all"
on public.skills
for select
to authenticated
using (exists (select 1 from public.admin_users where user_id = (select auth.uid())));
create policy "skills_admin_insert"
on public.skills
for insert
to authenticated
with check (exists (select 1 from public.admin_users where user_id = (select auth.uid())));
create policy "skills_admin_update"
on public.skills
for update
to authenticated
using (exists (select 1 from public.admin_users where user_id = (select auth.uid())))
with check (exists (select 1 from public.admin_users where user_id = (select auth.uid())));
create policy "skills_admin_delete"
on public.skills
for delete
to authenticated
using (exists (select 1 from public.admin_users where user_id = (select auth.uid())));
drop policy if exists "site_config_public_select" on public.site_config;
drop policy if exists "site_config_authenticated_select_all" on public.site_config;
drop policy if exists "site_config_authenticated_insert" on public.site_config;
drop policy if exists "site_config_authenticated_update" on public.site_config;
drop policy if exists "site_config_authenticated_delete" on public.site_config;
create policy "site_config_public_select"
on public.site_config
for select
to anon, authenticated
using (true);
create policy "site_config_admin_insert"
on public.site_config
for insert
to authenticated
with check (
  id = 'global'
  and exists (select 1 from public.admin_users where user_id = (select auth.uid()))
);
create policy "site_config_admin_update"
on public.site_config
for update
to authenticated
using (exists (select 1 from public.admin_users where user_id = (select auth.uid())))
with check (
  id = 'global'
  and exists (select 1 from public.admin_users where user_id = (select auth.uid()))
);
create policy "site_config_admin_delete"
on public.site_config
for delete
to authenticated
using (exists (select 1 from public.admin_users where user_id = (select auth.uid())));
drop policy if exists "publish_log_authenticated_select_all" on public.publish_log;
drop policy if exists "publish_log_authenticated_insert" on public.publish_log;
drop policy if exists "publish_log_authenticated_update" on public.publish_log;
drop policy if exists "publish_log_authenticated_delete" on public.publish_log;
create policy "publish_log_admin_select_all"
on public.publish_log
for select
to authenticated
using (exists (select 1 from public.admin_users where user_id = (select auth.uid())));
create policy "publish_log_admin_insert"
on public.publish_log
for insert
to authenticated
with check (exists (select 1 from public.admin_users where user_id = (select auth.uid())));
create policy "publish_log_admin_update"
on public.publish_log
for update
to authenticated
using (exists (select 1 from public.admin_users where user_id = (select auth.uid())))
with check (exists (select 1 from public.admin_users where user_id = (select auth.uid())));
create policy "publish_log_admin_delete"
on public.publish_log
for delete
to authenticated
using (exists (select 1 from public.admin_users where user_id = (select auth.uid())));
drop policy if exists "project_images_public_select_published_project" on public.project_images;
drop policy if exists "project_images_authenticated_select_all" on public.project_images;
drop policy if exists "project_images_authenticated_insert" on public.project_images;
drop policy if exists "project_images_authenticated_update" on public.project_images;
drop policy if exists "project_images_authenticated_delete" on public.project_images;
drop policy if exists "project_images_public_read_published" on public.project_images;
drop policy if exists "project_images_admin_select_all" on public.project_images;
drop policy if exists "project_images_admin_insert_all" on public.project_images;
drop policy if exists "project_images_admin_update_all" on public.project_images;
drop policy if exists "project_images_admin_delete_all" on public.project_images;
create policy "project_images_public_select_published_project"
on public.project_images
for select
to anon, authenticated
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
using (exists (select 1 from public.admin_users where user_id = (select auth.uid())));
create policy "project_images_admin_insert"
on public.project_images
for insert
to authenticated
with check (exists (select 1 from public.admin_users where user_id = (select auth.uid())));
create policy "project_images_admin_update"
on public.project_images
for update
to authenticated
using (exists (select 1 from public.admin_users where user_id = (select auth.uid())))
with check (exists (select 1 from public.admin_users where user_id = (select auth.uid())));
create policy "project_images_admin_delete"
on public.project_images
for delete
to authenticated
using (exists (select 1 from public.admin_users where user_id = (select auth.uid())));
update storage.buckets
set
  public = true,
  file_size_limit = 10485760,
  allowed_mime_types = array[
    'image/jpeg',
    'image/png',
    'image/webp',
    'image/avif',
    'application/pdf'
  ]
where id = 'portfolio-assets';
drop policy if exists "portfolio_assets_public_read" on storage.objects;
drop policy if exists "portfolio_assets_authenticated_insert" on storage.objects;
drop policy if exists "portfolio_assets_authenticated_update" on storage.objects;
drop policy if exists "portfolio_assets_authenticated_delete" on storage.objects;
drop policy if exists "portfolio_assets_admin_select" on storage.objects;
drop policy if exists "portfolio_assets_admin_insert" on storage.objects;
drop policy if exists "portfolio_assets_admin_update" on storage.objects;
drop policy if exists "portfolio_assets_admin_delete" on storage.objects;
create policy "portfolio_assets_admin_select"
on storage.objects
for select
to authenticated
using (
  bucket_id = 'portfolio-assets'
  and exists (select 1 from public.admin_users where user_id = (select auth.uid()))
);
create policy "portfolio_assets_admin_insert"
on storage.objects
for insert
to authenticated
with check (
  bucket_id = 'portfolio-assets'
  and exists (select 1 from public.admin_users where user_id = (select auth.uid()))
);
create policy "portfolio_assets_admin_update"
on storage.objects
for update
to authenticated
using (
  bucket_id = 'portfolio-assets'
  and exists (select 1 from public.admin_users where user_id = (select auth.uid()))
)
with check (
  bucket_id = 'portfolio-assets'
  and exists (select 1 from public.admin_users where user_id = (select auth.uid()))
);
create policy "portfolio_assets_admin_delete"
on storage.objects
for delete
to authenticated
using (
  bucket_id = 'portfolio-assets'
  and exists (select 1 from public.admin_users where user_id = (select auth.uid()))
);
notify pgrst, 'reload schema';
