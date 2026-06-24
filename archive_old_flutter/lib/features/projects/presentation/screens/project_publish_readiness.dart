import 'project_form_support.dart';

enum PublishIssueSeverity { blocker, warning }

final class PublishReadinessIssue {
  const PublishReadinessIssue({required this.message, required this.severity});

  final String message;
  final PublishIssueSeverity severity;
}

List<PublishReadinessIssue> assessProjectPublishReadiness({
  required String title,
  required String slug,
  required String shortDescription,
  required String description,
  required String techStack,
  required String imageUrl,
  required String galleryImages,
  required String githubUrl,
  required String liveUrl,
  required String role,
  required String impact,
  required String architectureNotes,
  required String caseStudyMarkdown,
}) {
  final issues = <PublishReadinessIssue>[];

  void blocker(String message) {
    issues.add(
      PublishReadinessIssue(
        message: message,
        severity: PublishIssueSeverity.blocker,
      ),
    );
  }

  void warning(String message) {
    issues.add(
      PublishReadinessIssue(
        message: message,
        severity: PublishIssueSeverity.warning,
      ),
    );
  }

  if (optionalText(title) == null) {
    blocker('Title is required.');
  }
  if (validateSlug(slug) != null) {
    blocker('Slug must be valid before publishing.');
  }
  if (optionalText(description) == null) {
    blocker('Markdown description is required.');
  }
  if (optionalText(shortDescription) == null) {
    blocker('Short description is required for project cards.');
  }
  if (splitTechStack(techStack).isEmpty) {
    blocker('At least one tech stack item is required.');
  }
  if (optionalText(imageUrl) == null) {
    blocker('Primary image URL is required.');
  }

  final linkCount = [
    optionalText(githubUrl),
    optionalText(liveUrl),
  ].whereType<String>().length;
  if (linkCount == 0) {
    warning('Add a GitHub or live URL so visitors can inspect the work.');
  }
  if (optionalText(role) == null) {
    warning('Add your role to strengthen the case-study page.');
  }
  if (optionalText(impact) == null) {
    warning('Add impact or outcome for recruiter scanning.');
  }
  if (optionalText(architectureNotes) == null) {
    warning('Add architecture notes for technical readers.');
  }
  if (optionalText(caseStudyMarkdown) == null) {
    warning('Add case-study Markdown for the detail page.');
  }
  if (optionalText(galleryImages) == null) {
    warning('Add gallery images when you have more visual evidence.');
  }

  return issues;
}

bool hasPublishBlockers(List<PublishReadinessIssue> issues) {
  return issues.any((issue) => issue.severity == PublishIssueSeverity.blocker);
}
