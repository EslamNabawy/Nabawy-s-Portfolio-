import '../../../../core/utils/json_readers.dart';

enum ThemeAccentColor {
  signal('signal', 'Signal Green'),
  cyan('cyan', 'System Cyan'),
  amber('amber', 'Amber'),
  oxide('oxide', 'Oxide Red');

  const ThemeAccentColor(this.value, this.label);

  final String value;
  final String label;
}

enum ThemeBackgroundMode {
  grid('grid', 'Grid'),
  clean('clean', 'Clean'),
  terminal('terminal', 'Terminal'),
  studio('studio', 'Studio'),
  forge('forge', 'System Forge');

  const ThemeBackgroundMode(this.value, this.label);

  final String value;
  final String label;
}

enum ThemeSurfaceStyle {
  flat('flat', 'Flat'),
  panel('panel', 'Panel'),
  glass('glass', 'Glass'),
  elevated('elevated', 'Elevated');

  const ThemeSurfaceStyle(this.value, this.label);

  final String value;
  final String label;
}

enum ThemeRadius {
  sharp('sharp', 'Sharp'),
  compact('compact', 'Compact'),
  standard('standard', 'Standard'),
  soft('soft', 'Soft');

  const ThemeRadius(this.value, this.label);

  final String value;
  final String label;
}

enum ThemeBorderWeight {
  thin('thin', 'Thin'),
  standard('standard', 'Standard'),
  bold('bold', 'Bold');

  const ThemeBorderWeight(this.value, this.label);

  final String value;
  final String label;
}

enum ThemeDensity {
  compact('compact', 'Compact'),
  standard('standard', 'Standard'),
  spacious('spacious', 'Spacious');

  const ThemeDensity(this.value, this.label);

  final String value;
  final String label;
}

enum ThemeMotionIntensity {
  none('none', 'None'),
  reduced('reduced', 'Reduced'),
  standard('standard', 'Standard'),
  expressive('expressive', 'Expressive');

  const ThemeMotionIntensity(this.value, this.label);

  final String value;
  final String label;
}

enum ThemeHeroTreatment {
  console('console', 'Console'),
  dossier('dossier', 'Dossier'),
  terminal('terminal', 'Terminal'),
  studio('studio', 'Studio'),
  forge('forge', 'System Forge');

  const ThemeHeroTreatment(this.value, this.label);

  final String value;
  final String label;
}

final class SiteThemeConfig {
  const SiteThemeConfig({
    this.accentColor = ThemeAccentColor.signal,
    this.backgroundMode = ThemeBackgroundMode.grid,
    this.surfaceStyle = ThemeSurfaceStyle.panel,
    this.radius = ThemeRadius.compact,
    this.borderWeight = ThemeBorderWeight.standard,
    this.density = ThemeDensity.standard,
    this.motionIntensity = ThemeMotionIntensity.standard,
    this.heroTreatment = ThemeHeroTreatment.console,
  });

  final ThemeAccentColor accentColor;
  final ThemeBackgroundMode backgroundMode;
  final ThemeSurfaceStyle surfaceStyle;
  final ThemeRadius radius;
  final ThemeBorderWeight borderWeight;
  final ThemeDensity density;
  final ThemeMotionIntensity motionIntensity;
  final ThemeHeroTreatment heroTreatment;

  factory SiteThemeConfig.fromJson(JsonMap json) {
    return SiteThemeConfig(
      accentColor: _readOption(
        json,
        'accentColor',
        ThemeAccentColor.values,
        ThemeAccentColor.signal,
      ),
      backgroundMode: _readOption(
        json,
        'backgroundMode',
        ThemeBackgroundMode.values,
        ThemeBackgroundMode.grid,
      ),
      surfaceStyle: _readOption(
        json,
        'surfaceStyle',
        ThemeSurfaceStyle.values,
        ThemeSurfaceStyle.panel,
      ),
      radius: _readOption(
        json,
        'radius',
        ThemeRadius.values,
        ThemeRadius.compact,
      ),
      borderWeight: _readOption(
        json,
        'borderWeight',
        ThemeBorderWeight.values,
        ThemeBorderWeight.standard,
      ),
      density: _readOption(
        json,
        'density',
        ThemeDensity.values,
        ThemeDensity.standard,
      ),
      motionIntensity: _readOption(
        json,
        'motionIntensity',
        ThemeMotionIntensity.values,
        ThemeMotionIntensity.standard,
      ),
      heroTreatment: _readOption(
        json,
        'heroTreatment',
        ThemeHeroTreatment.values,
        ThemeHeroTreatment.console,
      ),
    );
  }

  JsonMap toJson() {
    return <String, Object?>{
      'accentColor': accentColor.value,
      'backgroundMode': backgroundMode.value,
      'surfaceStyle': surfaceStyle.value,
      'radius': radius.value,
      'borderWeight': borderWeight.value,
      'density': density.value,
      'motionIntensity': motionIntensity.value,
      'heroTreatment': heroTreatment.value,
    };
  }

  SiteThemeConfig copyWith({
    ThemeAccentColor? accentColor,
    ThemeBackgroundMode? backgroundMode,
    ThemeSurfaceStyle? surfaceStyle,
    ThemeRadius? radius,
    ThemeBorderWeight? borderWeight,
    ThemeDensity? density,
    ThemeMotionIntensity? motionIntensity,
    ThemeHeroTreatment? heroTreatment,
  }) {
    return SiteThemeConfig(
      accentColor: accentColor ?? this.accentColor,
      backgroundMode: backgroundMode ?? this.backgroundMode,
      surfaceStyle: surfaceStyle ?? this.surfaceStyle,
      radius: radius ?? this.radius,
      borderWeight: borderWeight ?? this.borderWeight,
      density: density ?? this.density,
      motionIntensity: motionIntensity ?? this.motionIntensity,
      heroTreatment: heroTreatment ?? this.heroTreatment,
    );
  }
}

T _readOption<T extends Enum>(
  JsonMap json,
  String key,
  List<T> values,
  T defaultValue,
) {
  final value = json[key];
  if (value == null) {
    return defaultValue;
  }
  if (value is! String) {
    throw FormatException('Theme token "$key" must be a string.');
  }
  return values.firstWhere(
    (item) => _enumValue(item) == value,
    orElse: () =>
        throw FormatException('Unknown theme token "$key": "$value".'),
  );
}

String _enumValue(Enum value) {
  final dynamic typedValue = value;
  return typedValue.value as String;
}
