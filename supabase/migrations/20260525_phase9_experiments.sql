create table if not exists public.experiments (
  id uuid primary key default gen_random_uuid(),
  title text not null check (length(trim(title)) > 0),
  slug text not null unique check (slug ~ '^[a-z0-9]+(-[a-z0-9]+)*$'),
  status text not null default 'prototype' check (
    status in ('prototype', 'active', 'archived')
  ),
  category text not null check (length(trim(category)) > 0),
  summary text not null check (length(trim(summary)) > 0),
  writeup_markdown text,
  media_url text,
  github_url text,
  live_url text,
  display_order integer not null default 0,
  is_published boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists experiments_public_order_idx
  on public.experiments(is_published, display_order, created_at desc);

drop trigger if exists set_experiments_updated_at on public.experiments;
create trigger set_experiments_updated_at
before update on public.experiments
for each row
execute function public.set_updated_at();

alter table public.experiments enable row level security;

revoke all on public.experiments from anon, authenticated;
grant select on public.experiments to anon, authenticated;
grant select, insert, update, delete on public.experiments to authenticated;

drop policy if exists "experiments_public_select_published" on public.experiments;
drop policy if exists "experiments_admin_select_all" on public.experiments;
drop policy if exists "experiments_admin_insert" on public.experiments;
drop policy if exists "experiments_admin_update" on public.experiments;
drop policy if exists "experiments_admin_delete" on public.experiments;

create policy "experiments_public_select_published"
on public.experiments
for select
to anon, authenticated
using (is_published = true);

create policy "experiments_admin_select_all"
on public.experiments
for select
to authenticated
using (exists (select 1 from public.admin_users where user_id = (select auth.uid())));

create policy "experiments_admin_insert"
on public.experiments
for insert
to authenticated
with check (exists (select 1 from public.admin_users where user_id = (select auth.uid())));

create policy "experiments_admin_update"
on public.experiments
for update
to authenticated
using (exists (select 1 from public.admin_users where user_id = (select auth.uid())))
with check (exists (select 1 from public.admin_users where user_id = (select auth.uid())));

create policy "experiments_admin_delete"
on public.experiments
for delete
to authenticated
using (exists (select 1 from public.admin_users where user_id = (select auth.uid())));

notify pgrst, 'reload schema';
