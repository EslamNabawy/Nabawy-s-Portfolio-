import 'package:flutter/material.dart';

import 'project_form_controllers.dart';
import 'project_form_sections.dart';
import 'project_form_support.dart';
import 'project_markdown_preview.dart';
import 'project_media_preview.dart';
import 'project_publish_readiness.dart';
import 'project_readiness_panel.dart';

class ProjectFormBody extends StatelessWidget {
  const ProjectFormBody({
    super.key,
    required this.formKey,
    required this.controllers,
    required this.error,
    required this.isUploadingImage,
    required this.isSaving,
    required this.canSubmit,
    required this.hasUnsavedChanges,
    required this.isPublished,
    required this.featured,
    required this.submitLabel,
    required this.publishReadinessIssues,
    required this.galleryImageUrls,
    required this.onTitleChanged,
    required this.onPickAndUpload,
    required this.imageValidator,
    required this.onRemoveGalleryImage,
    required this.onPublishedChanged,
    required this.onFeaturedChanged,
    required this.onCancel,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final ProjectFormControllers controllers;
  final String? error;
  final bool isUploadingImage;
  final bool isSaving;
  final bool canSubmit;
  final bool hasUnsavedChanges;
  final bool isPublished;
  final bool featured;
  final String submitLabel;
  final List<PublishReadinessIssue> publishReadinessIssues;
  final List<String> galleryImageUrls;
  final ValueChanged<String> onTitleChanged;
  final VoidCallback onPickAndUpload;
  final String? Function(String?) imageValidator;
  final ValueChanged<String> onRemoveGalleryImage;
  final ValueChanged<bool> onPublishedChanged;
  final ValueChanged<bool> onFeaturedChanged;
  final VoidCallback onCancel;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final c = controllers;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1100),
        child: Form(
          key: formKey,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              if (error != null) ...[
                ErrorPanel(message: error!),
                const SizedBox(height: 16),
              ],
              ProjectContentSection(
                title: c.title,
                slug: c.slug,
                shortDescription: c.shortDescription,
                description: c.description,
                techStack: c.techStack,
                onTitleChanged: onTitleChanged,
              ),
              const SizedBox(height: 16),
              ProjectCaseStudySection(
                role: c.role,
                impact: c.impact,
                architectureNotes: c.architectureNotes,
                caseStudyMarkdown: c.caseStudyMarkdown,
              ),
              const SizedBox(height: 16),
              ProjectMarkdownPreviewSection(
                description: c.description.text,
                architectureNotes: c.architectureNotes.text,
                caseStudyMarkdown: c.caseStudyMarkdown.text,
              ),
              const SizedBox(height: 16),
              ProjectLinksSection(
                githubUrl: c.githubUrl,
                liveUrl: c.liveUrl,
                imageUrl: c.imageUrl,
                galleryImages: c.galleryImages,
                isUploadingImage: isUploadingImage,
                onPickAndUpload: onPickAndUpload,
                imageValidator: imageValidator,
              ),
              const SizedBox(height: 16),
              ProjectMediaPreview(
                primaryImageUrl: c.imageUrl.text,
                galleryImageUrls: galleryImageUrls,
                onRemoveGalleryImage: onRemoveGalleryImage,
              ),
              const SizedBox(height: 16),
              ProjectPublishingSection(
                displayOrder: c.displayOrder,
                isPublished: isPublished,
                featured: featured,
                onPublishedChanged: onPublishedChanged,
                onFeaturedChanged: onFeaturedChanged,
              ),
              const SizedBox(height: 16),
              ProjectReadinessPanel(
                isPublished: isPublished,
                issues: publishReadinessIssues,
              ),
              const SizedBox(height: 24),
              ProjectFormActions(
                isSaving: isSaving,
                canSubmit: canSubmit,
                hasUnsavedChanges: hasUnsavedChanges,
                submitLabel: submitLabel,
                onCancel: onCancel,
                onSubmit: onSubmit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
