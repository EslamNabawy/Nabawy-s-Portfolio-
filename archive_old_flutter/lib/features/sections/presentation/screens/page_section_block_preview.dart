import 'package:flutter/material.dart';

import '../../domain/entities/page_section.dart';
import '../../domain/entities/section_block.dart';

final class PageSectionPreviewPalette {
  const PageSectionPreviewPalette({
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

  static PageSectionPreviewPalette forTone(PageSectionTone tone) {
    return switch (tone) {
      PageSectionTone.ink => const PageSectionPreviewPalette(
        background: Color(0xFF080B0C),
        itemBackground: Color(0xFF111827),
        foreground: Colors.white,
        muted: Color(0xFFCBD5E1),
        line: Color(0x33475569),
        accent: Color(0xFF21D3BE),
      ),
      PageSectionTone.signal => const PageSectionPreviewPalette(
        background: Color(0xFF061213),
        itemBackground: Color(0x161EFFE3),
        foreground: Colors.white,
        muted: Color(0xFFCBD5E1),
        line: Color(0x5521D3BE),
        accent: Color(0xFF21D3BE),
      ),
      PageSectionTone.studio => const PageSectionPreviewPalette(
        background: Color(0xFFEAF3F1),
        itemBackground: Colors.white,
        foreground: Color(0xFF080B0C),
        muted: Color(0xFF58635F),
        line: Color(0xFFC7D2CC),
        accent: Color(0xFF00836B),
      ),
      PageSectionTone.minimal ||
      PageSectionTone.panel => const PageSectionPreviewPalette(
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

class PageSectionBlockPreview extends StatelessWidget {
  const PageSectionBlockPreview({
    super.key,
    required this.block,
    required this.section,
    required this.palette,
  });

  final SectionBlock block;
  final PageSection section;
  final PageSectionPreviewPalette palette;

  @override
  Widget build(BuildContext context) {
    return switch (block.type) {
      SectionBlockType.media => _MediaBlock(block: block, palette: palette),
      SectionBlockType.ctaRow => _ActionBlock(block: block, palette: palette),
      SectionBlockType.heroText ||
      SectionBlockType.callout => _TextBlock(block: block, palette: palette),
      _ => _ItemGrid(block: block, section: section, palette: palette),
    };
  }
}

class _TextBlock extends StatelessWidget {
  const _TextBlock({required this.block, required this.palette});

  final SectionBlock block;
  final PageSectionPreviewPalette palette;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      palette: palette,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if ((block.label ?? '').isNotEmpty) _Label(block.label!, palette),
          if ((block.title ?? '').isNotEmpty) _Title(block.title!, palette),
          if ((block.copy ?? '').isNotEmpty) _Copy(block.copy!, palette),
        ],
      ),
    );
  }
}

class _MediaBlock extends StatelessWidget {
  const _MediaBlock({required this.block, required this.palette});

  final SectionBlock block;
  final PageSectionPreviewPalette palette;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      palette: palette,
      child: Row(
        children: [
          Icon(Icons.image_outlined, color: palette.accent),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              block.caption ?? block.altText ?? block.mediaUrl ?? 'Media block',
              style: TextStyle(color: palette.muted),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionBlock extends StatelessWidget {
  const _ActionBlock({required this.block, required this.palette});

  final SectionBlock block;
  final PageSectionPreviewPalette palette;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final action in block.actions)
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              foregroundColor: palette.foreground,
              side: BorderSide(color: palette.line),
            ),
            child: Text(action.label ?? 'CTA'),
          ),
      ],
    );
  }
}

class _ItemGrid extends StatelessWidget {
  const _ItemGrid({
    required this.block,
    required this.section,
    required this.palette,
  });

  final SectionBlock block;
  final PageSection section;
  final PageSectionPreviewPalette palette;

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
            for (final item in block.items)
              _Panel(
                palette: palette,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Label(item.label ?? block.type.label, palette),
                    _Title(item.title ?? block.type.label, palette),
                    Expanded(child: _Copy(item.copy ?? '', palette)),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.palette, required this.child});

  final PageSectionPreviewPalette palette;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: palette.line),
        color: palette.itemBackground,
      ),
      child: Padding(padding: const EdgeInsets.all(14), child: child),
    );
  }
}

class _Label extends Text {
  _Label(super.data, PageSectionPreviewPalette palette)
    : super(
        style: TextStyle(
          color: palette.accent,
          fontSize: 11,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.2,
        ),
      );
}

class _Title extends Text {
  _Title(super.data, PageSectionPreviewPalette palette)
    : super(
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: palette.foreground,
          fontWeight: FontWeight.w900,
        ),
      );
}

class _Copy extends Text {
  _Copy(super.data, PageSectionPreviewPalette palette)
    : super(
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: palette.muted, height: 1.35),
      );
}
