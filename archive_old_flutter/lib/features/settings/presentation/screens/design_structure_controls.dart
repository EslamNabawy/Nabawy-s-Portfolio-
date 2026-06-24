import 'package:flutter/material.dart';

import '../../domain/entities/site_theme_config.dart';

class PortfolioStructureControls extends StatelessWidget {
  const PortfolioStructureControls({
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
        _Field(
          child: _EnumDropdown(
            label: 'Hero Layout',
            value: theme.heroLayout,
            values: ThemeHeroLayout.values,
            onChanged: (value) => onChanged(theme.copyWith(heroLayout: value)),
          ),
        ),
        _Field(
          child: _EnumDropdown(
            label: 'Section Order',
            value: theme.sectionOrder,
            values: ThemeSectionOrder.values,
            onChanged: (value) =>
                onChanged(theme.copyWith(sectionOrder: value)),
          ),
        ),
        _Field(
          child: _EnumDropdown(
            label: 'Project Cards',
            value: theme.projectCardStyle,
            values: ThemeProjectCardStyle.values,
            onChanged: (value) =>
                onChanged(theme.copyWith(projectCardStyle: value)),
          ),
        ),
        SizedBox(
          width: 280,
          child: SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Featured Panel'),
            subtitle: const Text('Show project preview in hero'),
            value: theme.showFeaturedProjectPanel,
            onChanged: (value) =>
                onChanged(theme.copyWith(showFeaturedProjectPanel: value)),
          ),
        ),
      ],
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => SizedBox(width: 280, child: child);
}

class _EnumDropdown<T extends Enum> extends StatelessWidget {
  const _EnumDropdown({
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
      isExpanded: true,
      decoration: InputDecoration(labelText: label),
      items: [
        for (final item in values)
          DropdownMenuItem(
            value: item,
            child: Text(_enumLabel(item), overflow: TextOverflow.ellipsis),
          ),
      ],
      onChanged: (value) {
        if (value != null) {
          onChanged(value);
        }
      },
    );
  }
}

String _enumLabel(Enum value) {
  final dynamic typedValue = value;
  return typedValue.label as String;
}
