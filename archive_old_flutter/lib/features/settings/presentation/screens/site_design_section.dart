import 'package:flutter/material.dart';

import '../../../projects/presentation/screens/project_form_support.dart';
import '../../domain/entities/site_config.dart';

class SiteDesignSection extends StatelessWidget {
  const SiteDesignSection({
    super.key,
    required this.designVariant,
    required this.onChanged,
  });

  final PublicDesignVariant designVariant;
  final ValueChanged<PublicDesignVariant> onChanged;

  @override
  Widget build(BuildContext context) {
    return ProjectFormSection(
      title: 'Public Design',
      children: [
        DropdownButtonFormField<PublicDesignVariant>(
          initialValue: designVariant,
          decoration: const InputDecoration(labelText: 'Portfolio Design'),
          items: [
            for (final variant in PublicDesignVariant.values)
              DropdownMenuItem(value: variant, child: Text(variant.label)),
          ],
          onChanged: (value) {
            if (value != null) {
              onChanged(value);
            }
          },
        ),
        const SizedBox(height: 12),
        Text(_descriptionFor(designVariant)),
      ],
    );
  }

  String _descriptionFor(PublicDesignVariant variant) {
    return switch (variant) {
      PublicDesignVariant.commandCenter =>
        'Dark cinematic engineering console with the strongest visual identity.',
      PublicDesignVariant.cleanDossier =>
        'Bright recruiter-friendly dossier layout with quieter contrast.',
      PublicDesignVariant.terminalOps =>
        'High-contrast terminal operations style for a more tactical mood.',
      PublicDesignVariant.signalStudio =>
        'Bright creative studio surface with bold signal accents and premium contrast.',
      PublicDesignVariant.systemForge =>
        'Sharper industrial engineering surface with amber telemetry.',
    };
  }
}
