import 'package:flutter/material.dart';

import '../../../projects/presentation/screens/project_form_support.dart';
import '../../domain/entities/page_section.dart';
import 'page_section_form_support.dart';
import 'page_section_preview.dart';

class PageSectionLivePreview extends StatelessWidget {
  const PageSectionLivePreview({
    super.key,
    required this.title,
    required this.sectionKey,
    required this.eyebrow,
    required this.body,
    required this.placement,
    required this.sectionType,
    required this.layout,
    required this.tone,
    required this.density,
    required this.alignment,
    required this.contentJson,
    required this.designJson,
  });

  final TextEditingController title;
  final TextEditingController sectionKey;
  final TextEditingController eyebrow;
  final TextEditingController body;
  final PageSectionPlacement placement;
  final PageSectionType sectionType;
  final PageSectionLayout layout;
  final PageSectionTone tone;
  final PageSectionDensity density;
  final PageSectionAlignment alignment;
  final TextEditingController contentJson;
  final TextEditingController designJson;

  @override
  Widget build(BuildContext context) {
    try {
      return ProjectFormSection(
        title: 'Live Preview',
        children: [PageSectionPreview(section: _section())],
      );
    } catch (error) {
      return ErrorPanel(message: 'Preview unavailable: $error');
    }
  }

  PageSection _section() {
    return PageSection(
      sectionKey: sectionKey.text.trim().isEmpty
          ? 'preview-section'
          : sectionKey.text.trim(),
      title: title.text.trim().isEmpty ? 'Untitled Section' : title.text.trim(),
      eyebrow: optionalText(eyebrow.text),
      body: optionalText(body.text),
      placement: placement,
      sectionType: sectionType,
      layout: layout,
      tone: tone,
      density: density,
      alignment: alignment,
      contentJson: parseJsonObjectText(contentJson.text, 'Content JSON'),
      designJson: parseJsonObjectText(designJson.text, 'Design JSON'),
    );
  }
}
