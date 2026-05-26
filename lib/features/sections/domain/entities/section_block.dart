import '../../../../core/utils/json_readers.dart';

enum SectionBlockType {
  heroText('heroText', 'Hero Text'),
  cardGrid('cardGrid', 'Card Grid'),
  metricStrip('metricStrip', 'Metric Strip'),
  timeline('timeline', 'Timeline'),
  media('media', 'Media'),
  ctaRow('ctaRow', 'CTA Row'),
  callout('callout', 'Callout'),
  architecturePanel('architecturePanel', 'Architecture Panel');

  const SectionBlockType(this.value, this.label);

  final String value;
  final String label;

  static SectionBlockType fromJson(String value) {
    return values.firstWhere(
      (item) => item.value == value,
      orElse: () => throw FormatException('Unknown section block "$value".'),
    );
  }
}

final class SectionBlock {
  const SectionBlock({
    required this.type,
    this.label,
    this.title,
    this.copy,
    this.url,
    this.mediaUrl,
    this.altText,
    this.caption,
    this.items = const <SectionBlockItem>[],
    this.actions = const <SectionBlockAction>[],
  });

  final SectionBlockType type;
  final String? label;
  final String? title;
  final String? copy;
  final String? url;
  final String? mediaUrl;
  final String? altText;
  final String? caption;
  final List<SectionBlockItem> items;
  final List<SectionBlockAction> actions;

  factory SectionBlock.fromJson(JsonMap json) {
    return SectionBlock(
      type: SectionBlockType.fromJson(readString(json, 'type')),
      label: readOptionalString(json, 'label'),
      title: readOptionalString(json, 'title'),
      copy: readOptionalString(json, 'copy'),
      url: readOptionalString(json, 'url'),
      mediaUrl: readOptionalString(json, 'mediaUrl'),
      altText: readOptionalString(json, 'altText'),
      caption: readOptionalString(json, 'caption'),
      items: _readItems(json['items']),
      actions: _readActions(json['actions']),
    );
  }

  JsonMap toJson() {
    return <String, Object?>{
      'type': type.value,
      if (_filled(label)) 'label': label!.trim(),
      if (_filled(title)) 'title': title!.trim(),
      if (_filled(copy)) 'copy': copy!.trim(),
      if (_filled(url)) 'url': url!.trim(),
      if (_filled(mediaUrl)) 'mediaUrl': mediaUrl!.trim(),
      if (_filled(altText)) 'altText': altText!.trim(),
      if (_filled(caption)) 'caption': caption!.trim(),
      if (items.isNotEmpty)
        'items': items.map((item) => item.toJson()).toList(),
      if (actions.isNotEmpty)
        'actions': actions.map((action) => action.toJson()).toList(),
    };
  }
}

final class SectionBlockItem {
  const SectionBlockItem({this.label, this.title, this.copy, this.url});

  final String? label;
  final String? title;
  final String? copy;
  final String? url;

  factory SectionBlockItem.fromJson(JsonMap json) {
    return SectionBlockItem(
      label: readOptionalString(json, 'label'),
      title: readOptionalString(json, 'title'),
      copy: readOptionalString(json, 'copy'),
      url: readOptionalString(json, 'url'),
    );
  }

  JsonMap toJson() {
    return <String, Object?>{
      if (_filled(label)) 'label': label!.trim(),
      if (_filled(title)) 'title': title!.trim(),
      if (_filled(copy)) 'copy': copy!.trim(),
      if (_filled(url)) 'url': url!.trim(),
    };
  }
}

final class SectionBlockAction {
  const SectionBlockAction({this.label, this.url});

  final String? label;
  final String? url;

  factory SectionBlockAction.fromJson(JsonMap json) {
    return SectionBlockAction(
      label: readOptionalString(json, 'label'),
      url: readOptionalString(json, 'url'),
    );
  }

  JsonMap toJson() {
    return <String, Object?>{
      if (_filled(label)) 'label': label!.trim(),
      if (_filled(url)) 'url': url!.trim(),
    };
  }
}

List<SectionBlock> sectionBlocksFromContent(JsonMap content) {
  final blocks = content['blocks'];
  if (blocks is Iterable) {
    return blocks
        .whereType<Map>()
        .map((item) => SectionBlock.fromJson(JsonMap.from(item)))
        .toList(growable: false);
  }

  final legacyItems = _readItems(content['items']);
  final legacyActions = _readActions(content['actions']);
  return <SectionBlock>[
    if (legacyItems.isNotEmpty)
      SectionBlock(type: SectionBlockType.cardGrid, items: legacyItems),
    if (legacyActions.isNotEmpty)
      SectionBlock(type: SectionBlockType.ctaRow, actions: legacyActions),
  ];
}

JsonMap sectionBlocksToContent(List<SectionBlock> blocks) {
  return <String, Object?>{
    'schemaVersion': 2,
    'blocks': blocks.map((block) => block.toJson()).toList(),
  };
}

List<SectionBlockItem> _readItems(Object? value) {
  if (value is! Iterable) {
    return const <SectionBlockItem>[];
  }
  return value
      .whereType<Map>()
      .map((item) => SectionBlockItem.fromJson(JsonMap.from(item)))
      .toList(growable: false);
}

List<SectionBlockAction> _readActions(Object? value) {
  if (value is! Iterable) {
    return const <SectionBlockAction>[];
  }
  return value
      .whereType<Map>()
      .map((item) => SectionBlockAction.fromJson(JsonMap.from(item)))
      .toList(growable: false);
}

bool _filled(String? value) => value != null && value.trim().isNotEmpty;
