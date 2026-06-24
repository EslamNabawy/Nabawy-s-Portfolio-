import 'package:flutter/material.dart';

import 'project_form_support.dart';

class ProjectContentSection extends StatelessWidget {
  const ProjectContentSection({
    super.key,
    required this.title,
    required this.slug,
    required this.shortDescription,
    required this.description,
    required this.techStack,
    required this.onTitleChanged,
  });

  final TextEditingController title;
  final TextEditingController slug;
  final TextEditingController shortDescription;
  final TextEditingController description;
  final TextEditingController techStack;
  final ValueChanged<String> onTitleChanged;

  @override
  Widget build(BuildContext context) {
    return ProjectFormSection(
      title: 'Content',
      children: [
        TextFormField(
          controller: title,
          decoration: const InputDecoration(labelText: 'Title'),
          validator: requiredField('Title'),
          onChanged: onTitleChanged,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: slug,
          decoration: const InputDecoration(labelText: 'Slug'),
          validator: validateSlug,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: shortDescription,
          decoration: const InputDecoration(
            labelText: 'Short Description',
            helperText: 'Compact card summary for recruiter scanning.',
          ),
          maxLines: 2,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: description,
          decoration: const InputDecoration(
            labelText: 'Markdown Description',
            alignLabelWithHint: true,
          ),
          minLines: 7,
          maxLines: 12,
          validator: requiredField('Description'),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: techStack,
          decoration: const InputDecoration(
            labelText: 'Tech Stack',
            helperText: 'Comma-separated values.',
          ),
          validator: validateTechStack,
        ),
      ],
    );
  }
}

class ProjectLinksSection extends StatelessWidget {
  const ProjectLinksSection({
    super.key,
    required this.githubUrl,
    required this.liveUrl,
    required this.imageUrl,
    required this.galleryImages,
    required this.isUploadingImage,
    required this.onPickAndUpload,
    required this.imageValidator,
  });

  final TextEditingController githubUrl;
  final TextEditingController liveUrl;
  final TextEditingController imageUrl;
  final TextEditingController galleryImages;
  final bool isUploadingImage;
  final VoidCallback onPickAndUpload;
  final String? Function(String?) imageValidator;

  @override
  Widget build(BuildContext context) {
    return ProjectFormSection(
      title: 'Links and Media',
      children: [
        TextFormField(
          controller: githubUrl,
          decoration: const InputDecoration(labelText: 'GitHub URL'),
          validator: validateOptionalUrl,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: liveUrl,
          decoration: const InputDecoration(labelText: 'Live URL'),
          validator: validateOptionalUrl,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: imageUrl,
          decoration: const InputDecoration(
            labelText: 'Primary Image URL',
            helperText: 'Paste an external URL or upload to Supabase Storage.',
          ),
          validator: imageValidator,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: galleryImages,
          decoration: const InputDecoration(
            labelText: 'Gallery Image URLs',
            helperText: 'One URL per line. Optional.',
            alignLabelWithHint: true,
          ),
          minLines: 3,
          maxLines: 6,
          validator: validateOptionalUrlList,
        ),
        const SizedBox(height: 12),
        ImageUploadControl(
          isUploading: isUploadingImage,
          onPressed: onPickAndUpload,
        ),
      ],
    );
  }
}

class ProjectCaseStudySection extends StatelessWidget {
  const ProjectCaseStudySection({
    super.key,
    required this.role,
    required this.impact,
    required this.architectureNotes,
    required this.caseStudyMarkdown,
  });

  final TextEditingController role;
  final TextEditingController impact;
  final TextEditingController architectureNotes;
  final TextEditingController caseStudyMarkdown;

  @override
  Widget build(BuildContext context) {
    return ProjectFormSection(
      title: 'Case Study',
      children: [
        TextFormField(
          controller: role,
          decoration: const InputDecoration(labelText: 'Role'),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: impact,
          decoration: const InputDecoration(
            labelText: 'Impact',
            helperText: 'Outcome, metric, or strongest result.',
          ),
          maxLines: 2,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: architectureNotes,
          decoration: const InputDecoration(
            labelText: 'Architecture Notes',
            alignLabelWithHint: true,
          ),
          minLines: 3,
          maxLines: 6,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: caseStudyMarkdown,
          decoration: const InputDecoration(
            labelText: 'Case Study Markdown',
            alignLabelWithHint: true,
          ),
          minLines: 6,
          maxLines: 12,
        ),
      ],
    );
  }
}

class ProjectPublishingSection extends StatelessWidget {
  const ProjectPublishingSection({
    super.key,
    required this.displayOrder,
    required this.isPublished,
    required this.featured,
    required this.onPublishedChanged,
    required this.onFeaturedChanged,
  });

  final TextEditingController displayOrder;
  final bool isPublished;
  final bool featured;
  final ValueChanged<bool> onPublishedChanged;
  final ValueChanged<bool> onFeaturedChanged;

  @override
  Widget build(BuildContext context) {
    return ProjectFormSection(
      title: 'Publishing',
      children: [
        TextFormField(
          controller: displayOrder,
          decoration: const InputDecoration(labelText: 'Display Order'),
          keyboardType: TextInputType.number,
          validator: validateDisplayOrder,
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: isPublished,
          title: const Text('Published'),
          subtitle: const Text(
            'Visible on the public portfolio. Requires image and tech stack.',
          ),
          onChanged: onPublishedChanged,
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: featured,
          title: const Text('Featured'),
          subtitle: const Text('Prioritize this project on the public site.'),
          onChanged: onFeaturedChanged,
        ),
      ],
    );
  }
}
