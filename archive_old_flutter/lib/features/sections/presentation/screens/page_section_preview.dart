import 'package:flutter/material.dart';

import '../../domain/entities/page_section.dart';
import '../../domain/entities/section_block.dart';
import 'page_section_block_preview.dart';

class PageSectionPreview extends StatelessWidget {
  const PageSectionPreview({super.key, required this.section});

  final PageSection section;

  @override
  Widget build(BuildContext context) {
    final colors = PageSectionPreviewPalette.forTone(section.tone);
    final blocks = sectionBlocksFromContent(section.contentJson);
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
            for (final block in blocks) ...[
              const SizedBox(height: 14),
              PageSectionBlockPreview(
                block: block,
                section: section,
                palette: colors,
              ),
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
