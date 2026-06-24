import 'package:flutter/material.dart';

import '../../../projects/presentation/screens/project_form_support.dart';
import '../../domain/entities/page_section.dart';
import 'page_section_form_support.dart';

class PageSectionIdentitySection extends StatelessWidget {
  const PageSectionIdentitySection({
    super.key,
    required this.title,
    required this.sectionKey,
    required this.eyebrow,
    required this.body,
    required this.displayOrder,
    required this.isPublished,
    required this.onTitleChanged,
    required this.onChanged,
    required this.onPublishedChanged,
  });

  final TextEditingController title;
  final TextEditingController sectionKey;
  final TextEditingController eyebrow;
  final TextEditingController body;
  final TextEditingController displayOrder;
  final bool isPublished;
  final ValueChanged<String> onTitleChanged;
  final VoidCallback onChanged;
  final ValueChanged<bool> onPublishedChanged;

  @override
  Widget build(BuildContext context) {
    return ProjectFormSection(
      title: 'Section Content',
      children: [
        TextFormField(
          controller: title,
          decoration: const InputDecoration(labelText: 'Title'),
          validator: requiredField('Title'),
          onChanged: (value) {
            onTitleChanged(value);
            onChanged();
          },
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: sectionKey,
          decoration: const InputDecoration(
            labelText: 'Section Key',
            helperText: 'Stable lowercase identifier used for anchors/CMS.',
          ),
          validator: validateSlug,
          onChanged: (_) => onChanged(),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: eyebrow,
          decoration: const InputDecoration(labelText: 'Eyebrow'),
          onChanged: (_) => onChanged(),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: body,
          decoration: const InputDecoration(
            labelText: 'Body Copy',
            alignLabelWithHint: true,
          ),
          minLines: 3,
          maxLines: 7,
          onChanged: (_) => onChanged(),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: displayOrder,
          decoration: const InputDecoration(labelText: 'Display Order'),
          keyboardType: TextInputType.number,
          validator: validateDisplayOrder,
          onChanged: (_) => onChanged(),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: isPublished,
          title: const Text('Published'),
          subtitle: const Text('Visible on the next static site build.'),
          onChanged: onPublishedChanged,
        ),
      ],
    );
  }
}

class PageSectionDesignSection extends StatelessWidget {
  const PageSectionDesignSection({
    super.key,
    required this.placement,
    required this.sectionType,
    required this.layout,
    required this.tone,
    required this.density,
    required this.alignment,
    required this.onPlacementChanged,
    required this.onTypeChanged,
    required this.onLayoutChanged,
    required this.onToneChanged,
    required this.onDensityChanged,
    required this.onAlignmentChanged,
  });

  final PageSectionPlacement placement;
  final PageSectionType sectionType;
  final PageSectionLayout layout;
  final PageSectionTone tone;
  final PageSectionDensity density;
  final PageSectionAlignment alignment;
  final ValueChanged<PageSectionPlacement> onPlacementChanged;
  final ValueChanged<PageSectionType> onTypeChanged;
  final ValueChanged<PageSectionLayout> onLayoutChanged;
  final ValueChanged<PageSectionTone> onToneChanged;
  final ValueChanged<PageSectionDensity> onDensityChanged;
  final ValueChanged<PageSectionAlignment> onAlignmentChanged;

  @override
  Widget build(BuildContext context) {
    return ProjectFormSection(
      title: 'Design Controls',
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _FieldBox(
              child: SectionDropdown(
                label: 'Placement',
                value: placement,
                values: PageSectionPlacement.values,
                labelFor: (value) => value.label,
                onChanged: onPlacementChanged,
              ),
            ),
            _FieldBox(
              child: SectionDropdown(
                label: 'Type',
                value: sectionType,
                values: PageSectionType.values,
                labelFor: (value) => value.label,
                onChanged: onTypeChanged,
              ),
            ),
            _FieldBox(
              child: SectionDropdown(
                label: 'Layout',
                value: layout,
                values: PageSectionLayout.values,
                labelFor: (value) => value.label,
                onChanged: onLayoutChanged,
              ),
            ),
            _FieldBox(
              child: SectionDropdown(
                label: 'Tone',
                value: tone,
                values: PageSectionTone.values,
                labelFor: (value) => value.label,
                onChanged: onToneChanged,
              ),
            ),
            _FieldBox(
              child: SectionDropdown(
                label: 'Density',
                value: density,
                values: PageSectionDensity.values,
                labelFor: (value) => value.label,
                onChanged: onDensityChanged,
              ),
            ),
            _FieldBox(
              child: SectionDropdown(
                label: 'Alignment',
                value: alignment,
                values: PageSectionAlignment.values,
                labelFor: (value) => value.label,
                onChanged: onAlignmentChanged,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class PageSectionAdvancedJsonSection extends StatelessWidget {
  const PageSectionAdvancedJsonSection({
    super.key,
    required this.contentJson,
    required this.designJson,
    required this.onChanged,
  });

  final TextEditingController contentJson;
  final TextEditingController designJson;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return ProjectFormSection(
      title: 'Advanced Escape Hatch',
      children: [
        ExpansionTile(
          tilePadding: EdgeInsets.zero,
          childrenPadding: EdgeInsets.zero,
          title: const Text('Edit Raw JSON'),
          subtitle: const Text(
            'Use only when the structured builder is not enough.',
          ),
          children: [
            TextFormField(
              controller: contentJson,
              decoration: const InputDecoration(
                labelText: 'Content JSON',
                helperText:
                    'Items/actions for grids, metrics, CTA, and timeline blocks.',
                alignLabelWithHint: true,
              ),
              minLines: 8,
              maxLines: 16,
              validator: (value) =>
                  validateJsonObjectField('Content JSON', value),
              onChanged: (_) => onChanged(),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: designJson,
              decoration: const InputDecoration(
                labelText: 'Design JSON',
                helperText:
                    'Optional metadata like accent, mediaUrl, or caption.',
                alignLabelWithHint: true,
              ),
              minLines: 5,
              maxLines: 12,
              validator: (value) =>
                  validateJsonObjectField('Design JSON', value),
              onChanged: (_) => onChanged(),
            ),
          ],
        ),
      ],
    );
  }
}

class _FieldBox extends StatelessWidget {
  const _FieldBox({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: 260, child: child);
  }
}
