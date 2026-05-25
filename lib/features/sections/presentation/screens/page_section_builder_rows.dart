import 'package:flutter/material.dart';

import 'page_section_editor_drafts.dart';
import 'page_section_form_support.dart';

class SectionItemEditor extends StatelessWidget {
  const SectionItemEditor({
    super.key,
    required this.index,
    required this.item,
    required this.onRemove,
    required this.onChanged,
  });

  final int index;
  final SectionItemDraft item;
  final VoidCallback? onRemove;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: Text('Card ${index + 1}')),
                IconButton(
                  tooltip: 'Remove card',
                  onPressed: onRemove,
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: item.label,
                    decoration: const InputDecoration(labelText: 'Label'),
                    onChanged: (_) => onChanged(),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: item.title,
                    decoration: const InputDecoration(labelText: 'Title'),
                    onChanged: (_) => onChanged(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: item.copy,
              decoration: const InputDecoration(labelText: 'Copy'),
              maxLines: 2,
              onChanged: (_) => onChanged(),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: item.url,
              decoration: const InputDecoration(labelText: 'Optional URL'),
              validator: validateOptionalHref,
              onChanged: (_) => onChanged(),
            ),
          ],
        ),
      ),
    );
  }
}

class SectionActionEditor extends StatelessWidget {
  const SectionActionEditor({
    super.key,
    required this.action,
    required this.onRemove,
    required this.onChanged,
  });

  final SectionActionDraft action;
  final VoidCallback onRemove;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: action.label,
            decoration: const InputDecoration(labelText: 'Label'),
            onChanged: (_) => onChanged(),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 2,
          child: TextFormField(
            controller: action.url,
            decoration: const InputDecoration(labelText: 'URL or Anchor'),
            validator: validateOptionalHref,
            onChanged: (_) => onChanged(),
          ),
        ),
        IconButton(
          tooltip: 'Remove CTA',
          onPressed: onRemove,
          icon: const Icon(Icons.delete_outline),
        ),
      ],
    );
  }
}
