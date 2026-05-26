import 'page_section.dart';
import 'section_block.dart';

final class PageSectionReadiness {
  const PageSectionReadiness({required this.messages});

  final List<String> messages;

  bool get isReady => messages.isEmpty;
}

PageSectionReadiness assessPageSectionReadiness(PageSection section) {
  final messages = <String>[];
  if (section.title.trim().isEmpty) {
    messages.add('Title is required.');
  }
  if (!RegExp(r'^[a-z0-9]+(-[a-z0-9]+)*$').hasMatch(section.sectionKey)) {
    messages.add('Section key must be lowercase kebab-case.');
  }
  if (!section.isPublished) {
    return PageSectionReadiness(messages: List.unmodifiable(messages));
  }

  final blocks = sectionBlocksFromContent(section.contentJson);
  if (blocks.isEmpty) {
    messages.add('Published sections need at least one content block.');
  }
  for (final block in blocks) {
    messages.addAll(_validateBlock(block));
  }
  return PageSectionReadiness(messages: List.unmodifiable(messages));
}

List<String> _validateBlock(SectionBlock block) {
  final messages = <String>[];
  switch (block.type) {
    case SectionBlockType.cardGrid:
    case SectionBlockType.metricStrip:
    case SectionBlockType.timeline:
    case SectionBlockType.architecturePanel:
      if (block.items.isEmpty) {
        messages.add('${block.type.label} needs at least one item.');
      }
      for (final item in block.items) {
        if (_blank(item.title) && _blank(item.copy)) {
          messages.add('${block.type.label} has an empty item.');
        }
        if (!_blank(item.url) && !_safeHref(item.url!)) {
          messages.add('${block.type.label} has an unsafe item URL.');
        }
      }
      break;
    case SectionBlockType.ctaRow:
      if (block.actions.isEmpty) {
        messages.add('CTA Row needs at least one button.');
      }
      for (final action in block.actions) {
        if (_blank(action.label) || _blank(action.url)) {
          messages.add('CTA buttons require label and URL.');
        } else if (!_safeHref(action.url!)) {
          messages.add('CTA Row has an unsafe URL.');
        }
      }
      break;
    case SectionBlockType.media:
      if (_blank(block.mediaUrl) || !_safeMediaUrl(block.mediaUrl!)) {
        messages.add('Media block needs a valid http(s) URL.');
      }
      if (_blank(block.altText) && _blank(block.caption)) {
        messages.add('Media block needs alt text or caption.');
      }
      break;
    case SectionBlockType.heroText:
    case SectionBlockType.callout:
      if (_blank(block.title) && _blank(block.copy)) {
        messages.add('${block.type.label} needs title or copy.');
      }
      if (!_blank(block.url) && !_safeHref(block.url!)) {
        messages.add('${block.type.label} has an unsafe URL.');
      }
      break;
  }
  return messages;
}

bool _blank(String? value) => value == null || value.trim().isEmpty;

bool _safeHref(String value) {
  final trimmed = value.trim();
  return trimmed.startsWith('#') ||
      trimmed.startsWith('/') ||
      trimmed.startsWith('https://') ||
      trimmed.startsWith('http://') ||
      trimmed.startsWith('mailto:');
}

bool _safeMediaUrl(String value) {
  final trimmed = value.trim();
  return trimmed.startsWith('https://') || trimmed.startsWith('http://');
}
