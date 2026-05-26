import 'package:flutter/material.dart';

import '../../../../core/utils/json_readers.dart';
import '../../../projects/presentation/screens/project_form_support.dart';
import '../../domain/entities/section_block.dart';
import 'page_section_block_editor.dart';
import 'page_section_editor_drafts.dart';

class PageSectionBlocksInspector extends StatefulWidget {
  const PageSectionBlocksInspector({
    super.key,
    required this.contentJson,
    required this.onChanged,
  });

  final JsonMap contentJson;
  final ValueChanged<JsonMap> onChanged;

  @override
  State<PageSectionBlocksInspector> createState() =>
      _PageSectionBlocksInspectorState();
}

class _PageSectionBlocksInspectorState
    extends State<PageSectionBlocksInspector> {
  late final List<SectionBlockDraft> _blocks;

  @override
  void initState() {
    super.initState();
    _blocks = sectionBlocksFromContent(
      widget.contentJson,
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
      title: 'Blocks',
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
                onChanged: _sync,
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
    _sync();
  }

  void _remove(int index) {
    _blocks.removeAt(index).dispose();
    setState(() {});
    _sync();
  }

  void _reorder(int oldIndex, int newIndex) {
    final block = _blocks.removeAt(oldIndex);
    _blocks.insert(newIndex, block);
    setState(() {});
    _sync();
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
    _sync();
  }

  void _sync() {
    widget.onChanged(
      sectionBlocksToContent(_blocks.map((block) => block.toBlock()).toList()),
    );
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
