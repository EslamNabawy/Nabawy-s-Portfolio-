alter table public.site_config
  add column if not exists design_variant text not null default 'command_center';

alter table public.site_config
  drop constraint if exists site_config_design_variant_check;

alter table public.site_config
  add constraint site_config_design_variant_check
  check (design_variant in ('command_center', 'clean_dossier', 'terminal_ops'));

update public.site_config
set design_variant = 'command_center'
where id = 'global'
  and design_variant is null;

notify pgrst, 'reload schema';
