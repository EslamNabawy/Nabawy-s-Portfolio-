import 'package:flutter/material.dart';

class ProjectFormSection extends StatelessWidget {
  const ProjectFormSection({
    super.key,
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

class ErrorPanel extends StatelessWidget {
  const ErrorPanel({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFFEE2E2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text(message, style: const TextStyle(color: Color(0xFF991B1B))),
      ),
    );
  }
}

class ImageUploadControl extends StatelessWidget {
  const ImageUploadControl({
    super.key,
    required this.isUploading,
    required this.onPressed,
  });

  final bool isUploading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        FilledButton.icon(
          onPressed: isUploading ? null : onPressed,
          icon: const Icon(Icons.upload_file),
          label: const Text('Pick and Upload Image'),
        ),
        const SizedBox(width: 12),
        if (isUploading)
          const Row(
            children: [
              SizedBox.square(
                dimension: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 8),
              Text('Uploading image...'),
            ],
          ),
      ],
    );
  }
}

class ProjectFormActions extends StatelessWidget {
  const ProjectFormActions({
    super.key,
    required this.isSaving,
    required this.canSubmit,
    required this.hasUnsavedChanges,
    required this.submitLabel,
    required this.onCancel,
    required this.onSubmit,
  });

  final bool isSaving;
  final bool canSubmit;
  final bool hasUnsavedChanges;
  final String submitLabel;
  final VoidCallback onCancel;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (hasUnsavedChanges) ...[
          const Text('Unsaved changes'),
          const SizedBox(width: 12),
        ],
        TextButton(
          onPressed: isSaving ? null : onCancel,
          child: const Text('Cancel'),
        ),
        const SizedBox(width: 12),
        FilledButton(
          onPressed: canSubmit ? onSubmit : null,
          child: isSaving
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(submitLabel),
        ),
      ],
    );
  }
}

String? Function(String?) requiredField(String label) {
  return (value) {
    if ((value ?? '').trim().isEmpty) {
      return '$label is required.';
    }
    return null;
  };
}

String? validateSlug(String? value) {
  final slug = value?.trim() ?? '';
  if (slug.isEmpty) {
    return 'Slug is required.';
  }
  if (!RegExp(r'^[a-z0-9]+(?:-[a-z0-9]+)*$').hasMatch(slug)) {
    return 'Use lowercase letters, numbers, and single hyphens.';
  }
  return null;
}

String? validateTechStack(String? value) {
  if (splitTechStack(value ?? '').isEmpty) {
    return 'Add at least one tech stack item.';
  }
  return null;
}

String? validateImageUrl(String? value) {
  final url = value?.trim() ?? '';
  if (url.isEmpty) {
    return null;
  }
  return validateOptionalUrl(url);
}

String? validateOptionalUrlList(String? value) {
  final raw = value?.trim() ?? '';
  if (raw.isEmpty) {
    return null;
  }
  final urls = raw
      .split(RegExp(r'[\n,]+'))
      .map((item) => item.trim())
      .where((item) => item.isNotEmpty);
  for (final url in urls) {
    final error = validateOptionalUrl(url);
    if (error != null) {
      return 'Invalid image URL: $url';
    }
  }
  return null;
}

String? validateOptionalUrl(String? value) {
  final url = value?.trim() ?? '';
  if (url.isEmpty) {
    return null;
  }
  final parsed = Uri.tryParse(url);
  if (parsed == null || !parsed.hasScheme || parsed.host.trim().isEmpty) {
    return 'Enter a valid absolute URL.';
  }
  return null;
}

String? validateDisplayOrder(String? value) {
  final parsed = int.tryParse(value?.trim() ?? '');
  if (parsed == null) {
    return 'Display order must be a whole number.';
  }
  return null;
}

List<String> splitTechStack(String value) {
  return value
      .split(',')
      .map((item) => item.trim())
      .where((item) => item.isNotEmpty)
      .toList(growable: false);
}

String? optionalText(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

String contentTypeFor(String? extension) {
  return switch (extension?.toLowerCase()) {
    'jpg' || 'jpeg' => 'image/jpeg',
    'png' => 'image/png',
    'webp' => 'image/webp',
    'avif' => 'image/avif',
    _ => throw UnsupportedError('Unsupported image extension: $extension'),
  };
}
