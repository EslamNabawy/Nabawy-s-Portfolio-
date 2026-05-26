import 'package:flutter/material.dart';

import '../../../projects/presentation/screens/project_form_support.dart';
import '../../domain/entities/section_block.dart';
import 'page_section_builder_rows.dart';
import 'page_section_editor_drafts.dart';
import 'page_section_form_support.dart';

class PageSectionBlockEditor extends StatelessWidget {
  const PageSectionBlockEditor({
    super.key,
    required this.index,
    required this.block,
    required this.onTypeChanged,
    required this.onRemove,
    required this.onChanged,
  });

  final int index;
  final SectionBlockDraft block;
  final ValueChanged<SectionBlockType> onTypeChanged;
  final VoidCallback? onRemove;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.drag_indicator),
                const SizedBox(width: 8),
                Expanded(child: Text('Block ${index + 1}')),
                SizedBox(
                  width: 190,
                  child: SectionDropdown(
                    label: 'Block Type',
                    value: block.type,
                    values: SectionBlockType.values,
                    labelFor: (value) => value.label,
                    onChanged: onTypeChanged,
                  ),
                ),
                IconButton(
                  tooltip: 'Remove block',
                  onPressed: onRemove,
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _TextFields(block: block, onChanged: onChanged),
            if (_hasItems(block.type)) ...[
              const Divider(height: 28),
              _ItemList(block: block, onChanged: onChanged),
            ],
            if (block.type == SectionBlockType.ctaRow) ...[
              const Divider(height: 28),
              _ActionList(block: block, onChanged: onChanged),
            ],
            if (block.type == SectionBlockType.media) ...[
              const Divider(height: 28),
              _MediaFields(block: block, onChanged: onChanged),
            ],
          ],
        ),
      ),
    );
  }
}

class _TextFields extends StatelessWidget {
  const _TextFields({required this.block, required this.onChanged});

  final SectionBlockDraft block;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: block.label,
                decoration: const InputDecoration(labelText: 'Label'),
                onChanged: (_) => onChanged(),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: TextFormField(
                controller: block.title,
                decoration: const InputDecoration(labelText: 'Title'),
                onChanged: (_) => onChanged(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: block.copy,
          decoration: const InputDecoration(labelText: 'Copy'),
          minLines: 2,
          maxLines: 4,
          onChanged: (_) => onChanged(),
        ),
        if (block.type == SectionBlockType.heroText ||
            block.type == SectionBlockType.callout) ...[
          const SizedBox(height: 10),
          TextFormField(
            controller: block.url,
            decoration: const InputDecoration(labelText: 'Optional URL'),
            validator: validateOptionalHref,
            onChanged: (_) => onChanged(),
          ),
        ],
      ],
    );
  }
}

class _ItemList extends StatefulWidget {
  const _ItemList({required this.block, required this.onChanged});

  final SectionBlockDraft block;
  final VoidCallback onChanged;

  @override
  State<_ItemList> createState() => _ItemListState();
}

class _ItemListState extends State<_ItemList> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var index = 0; index < widget.block.items.length; index++) ...[
          SectionItemEditor(
            index: index,
            item: widget.block.items[index],
            onRemove: widget.block.items.length == 1
                ? null
                : () => _remove(index),
            onChanged: widget.onChanged,
          ),
          const SizedBox(height: 10),
        ],
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            onPressed: _add,
            icon: const Icon(Icons.add),
            label: const Text('Add Item'),
          ),
        ),
      ],
    );
  }

  void _add() {
    setState(
      () => widget.block.items.add(
        SectionItemDraft.empty(widget.block.items.length),
      ),
    );
    widget.onChanged();
  }

  void _remove(int index) {
    widget.block.items.removeAt(index).dispose();
    setState(() {});
    widget.onChanged();
  }
}

class _ActionList extends StatefulWidget {
  const _ActionList({required this.block, required this.onChanged});

  final SectionBlockDraft block;
  final VoidCallback onChanged;

  @override
  State<_ActionList> createState() => _ActionListState();
}

class _ActionListState extends State<_ActionList> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var index = 0; index < widget.block.actions.length; index++) ...[
          SectionActionEditor(
            action: widget.block.actions[index],
            onRemove: () => _remove(index),
            onChanged: widget.onChanged,
          ),
          const SizedBox(height: 10),
        ],
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            onPressed: _add,
            icon: const Icon(Icons.add_link),
            label: const Text('Add CTA'),
          ),
        ),
      ],
    );
  }

  void _add() {
    setState(() => widget.block.actions.add(SectionActionDraft.empty()));
    widget.onChanged();
  }

  void _remove(int index) {
    widget.block.actions.removeAt(index).dispose();
    setState(() {});
    widget.onChanged();
  }
}

class _MediaFields extends StatelessWidget {
  const _MediaFields({required this.block, required this.onChanged});

  final SectionBlockDraft block;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: block.mediaUrl,
          decoration: const InputDecoration(labelText: 'Media URL'),
          validator: validateOptionalUrl,
          onChanged: (_) => onChanged(),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: block.altText,
          decoration: const InputDecoration(labelText: 'Alt Text'),
          onChanged: (_) => onChanged(),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: block.caption,
          decoration: const InputDecoration(labelText: 'Caption'),
          onChanged: (_) => onChanged(),
        ),
      ],
    );
  }
}

bool _hasItems(SectionBlockType type) {
  return type == SectionBlockType.cardGrid ||
      type == SectionBlockType.metricStrip ||
      type == SectionBlockType.timeline ||
      type == SectionBlockType.architecturePanel;
}
