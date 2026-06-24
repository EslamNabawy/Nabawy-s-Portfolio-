import 'package:flutter/material.dart';

import '../../../projects/presentation/screens/project_form_support.dart';
import '../../domain/entities/section_block.dart';
import 'page_section_block_editor.dart';
import 'page_section_editor_drafts.dart';
import 'page_section_form_support.dart';

class PageSectionStructuredEditor extends StatefulWidget {
  const PageSectionStructuredEditor({
    super.key,
    required this.contentJson,
    required this.designJson,
    required this.onChanged,
  });

  final TextEditingController contentJson;
  final TextEditingController designJson;
  final VoidCallback onChanged;

  @override
  State<PageSectionStructuredEditor> createState() =>
      _PageSectionStructuredEditorState();
}

class _PageSectionStructuredEditorState
    extends State<PageSectionStructuredEditor> {
  late final List<SectionBlockDraft> _blocks;

  @override
  void initState() {
    super.initState();
    final content = parseJsonObjectText(
      widget.contentJson.text,
      'Content JSON',
    );
    _blocks = sectionBlocksFromContent(
      content,
    ).map(SectionBlockDraft.fromBlock).toList(growable: true);
    if (_blocks.isEmpty) {
      _blocks.add(SectionBlockDraft.empty(SectionBlockType.cardGrid));
    }
  }

  @override
  void dispose() {
    for (final block in _blocks) {
      block.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ProjectFormSection(
      title: 'Structured Builder',
      children: [
        ReorderableListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _blocks.length,
          onReorderItem: _reorder,
          itemBuilder: (context, index) {
            final block = _blocks[index];
            return Padding(
              key: ValueKey(block),
              padding: const EdgeInsets.only(bottom: 10),
              child: PageSectionBlockEditor(
                index: index,
                block: block,
                onTypeChanged: (value) => _changeType(index, value),
                onRemove: _blocks.length == 1 ? null : () => _remove(index),
                onChanged: _syncJson,
              ),
            );
          },
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: PopupMenuButton<SectionBlockType>(
            onSelected: _addBlock,
            itemBuilder: (context) => [
              for (final type in SectionBlockType.values)
                PopupMenuItem(value: type, child: Text(type.label)),
            ],
            child: const _AddBlockButton(),
          ),
        ),
      ],
    );
  }

  void _addBlock(SectionBlockType type) {
    setState(() => _blocks.add(SectionBlockDraft.empty(type)));
    _syncJson();
  }

  void _remove(int index) {
    _blocks.removeAt(index).dispose();
    setState(() {});
    _syncJson();
  }

  void _reorder(int oldIndex, int newIndex) {
    final block = _blocks.removeAt(oldIndex);
    _blocks.insert(newIndex, block);
    setState(() {});
    _syncJson();
  }

  void _changeType(int index, SectionBlockType type) {
    final block = _blocks[index];
    setState(() {
      block.type = type;
      if (!_hasItems(type)) {
        for (final item in block.items) {
          item.dispose();
        }
        block.items.clear();
      } else if (block.items.isEmpty) {
        block.items.add(SectionItemDraft.empty(0));
      }
      if (type != SectionBlockType.ctaRow) {
        for (final action in block.actions) {
          action.dispose();
        }
        block.actions.clear();
      } else if (block.actions.isEmpty) {
        block.actions.add(SectionActionDraft.empty());
      }
    });
    _syncJson();
  }

  void _syncJson() {
    widget.contentJson.text = prettyJson(
      sectionBlocksToContent(_blocks.map((block) => block.toBlock()).toList()),
    );
    final design = parseJsonObjectText(widget.designJson.text, 'Design JSON');
    widget.designJson.text = prettyJson(<String, Object?>{
      ...design,
      'accent': design['accent'] ?? 'signal',
    });
    widget.onChanged();
  }
}

class _AddBlockButton extends StatelessWidget {
  const _AddBlockButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outline),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [Icon(Icons.add), SizedBox(width: 8), Text('Add Block')],
      ),
    );
  }
}

bool _hasItems(SectionBlockType type) {
  return type == SectionBlockType.cardGrid ||
      type == SectionBlockType.metricStrip ||
      type == SectionBlockType.timeline ||
      type == SectionBlockType.architecturePanel;
}
