import 'package:flutter/widgets.dart';

import '../../domain/entities/project.dart';
import 'project_form_mapper.dart';

final class ProjectFormControllers {
  ProjectFormControllers._({
    required this.title,
    required this.slug,
    required this.shortDescription,
    required this.description,
    required this.techStack,
    required this.role,
    required this.impact,
    required this.architectureNotes,
    required this.caseStudyMarkdown,
    required this.githubUrl,
    required this.liveUrl,
    required this.imageUrl,
    required this.galleryImages,
    required this.displayOrder,
  });

  factory ProjectFormControllers.fromProject(Project? project) {
    return ProjectFormControllers._(
      title: TextEditingController(text: project?.title ?? ''),
      slug: TextEditingController(text: project?.slug ?? ''),
      shortDescription: TextEditingController(
        text: project?.shortDescription ?? '',
      ),
      description: TextEditingController(text: project?.description ?? ''),
      techStack: TextEditingController(
        text: project?.techStack.join(', ') ?? '',
      ),
      role: TextEditingController(text: project?.role ?? ''),
      impact: TextEditingController(text: project?.impact ?? ''),
      architectureNotes: TextEditingController(
        text: project?.architectureNotes ?? '',
      ),
      caseStudyMarkdown: TextEditingController(
        text: project?.caseStudyMarkdown ?? '',
      ),
      githubUrl: TextEditingController(text: project?.githubUrl ?? ''),
      liveUrl: TextEditingController(text: project?.liveUrl ?? ''),
      imageUrl: TextEditingController(text: project?.imageUrl ?? ''),
      galleryImages: TextEditingController(text: galleryImageText(project)),
      displayOrder: TextEditingController(
        text: (project?.displayOrder ?? 0).toString(),
      ),
    );
  }

  final TextEditingController title;
  final TextEditingController slug;
  final TextEditingController shortDescription;
  final TextEditingController description;
  final TextEditingController techStack;
  final TextEditingController role;
  final TextEditingController impact;
  final TextEditingController architectureNotes;
  final TextEditingController caseStudyMarkdown;
  final TextEditingController githubUrl;
  final TextEditingController liveUrl;
  final TextEditingController imageUrl;
  final TextEditingController galleryImages;
  final TextEditingController displayOrder;

  List<TextEditingController> get all => [
    title,
    slug,
    shortDescription,
    description,
    techStack,
    role,
    impact,
    architectureNotes,
    caseStudyMarkdown,
    githubUrl,
    liveUrl,
    imageUrl,
    galleryImages,
    displayOrder,
  ];

  String stateKey({required bool isPublished, required bool featured}) {
    return [
      for (final controller in all) controller.text,
      isPublished.toString(),
      featured.toString(),
    ].join('\u001f');
  }

  void dispose() {
    for (final controller in all) {
      controller.dispose();
    }
  }
}
