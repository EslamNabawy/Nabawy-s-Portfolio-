import 'package:flutter/widgets.dart';

import '../../domain/entities/project.dart';
import '../../domain/entities/project_image.dart';
import 'project_form_support.dart';

Project projectFromFormControllers({
  required Project? existingProject,
  required TextEditingController title,
  required TextEditingController slug,
  required TextEditingController shortDescription,
  required TextEditingController description,
  required TextEditingController role,
  required TextEditingController impact,
  required TextEditingController architectureNotes,
  required TextEditingController caseStudyMarkdown,
  required TextEditingController techStack,
  required TextEditingController githubUrl,
  required TextEditingController liveUrl,
  required TextEditingController imageUrl,
  required TextEditingController galleryImages,
  required TextEditingController displayOrder,
  required bool isPublished,
  required bool featured,
}) {
  return Project(
    id: existingProject?.id,
    title: title.text.trim(),
    slug: slug.text.trim(),
    description: description.text.trim(),
    shortDescription: optionalText(shortDescription.text),
    role: optionalText(role.text),
    impact: optionalText(impact.text),
    architectureNotes: optionalText(architectureNotes.text),
    caseStudyMarkdown: optionalText(caseStudyMarkdown.text),
    techStack: splitTechStack(techStack.text),
    images: projectImagesFromForm(
      title: title.text,
      imageUrl: imageUrl.text,
      galleryImages: galleryImages.text,
    ),
    githubUrl: optionalText(githubUrl.text),
    liveUrl: optionalText(liveUrl.text),
    imageUrl: optionalText(imageUrl.text),
    isPublished: isPublished,
    featured: featured,
    displayOrder: int.parse(displayOrder.text.trim()),
  );
}

List<ProjectImage> projectImagesFromForm({
  required String title,
  required String imageUrl,
  required String galleryImages,
}) {
  final urls = projectImageUrlsFromForm(
    imageUrl: imageUrl,
    galleryImages: galleryImages,
  );
  return [
    for (var index = 0; index < urls.length; index++)
      ProjectImage(
        imageUrl: urls[index],
        altText: '${title.trim()} image ${index + 1}',
        displayOrder: index,
      ),
  ];
}

List<String> projectImageUrlsFromForm({
  required String imageUrl,
  required String galleryImages,
}) {
  final urls = <String>[];

  void addUrl(String? value) {
    final url = value?.trim() ?? '';
    if (url.isNotEmpty && !urls.contains(url)) {
      urls.add(url);
    }
  }

  addUrl(imageUrl);
  for (final rawUrl in galleryImages.split(RegExp(r'[\n,]+'))) {
    addUrl(rawUrl);
  }
  return urls;
}

String galleryImageText(Project? project) {
  if (project == null || project.images.isEmpty) {
    return '';
  }
  final primaryUrl = project.imageUrl?.trim();
  return project.images
      .map((image) => image.imageUrl.trim())
      .where((url) => url.isNotEmpty && url != primaryUrl)
      .join('\n');
}
