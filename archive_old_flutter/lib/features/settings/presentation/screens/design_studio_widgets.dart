import 'package:flutter/material.dart';

import '../../domain/entities/site_config.dart';
import '../../domain/entities/site_theme_config.dart';
import '../../domain/entities/site_theme_preset.dart';

class DesignPresetGrid extends StatelessWidget {
  const DesignPresetGrid({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final PublicDesignVariant selected;
  final ValueChanged<SiteThemePreset> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        for (final preset in siteThemePresets)
          SizedBox(
            width: 220,
            child: ChoiceChip(
              selected: preset.variantValue == selected.value,
              label: Text(preset.name),
              avatar: const Icon(Icons.palette_outlined, size: 18),
              onSelected: (_) => onSelected(preset),
            ),
          ),
      ],
    );
  }
}

class ThemeTokenControls extends StatelessWidget {
  const ThemeTokenControls({
    super.key,
    required this.theme,
    required this.onChanged,
  });

  final SiteThemeConfig theme;
  final ValueChanged<SiteThemeConfig> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _TokenField(
          child: _ThemeDropdown(
            label: 'Accent',
            value: theme.accentColor,
            values: ThemeAccentColor.values,
            onChanged: (value) => onChanged(theme.copyWith(accentColor: value)),
          ),
        ),
        _TokenField(
          child: _ThemeDropdown(
            label: 'Background',
            value: theme.backgroundMode,
            values: ThemeBackgroundMode.values,
            onChanged: (value) =>
                onChanged(theme.copyWith(backgroundMode: value)),
          ),
        ),
        _TokenField(
          child: _ThemeDropdown(
            label: 'Surface',
            value: theme.surfaceStyle,
            values: ThemeSurfaceStyle.values,
            onChanged: (value) =>
                onChanged(theme.copyWith(surfaceStyle: value)),
          ),
        ),
        _TokenField(
          child: _ThemeDropdown(
            label: 'Radius',
            value: theme.radius,
            values: ThemeRadius.values,
            onChanged: (value) => onChanged(theme.copyWith(radius: value)),
          ),
        ),
        _TokenField(
          child: _ThemeDropdown(
            label: 'Border',
            value: theme.borderWeight,
            values: ThemeBorderWeight.values,
            onChanged: (value) =>
                onChanged(theme.copyWith(borderWeight: value)),
          ),
        ),
        _TokenField(
          child: _ThemeDropdown(
            label: 'Density',
            value: theme.density,
            values: ThemeDensity.values,
            onChanged: (value) => onChanged(theme.copyWith(density: value)),
          ),
        ),
        _TokenField(
          child: _ThemeDropdown(
            label: 'Motion',
            value: theme.motionIntensity,
            values: ThemeMotionIntensity.values,
            onChanged: (value) =>
                onChanged(theme.copyWith(motionIntensity: value)),
          ),
        ),
        _TokenField(
          child: _ThemeDropdown(
            label: 'Hero',
            value: theme.heroTreatment,
            values: ThemeHeroTreatment.values,
            onChanged: (value) =>
                onChanged(theme.copyWith(heroTreatment: value)),
          ),
        ),
      ],
    );
  }
}

class ThemePreview extends StatelessWidget {
  const ThemePreview({super.key, required this.variant, required this.theme});

  final PublicDesignVariant variant;
  final SiteThemeConfig theme;

  @override
  Widget build(BuildContext context) {
    final accent = _accentColor(theme.accentColor);
    final dark =
        theme.backgroundMode == ThemeBackgroundMode.terminal ||
        variant == PublicDesignVariant.commandCenter;
    final background = dark ? const Color(0xFF080B0C) : const Color(0xFFF4F7F5);
    final foreground = dark ? Colors.white : const Color(0xFF080B0C);
    final borderWidth = switch (theme.borderWeight) {
      ThemeBorderWeight.thin => 1.0,
      ThemeBorderWeight.standard => 1.5,
      ThemeBorderWeight.bold => 2.0,
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        border: Border.all(color: accent, width: borderWidth),
        borderRadius: BorderRadius.circular(_radius(theme.radius)),
      ),
      child: Padding(
        padding: EdgeInsets.all(_padding(theme.density)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              variant.label.toUpperCase(),
              style: TextStyle(
                color: accent,
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Engineering system surface',
              style: TextStyle(
                color: foreground,
                fontSize: 28,
                fontWeight: FontWeight.w900,
                height: 1,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 88,
              decoration: BoxDecoration(
                color: foreground.withValues(alpha: dark ? 0.08 : 0.05),
                border: Border.all(color: foreground.withValues(alpha: 0.18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TokenField extends StatelessWidget {
  const _TokenField({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => SizedBox(width: 220, child: child);
}

class _ThemeDropdown<T extends Enum> extends StatelessWidget {
  const _ThemeDropdown({
    required this.label,
    required this.value,
    required this.values,
    required this.onChanged,
  });

  final String label;
  final T value;
  final List<T> values;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      decoration: InputDecoration(labelText: label),
      items: [
        for (final item in values)
          DropdownMenuItem(value: item, child: Text(_enumLabel(item))),
      ],
      onChanged: (value) {
        if (value != null) {
          onChanged(value);
        }
      },
    );
  }
}

Color _accentColor(ThemeAccentColor value) {
  return switch (value) {
    ThemeAccentColor.signal => const Color(0xFF00836B),
    ThemeAccentColor.cyan => const Color(0xFF21D3BE),
    ThemeAccentColor.amber => const Color(0xFFB86105),
    ThemeAccentColor.oxide => const Color(0xFFA83A2A),
  };
}

double _padding(ThemeDensity density) {
  return switch (density) {
    ThemeDensity.compact => 18,
    ThemeDensity.standard => 24,
    ThemeDensity.spacious => 34,
  };
}

double _radius(ThemeRadius radius) {
  return switch (radius) {
    ThemeRadius.sharp => 0,
    ThemeRadius.compact => 6,
    ThemeRadius.standard => 10,
    ThemeRadius.soft => 16,
  };
}

String _enumLabel(Enum value) {
  final dynamic typedValue = value;
  return typedValue.label as String;
}
