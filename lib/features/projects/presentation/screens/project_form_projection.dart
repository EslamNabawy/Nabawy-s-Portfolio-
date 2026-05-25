import '../../domain/entities/project.dart';
import 'project_form_controllers.dart';
import 'project_form_mapper.dart';
import 'project_publish_readiness.dart';

Project projectFromControllerSet({
  required Project? existingProject,
  required ProjectFormControllers controllers,
  required bool isPublished,
  required bool featured,
}) {
  return projectFromFormControllers(
    existingProject: existingProject,
    title: controllers.title,
    slug: controllers.slug,
    shortDescription: controllers.shortDescription,
    description: controllers.description,
    role: controllers.role,
    impact: controllers.impact,
    architectureNotes: controllers.architectureNotes,
    caseStudyMarkdown: controllers.caseStudyMarkdown,
    techStack: controllers.techStack,
    githubUrl: controllers.githubUrl,
    liveUrl: controllers.liveUrl,
    imageUrl: controllers.imageUrl,
    galleryImages: controllers.galleryImages,
    displayOrder: controllers.displayOrder,
    isPublished: isPublished,
    featured: featured,
  );
}

List<PublishReadinessIssue> assessControllerPublishReadiness(
  ProjectFormControllers controllers,
) {
  return assessProjectPublishReadiness(
    title: controllers.title.text,
    slug: controllers.slug.text,
    shortDescription: controllers.shortDescription.text,
    description: controllers.description.text,
    techStack: controllers.techStack.text,
    imageUrl: controllers.imageUrl.text,
    galleryImages: controllers.galleryImages.text,
    githubUrl: controllers.githubUrl.text,
    liveUrl: controllers.liveUrl.text,
    role: controllers.role.text,
    impact: controllers.impact.text,
    architectureNotes: controllers.architectureNotes.text,
    caseStudyMarkdown: controllers.caseStudyMarkdown.text,
  );
}

List<String> galleryImageUrlsFromController(
  ProjectFormControllers controllers,
) {
  return projectImageUrlsFromForm(
    imageUrl: '',
    galleryImages: controllers.galleryImages.text,
  );
}
