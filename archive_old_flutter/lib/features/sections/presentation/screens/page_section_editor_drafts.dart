import 'package:flutter/material.dart';

import '../../domain/entities/section_block.dart';

final class SectionBlockDraft {
  SectionBlockDraft({
    required this.type,
    required String label,
    required String title,
    required String copy,
    required String url,
    required String mediaUrl,
    required String altText,
    required String caption,
    required this.items,
    required this.actions,
  }) : label = TextEditingController(text: label),
       title = TextEditingController(text: title),
       copy = TextEditingController(text: copy),
       url = TextEditingController(text: url),
       mediaUrl = TextEditingController(text: mediaUrl),
       altText = TextEditingController(text: altText),
       caption = TextEditingController(text: caption);

  factory SectionBlockDraft.empty(SectionBlockType type) {
    return SectionBlockDraft(
      type: type,
      label: '',
      title: '',
      copy: '',
      url: '',
      mediaUrl: '',
      altText: '',
      caption: '',
      items:
          type == SectionBlockType.cardGrid ||
              type == SectionBlockType.metricStrip ||
              type == SectionBlockType.timeline ||
              type == SectionBlockType.architecturePanel
          ? [SectionItemDraft.empty(0)]
          : <SectionItemDraft>[],
      actions: type == SectionBlockType.ctaRow
          ? [SectionActionDraft.empty()]
          : <SectionActionDraft>[],
    );
  }

  factory SectionBlockDraft.fromBlock(SectionBlock block) {
    return SectionBlockDraft(
      type: block.type,
      label: block.label ?? '',
      title: block.title ?? '',
      copy: block.copy ?? '',
      url: block.url ?? '',
      mediaUrl: block.mediaUrl ?? '',
      altText: block.altText ?? '',
      caption: block.caption ?? '',
      items: block.items
          .map(
            (item) => SectionItemDraft(
              label: item.label ?? '',
              title: item.title ?? '',
              copy: item.copy ?? '',
              url: item.url ?? '',
            ),
          )
          .toList(growable: true),
      actions: block.actions
          .map(
            (action) => SectionActionDraft(
              label: action.label ?? '',
              url: action.url ?? '',
            ),
          )
          .toList(growable: true),
    );
  }

  SectionBlockType type;
  final TextEditingController label;
  final TextEditingController title;
  final TextEditingController copy;
  final TextEditingController url;
  final TextEditingController mediaUrl;
  final TextEditingController altText;
  final TextEditingController caption;
  final List<SectionItemDraft> items;
  final List<SectionActionDraft> actions;

  SectionBlock toBlock() {
    return SectionBlock(
      type: type,
      label: _text(label),
      title: _text(title),
      copy: _text(copy),
      url: _text(url),
      mediaUrl: _text(mediaUrl),
      altText: _text(altText),
      caption: _text(caption),
      items: [
        for (final item in items)
          SectionBlockItem(
            label: _text(item.label),
            title: _text(item.title),
            copy: _text(item.copy),
            url: _text(item.url),
          ),
      ],
      actions: [
        for (final action in actions)
          SectionBlockAction(
            label: _text(action.label),
            url: _text(action.url),
          ),
      ],
    );
  }

  void dispose() {
    label.dispose();
    title.dispose();
    copy.dispose();
    url.dispose();
    mediaUrl.dispose();
    altText.dispose();
    caption.dispose();
    for (final item in items) {
      item.dispose();
    }
    for (final action in actions) {
      action.dispose();
    }
  }
}

final class SectionItemDraft {
  SectionItemDraft({
    required String label,
    required String title,
    required String copy,
    required String url,
  }) : label = TextEditingController(text: label),
       title = TextEditingController(text: title),
       copy = TextEditingController(text: copy),
       url = TextEditingController(text: url);

  factory SectionItemDraft.empty(int index) {
    return SectionItemDraft(
      label: (index + 1).toString().padLeft(2, '0'),
      title: '',
      copy: '',
      url: '',
    );
  }

  final TextEditingController label;
  final TextEditingController title;
  final TextEditingController copy;
  final TextEditingController url;

  void dispose() {
    label.dispose();
    title.dispose();
    copy.dispose();
    url.dispose();
  }
}

String? _text(TextEditingController controller) {
  final value = controller.text.trim();
  return value.isEmpty ? null : value;
}

final class SectionActionDraft {
  SectionActionDraft({required String label, required String url})
    : label = TextEditingController(text: label),
      url = TextEditingController(text: url);

  factory SectionActionDraft.empty() {
    return SectionActionDraft(label: '', url: '');
  }

  final TextEditingController label;
  final TextEditingController url;

  void dispose() {
    label.dispose();
    url.dispose();
  }
}
