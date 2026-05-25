import 'package:flutter/material.dart';

import '../../../projects/presentation/screens/project_form_support.dart';
import 'page_section_builder_rows.dart';
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
  late final TextEditingController _mediaUrl;
  late final TextEditingController _caption;
  late final List<SectionItemDraft> _items;
  late final List<SectionActionDraft> _actions;

  @override
  void initState() {
    super.initState();
    final content = parseJsonObjectText(
      widget.contentJson.text,
      'Content JSON',
    );
    final design = parseJsonObjectText(widget.designJson.text, 'Design JSON');
    _items = _readItems(content['items']);
    _actions = _readActions(content['actions']);
    if (_items.isEmpty) {
      _items.add(SectionItemDraft.empty(_items.length));
    }
    _mediaUrl = TextEditingController(text: _readString(design['mediaUrl']));
    _caption = TextEditingController(text: _readString(design['caption']));
  }

  @override
  void dispose() {
    _mediaUrl.dispose();
    _caption.dispose();
    for (final item in _items) {
      item.dispose();
    }
    for (final action in _actions) {
      action.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ProjectFormSection(
      title: 'Structured Builder',
      children: [
        Text('Content Cards', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 10),
        for (var index = 0; index < _items.length; index++) ...[
          SectionItemEditor(
            index: index,
            item: _items[index],
            onRemove: _items.length == 1 ? null : () => _removeItem(index),
            onChanged: _syncJson,
          ),
          const SizedBox(height: 10),
        ],
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            onPressed: _addItem,
            icon: const Icon(Icons.add),
            label: const Text('Add Card'),
          ),
        ),
        const Divider(height: 28),
        Text('CTA Buttons', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 10),
        for (var index = 0; index < _actions.length; index++) ...[
          SectionActionEditor(
            action: _actions[index],
            onRemove: () => _removeAction(index),
            onChanged: _syncJson,
          ),
          const SizedBox(height: 10),
        ],
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            onPressed: _addAction,
            icon: const Icon(Icons.add_link),
            label: const Text('Add CTA'),
          ),
        ),
        const Divider(height: 28),
        Text('Media', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 10),
        TextFormField(
          controller: _mediaUrl,
          decoration: const InputDecoration(labelText: 'Media URL'),
          validator: validateOptionalUrl,
          onChanged: (_) => _syncJson(),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: _caption,
          decoration: const InputDecoration(labelText: 'Media Caption'),
          onChanged: (_) => _syncJson(),
        ),
      ],
    );
  }

  void _addItem() {
    setState(() => _items.add(SectionItemDraft.empty(_items.length)));
    _syncJson();
  }

  void _removeItem(int index) {
    final removed = _items.removeAt(index);
    removed.dispose();
    setState(() {});
    _syncJson();
  }

  void _addAction() {
    setState(() => _actions.add(SectionActionDraft.empty()));
    _syncJson();
  }

  void _removeAction(int index) {
    final removed = _actions.removeAt(index);
    removed.dispose();
    setState(() {});
    _syncJson();
  }

  void _syncJson() {
    widget.contentJson.text = prettyJson(<String, Object?>{
      'items': [
        for (final item in _items)
          {
            'label': item.label.text.trim(),
            'title': item.title.text.trim(),
            'copy': item.copy.text.trim(),
            'url': item.url.text.trim(),
          },
      ],
      'actions': [
        for (final action in _actions)
          {'label': action.label.text.trim(), 'url': action.url.text.trim()},
      ],
    });
    widget.designJson.text = prettyJson(<String, Object?>{
      'accent': 'signal',
      'mediaUrl': _mediaUrl.text.trim(),
      'caption': _caption.text.trim(),
    });
    widget.onChanged();
  }

  List<SectionItemDraft> _readItems(Object? value) {
    if (value is! Iterable) {
      return <SectionItemDraft>[];
    }
    return value
        .whereType<Map>()
        .map(
          (item) => SectionItemDraft(
            label: _readString(item['label']),
            title: _readString(item['title']),
            copy: _readString(item['copy']),
            url: _readString(item['url']),
          ),
        )
        .toList(growable: true);
  }

  List<SectionActionDraft> _readActions(Object? value) {
    if (value is! Iterable) {
      return <SectionActionDraft>[];
    }
    return value
        .whereType<Map>()
        .map(
          (item) => SectionActionDraft(
            label: _readString(item['label']),
            url: _readString(item['url']),
          ),
        )
        .toList(growable: true);
  }

  String _readString(Object? value) {
    return value is String ? value.trim() : '';
  }
}
