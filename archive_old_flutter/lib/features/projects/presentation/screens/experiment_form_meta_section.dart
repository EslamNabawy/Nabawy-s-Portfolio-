import 'package:flutter/material.dart';

import '../../domain/entities/experiment.dart';
import 'project_form_support.dart';

class ExperimentMetaSection extends StatelessWidget {
  const ExperimentMetaSection({
    super.key,
    required this.status,
    required this.mediaUrl,
    required this.githubUrl,
    required this.liveUrl,
    required this.displayOrder,
    required this.isPublished,
    required this.onStatusChanged,
    required this.onPublishedChanged,
  });

  final ExperimentStatus status;
  final TextEditingController mediaUrl;
  final TextEditingController githubUrl;
  final TextEditingController liveUrl;
  final TextEditingController displayOrder;
  final bool isPublished;
  final ValueChanged<ExperimentStatus> onStatusChanged;
  final ValueChanged<bool> onPublishedChanged;

  @override
  Widget build(BuildContext context) {
    return ProjectFormSection(
      title: 'Status and Links',
      children: [
        DropdownButtonFormField<ExperimentStatus>(
          initialValue: status,
          decoration: const InputDecoration(labelText: 'Status'),
          items: const [
            DropdownMenuItem(
              value: ExperimentStatus.prototype,
              child: Text('Prototype'),
            ),
            DropdownMenuItem(
              value: ExperimentStatus.active,
              child: Text('Active'),
            ),
            DropdownMenuItem(
              value: ExperimentStatus.archived,
              child: Text('Archived'),
            ),
          ],
          onChanged: (value) {
            if (value != null) {
              onStatusChanged(value);
            }
          },
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: mediaUrl,
          decoration: const InputDecoration(labelText: 'Media URL'),
          validator: validateOptionalUrl,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: githubUrl,
          decoration: const InputDecoration(labelText: 'GitHub URL'),
          validator: validateOptionalUrl,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: liveUrl,
          decoration: const InputDecoration(labelText: 'Live URL'),
          validator: validateOptionalUrl,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: displayOrder,
          decoration: const InputDecoration(labelText: 'Display Order'),
          keyboardType: TextInputType.number,
          validator: validateDisplayOrder,
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: isPublished,
          title: const Text('Published'),
          subtitle: const Text('Visible in the public Lab.'),
          onChanged: onPublishedChanged,
        ),
      ],
    );
  }
}
