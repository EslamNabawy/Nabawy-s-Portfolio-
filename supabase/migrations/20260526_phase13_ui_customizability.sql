alter table public.site_config
  add column if not exists theme_json jsonb not null default '{}'::jsonb;

alter table public.site_config
  drop constraint if exists site_config_theme_json_object_check;

alter table public.site_config
  add constraint site_config_theme_json_object_check
  check (jsonb_typeof(theme_json) = 'object');

alter table public.site_config
  drop constraint if exists site_config_design_variant_check;

alter table public.site_config
  add constraint site_config_design_variant_check
  check (
    design_variant in (
      'command_center',
      'clean_dossier',
      'terminal_ops',
      'signal_studio',
      'system_forge'
    )
  );

update public.site_config
set theme_json = jsonb_build_object(
  'accentColor', 'signal',
  'backgroundMode', 'grid',
  'surfaceStyle', 'glass',
  'radius', 'compact',
  'borderWeight', 'standard',
  'density', 'standard',
  'motionIntensity', 'standard',
  'heroTreatment', 'console'
)
where id = 'global'
  and theme_json = '{}'::jsonb;

notify pgrst, 'reload schema';
