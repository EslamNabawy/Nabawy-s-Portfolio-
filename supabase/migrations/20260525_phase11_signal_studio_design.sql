alter table public.site_config
  drop constraint if exists site_config_design_variant_check;

alter table public.site_config
  add constraint site_config_design_variant_check
  check (
    design_variant in (
      'command_center',
      'clean_dossier',
      'terminal_ops',
      'signal_studio'
    )
  );

notify pgrst, 'reload schema';
