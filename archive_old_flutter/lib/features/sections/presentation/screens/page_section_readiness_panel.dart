import 'package:flutter/material.dart';

import '../../../../shared/ui/admin_components.dart';
import '../../../projects/presentation/screens/project_form_support.dart';
import '../../domain/entities/page_section.dart';
import '../../domain/entities/page_section_readiness.dart';
import 'page_section_form_support.dart';

class PageSectionReadinessPanel extends StatelessWidget {
  const PageSectionReadinessPanel({
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
    required this.displayOrder,
    required this.isPublished,
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
  final TextEditingController displayOrder;
  final bool isPublished;

  @override
  Widget build(BuildContext context) {
    try {
      final readiness = assessPageSectionReadiness(_section());
      return ProjectFormSection(
        title: 'Publish Readiness',
        children: [ValidationList(messages: readiness.messages)],
      );
    } catch (error) {
      return ErrorPanel(message: 'Readiness unavailable: $error');
    }
  }

  PageSection _section() {
    return PageSection(
      sectionKey: sectionKey.text.trim(),
      title: title.text.trim(),
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
      displayOrder: int.tryParse(displayOrder.text.trim()) ?? 0,
      isPublished: isPublished,
    );
  }
}
