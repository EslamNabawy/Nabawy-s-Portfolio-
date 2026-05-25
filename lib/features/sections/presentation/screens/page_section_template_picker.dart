import 'package:flutter/material.dart';

import '../../domain/entities/page_section_template.dart';

Future<PageSectionTemplate?> showPageSectionTemplatePicker(
  BuildContext context,
) {
  return showDialog<PageSectionTemplate>(
    context: context,
    builder: (context) => const _TemplateDialog(),
  );
}

class _TemplateDialog extends StatelessWidget {
  const _TemplateDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 880, maxHeight: 620),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Start From Template',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Templates are editable drafts. Pick one, then tune placement, layout, tone, and JSON content.',
              ),
              const SizedBox(height: 18),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 360,
                    mainAxisExtent: 190,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: pageSectionTemplates.length,
                  itemBuilder: (context, index) {
                    final template = pageSectionTemplates[index];
                    return _TemplateTile(template: template);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TemplateTile extends StatelessWidget {
  const _TemplateTile({required this.template});

  final PageSectionTemplate template;

  @override
  Widget build(BuildContext context) {
    final section = template.section;
    return InkWell(
      onTap: () => Navigator.of(context).pop(template),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFC7D2CC)),
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      template.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const Icon(Icons.add_circle_outline, size: 20),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                template.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Color(0xFF58635F)),
              ),
              const Spacer(),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _Chip(section.placement.label),
                  _Chip(section.sectionType.label),
                  _Chip(section.tone.label),
                  _Chip(section.layout.label),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        child: Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
