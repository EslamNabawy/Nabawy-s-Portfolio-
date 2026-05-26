import 'site_theme_config.dart';

final class SiteThemePreset {
  const SiteThemePreset({
    required this.variantValue,
    required this.name,
    required this.description,
    required this.config,
  });

  final String variantValue;
  final String name;
  final String description;
  final SiteThemeConfig config;
}

const siteThemePresets = <SiteThemePreset>[
  SiteThemePreset(
    variantValue: 'command_center',
    name: 'Command Center',
    description: 'Dark tactical console with grid logic and strong contrast.',
    config: SiteThemeConfig(
      accentColor: ThemeAccentColor.signal,
      backgroundMode: ThemeBackgroundMode.grid,
      surfaceStyle: ThemeSurfaceStyle.glass,
      radius: ThemeRadius.compact,
      borderWeight: ThemeBorderWeight.standard,
      density: ThemeDensity.standard,
      motionIntensity: ThemeMotionIntensity.standard,
      heroTreatment: ThemeHeroTreatment.console,
      heroLayout: ThemeHeroLayout.split,
      sectionOrder: ThemeSectionOrder.projectsFirst,
      projectCardStyle: ThemeProjectCardStyle.visual,
    ),
  ),
  SiteThemePreset(
    variantValue: 'clean_dossier',
    name: 'Clean Dossier',
    description: 'Bright recruiter-focused case-file surface.',
    config: SiteThemeConfig(
      accentColor: ThemeAccentColor.signal,
      backgroundMode: ThemeBackgroundMode.clean,
      surfaceStyle: ThemeSurfaceStyle.flat,
      radius: ThemeRadius.compact,
      borderWeight: ThemeBorderWeight.thin,
      density: ThemeDensity.standard,
      motionIntensity: ThemeMotionIntensity.reduced,
      heroTreatment: ThemeHeroTreatment.dossier,
      heroLayout: ThemeHeroLayout.statement,
      sectionOrder: ThemeSectionOrder.recruiterFirst,
      projectCardStyle: ThemeProjectCardStyle.compact,
      showFeaturedProjectPanel: false,
    ),
  ),
  SiteThemePreset(
    variantValue: 'terminal_ops',
    name: 'Terminal Ops',
    description: 'High-contrast operations terminal with compact density.',
    config: SiteThemeConfig(
      accentColor: ThemeAccentColor.cyan,
      backgroundMode: ThemeBackgroundMode.terminal,
      surfaceStyle: ThemeSurfaceStyle.panel,
      radius: ThemeRadius.sharp,
      borderWeight: ThemeBorderWeight.standard,
      density: ThemeDensity.compact,
      motionIntensity: ThemeMotionIntensity.reduced,
      heroTreatment: ThemeHeroTreatment.terminal,
      heroLayout: ThemeHeroLayout.split,
      sectionOrder: ThemeSectionOrder.recruiterFirst,
      projectCardStyle: ThemeProjectCardStyle.proof,
    ),
  ),
  SiteThemePreset(
    variantValue: 'signal_studio',
    name: 'Signal Studio',
    description: 'Premium bright studio with bold signal accents.',
    config: SiteThemeConfig(
      accentColor: ThemeAccentColor.cyan,
      backgroundMode: ThemeBackgroundMode.studio,
      surfaceStyle: ThemeSurfaceStyle.elevated,
      radius: ThemeRadius.standard,
      borderWeight: ThemeBorderWeight.thin,
      density: ThemeDensity.spacious,
      motionIntensity: ThemeMotionIntensity.standard,
      heroTreatment: ThemeHeroTreatment.studio,
      heroLayout: ThemeHeroLayout.split,
      sectionOrder: ThemeSectionOrder.projectsFirst,
      projectCardStyle: ThemeProjectCardStyle.visual,
    ),
  ),
  SiteThemePreset(
    variantValue: 'system_forge',
    name: 'System Forge',
    description: 'Sharper industrial engineering surface with amber telemetry.',
    config: SiteThemeConfig(
      accentColor: ThemeAccentColor.amber,
      backgroundMode: ThemeBackgroundMode.forge,
      surfaceStyle: ThemeSurfaceStyle.panel,
      radius: ThemeRadius.sharp,
      borderWeight: ThemeBorderWeight.bold,
      density: ThemeDensity.compact,
      motionIntensity: ThemeMotionIntensity.standard,
      heroTreatment: ThemeHeroTreatment.forge,
      heroLayout: ThemeHeroLayout.compact,
      sectionOrder: ThemeSectionOrder.projectsFirst,
      projectCardStyle: ThemeProjectCardStyle.proof,
    ),
  ),
];
