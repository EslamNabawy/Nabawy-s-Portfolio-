import 'package:flutter/material.dart';

import '../../domain/entities/page_section.dart';
import '../../domain/entities/section_block.dart';

class PageSectionPreview extends StatelessWidget {
  const PageSectionPreview({super.key, required this.section});

  final PageSection section;

  @override
  Widget build(BuildContext context) {
    final colors = _PreviewColors.forTone(section.tone);
    final blocks = sectionBlocksFromContent(section.contentJson);
    final items = _itemsFromBlocks(blocks);
    final actions = _actionsFromBlocks(blocks);
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: colors.line),
        color: colors.background,
      ),
      child: Padding(
        padding: EdgeInsets.all(_paddingFor(section.density)),
        child: Column(
          crossAxisAlignment: section.alignment == PageSectionAlignment.center
              ? CrossAxisAlignment.center
              : CrossAxisAlignment.start,
          children: [
            Text(
              section.eyebrow?.toUpperCase() ?? 'SECTION PREVIEW',
              style: TextStyle(
                color: colors.accent,
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.6,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              section.title,
              textAlign: _textAlign,
              style: TextStyle(
                color: colors.foreground,
                fontSize: 28,
                height: 1,
                fontWeight: FontWeight.w900,
              ),
            ),
            if ((section.body ?? '').trim().isNotEmpty) ...[
              const SizedBox(height: 12),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 620),
                child: Text(
                  section.body!,
                  textAlign: _textAlign,
                  style: TextStyle(
                    color: colors.muted,
                    height: 1.6,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
            if (actions.isNotEmpty) ...[
              const SizedBox(height: 16),
              Wrap(
                alignment: section.alignment == PageSectionAlignment.center
                    ? WrapAlignment.center
                    : WrapAlignment.start,
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final action in actions)
                    OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colors.foreground,
                        side: BorderSide(color: colors.line),
                      ),
                      child: Text(action.label),
                    ),
                ],
              ),
            ],
            if (items.isNotEmpty) ...[
              const SizedBox(height: 18),
              _PreviewItems(section: section, items: items, colors: colors),
            ],
          ],
        ),
      ),
    );
  }

  TextAlign get _textAlign {
    return section.alignment == PageSectionAlignment.center
        ? TextAlign.center
        : TextAlign.left;
  }

  double _paddingFor(PageSectionDensity density) {
    return switch (density) {
      PageSectionDensity.compact => 16,
      PageSectionDensity.standard => 22,
      PageSectionDensity.spacious => 32,
    };
  }
}

class _PreviewItems extends StatelessWidget {
  const _PreviewItems({
    required this.section,
    required this.items,
    required this.colors,
  });

  final PageSection section;
  final List<_PreviewItem> items;
  final _PreviewColors colors;

  @override
  Widget build(BuildContext context) {
    final columns = switch (section.layout) {
      PageSectionLayout.grid || PageSectionLayout.banner => 3,
      PageSectionLayout.split => 2,
      PageSectionLayout.stack || PageSectionLayout.rail => 1,
    };
    return LayoutBuilder(
      builder: (context, constraints) {
        final effectiveColumns = constraints.maxWidth < 720 ? 1 : columns;
        return GridView.count(
          crossAxisCount: effectiveColumns,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: effectiveColumns == 1 ? 4.2 : 1.7,
          children: [
            for (final item in items)
              DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(color: colors.line),
                  color: colors.itemBackground,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.label,
                        style: TextStyle(
                          color: colors.accent,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: colors.foreground,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Expanded(
                        child: Text(
                          item.copy,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: colors.muted, height: 1.35),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

final class _PreviewColors {
  const _PreviewColors({
    required this.background,
    required this.itemBackground,
    required this.foreground,
    required this.muted,
    required this.line,
    required this.accent,
  });

  final Color background;
  final Color itemBackground;
  final Color foreground;
  final Color muted;
  final Color line;
  final Color accent;

  static _PreviewColors forTone(PageSectionTone tone) {
    return switch (tone) {
      PageSectionTone.ink => const _PreviewColors(
        background: Color(0xFF080B0C),
        itemBackground: Color(0xFF111827),
        foreground: Colors.white,
        muted: Color(0xFFCBD5E1),
        line: Color(0x33475569),
        accent: Color(0xFF21D3BE),
      ),
      PageSectionTone.signal => const _PreviewColors(
        background: Color(0xFF061213),
        itemBackground: Color(0x161EFFE3),
        foreground: Colors.white,
        muted: Color(0xFFCBD5E1),
        line: Color(0x5521D3BE),
        accent: Color(0xFF21D3BE),
      ),
      PageSectionTone.studio => const _PreviewColors(
        background: Color(0xFFEAF3F1),
        itemBackground: Colors.white,
        foreground: Color(0xFF080B0C),
        muted: Color(0xFF58635F),
        line: Color(0xFFC7D2CC),
        accent: Color(0xFF00836B),
      ),
      PageSectionTone.minimal || PageSectionTone.panel => const _PreviewColors(
        background: Color(0xFFF4F7F5),
        itemBackground: Colors.white,
        foreground: Color(0xFF080B0C),
        muted: Color(0xFF58635F),
        line: Color(0xFFC7D2CC),
        accent: Color(0xFF00836B),
      ),
    };
  }
}

final class _PreviewItem {
  const _PreviewItem({
    required this.label,
    required this.title,
    required this.copy,
  });

  final String label;
  final String title;
  final String copy;
}

final class _PreviewAction {
  const _PreviewAction({required this.label});

  final String label;
}

List<_PreviewItem> _itemsFromBlocks(List<SectionBlock> blocks) {
  final items = <_PreviewItem>[];
  for (final block in blocks) {
    if (block.type == SectionBlockType.heroText ||
        block.type == SectionBlockType.callout ||
        block.type == SectionBlockType.media) {
      if ((block.title ?? block.copy ?? '').trim().isNotEmpty) {
        items.add(
          _PreviewItem(
            label: block.label ?? block.type.label,
            title: block.title ?? block.caption ?? block.type.label,
            copy: block.copy ?? block.mediaUrl ?? '',
          ),
        );
      }
    }
    for (final item in block.items) {
      items.add(
        _PreviewItem(
          label: item.label ?? block.type.label,
          title: item.title ?? block.type.label,
          copy: item.copy ?? '',
        ),
      );
    }
  }
  return items;
}

List<_PreviewAction> _actionsFromBlocks(List<SectionBlock> blocks) {
  return [
    for (final block in blocks)
      ...block.actions
          .where((action) => (action.label ?? '').trim().isNotEmpty)
          .map((action) => _PreviewAction(label: action.label!.trim())),
  ];
}
