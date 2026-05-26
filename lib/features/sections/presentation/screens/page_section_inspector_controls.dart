import 'package:flutter/material.dart';

import '../../../deployment/domain/entities/deployment_result.dart';
import '../../../deployment/presentation/widgets/deployment_status_panels.dart';
import '../../../projects/presentation/screens/project_form_support.dart';
import '../../domain/entities/page_section.dart';
import 'page_section_form_support.dart';

class PageSectionIdentityFields extends StatelessWidget {
  const PageSectionIdentityFields({
    super.key,
    required this.sectionKey,
    required this.title,
    required this.eyebrow,
    required this.body,
  });

  final TextEditingController sectionKey;
  final TextEditingController title;
  final TextEditingController eyebrow;
  final TextEditingController body;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: sectionKey,
          decoration: const InputDecoration(labelText: 'Section Key'),
          validator: validateSlug,
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: title,
          decoration: const InputDecoration(labelText: 'Title'),
          validator: requiredField('Title'),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: eyebrow,
          decoration: const InputDecoration(labelText: 'Eyebrow'),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: body,
          decoration: const InputDecoration(labelText: 'Body'),
          minLines: 3,
          maxLines: 6,
        ),
      ],
    );
  }
}

class PageSectionDesignFields extends StatelessWidget {
  const PageSectionDesignFields({
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
    return Column(
      children: [
        SectionDropdown(
          label: 'Placement',
          value: placement,
          values: PageSectionPlacement.values,
          labelFor: (value) => value.label,
          onChanged: onPlacementChanged,
        ),
        const SizedBox(height: 10),
        SectionDropdown(
          label: 'Type',
          value: sectionType,
          values: PageSectionType.values,
          labelFor: (value) => value.label,
          onChanged: onTypeChanged,
        ),
        const SizedBox(height: 10),
        SectionDropdown(
          label: 'Layout',
          value: layout,
          values: PageSectionLayout.values,
          labelFor: (value) => value.label,
          onChanged: onLayoutChanged,
        ),
        const SizedBox(height: 10),
        SectionDropdown(
          label: 'Tone',
          value: tone,
          values: PageSectionTone.values,
          labelFor: (value) => value.label,
          onChanged: onToneChanged,
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: SectionDropdown(
                label: 'Density',
                value: density,
                values: PageSectionDensity.values,
                labelFor: (value) => value.label,
                onChanged: onDensityChanged,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: SectionDropdown(
                label: 'Align',
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

class PageSectionInspectorActions extends StatelessWidget {
  const PageSectionInspectorActions({
    super.key,
    required this.busy,
    required this.isDeploying,
    required this.section,
    required this.onSave,
    required this.onSaveAndDeploy,
    required this.onEditAdvanced,
    required this.onPreview,
    required this.onDuplicate,
    required this.onDelete,
  });

  final bool busy;
  final bool isDeploying;
  final PageSection section;
  final VoidCallback onSave;
  final VoidCallback onSaveAndDeploy;
  final ValueChanged<PageSection> onEditAdvanced;
  final ValueChanged<PageSection> onPreview;
  final ValueChanged<PageSection> onDuplicate;
  final ValueChanged<PageSection> onDelete;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          onPressed: busy ? null : onSave,
          icon: const Icon(Icons.save_outlined),
          label: const Text('Save Inspector Changes'),
        ),
        const SizedBox(height: 8),
        FilledButton.tonalIcon(
          onPressed: busy ? null : onSaveAndDeploy,
          icon: isDeploying
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.rocket_launch_outlined),
          label: Text(isDeploying ? 'Deploying...' : 'Save + Deploy'),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: busy ? null : () => onEditAdvanced(section),
          icon: const Icon(Icons.dashboard_customize_outlined),
          label: const Text('Open Builder'),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            OutlinedButton.icon(
              onPressed: () => onPreview(section),
              icon: const Icon(Icons.open_in_full),
              label: const Text('Preview'),
            ),
            OutlinedButton.icon(
              onPressed: () => onDuplicate(section),
              icon: const Icon(Icons.copy_outlined),
              label: const Text('Duplicate'),
            ),
            OutlinedButton.icon(
              onPressed: section.id == null ? null : () => onDelete(section),
              icon: const Icon(Icons.delete_outline),
              label: const Text('Delete'),
            ),
          ],
        ),
      ],
    );
  }
}

class PageSectionDeploymentFeedback extends StatelessWidget {
  const PageSectionDeploymentFeedback({
    super.key,
    this.progress,
    this.result,
    this.error,
  });

  final DeploymentProgress? progress;
  final DeploymentResult? result;
  final String? error;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (progress != null) DeploymentProgressPanel(progress: progress!),
        if (result != null) DeploymentResultPanel(result: result!),
        if (error != null) DeploymentErrorPanel(message: error!),
      ],
    );
  }
}
