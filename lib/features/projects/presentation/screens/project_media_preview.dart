import 'package:flutter/material.dart';

import 'project_form_support.dart';

class ProjectMediaPreview extends StatelessWidget {
  const ProjectMediaPreview({
    super.key,
    required this.primaryImageUrl,
    required this.galleryImageUrls,
    required this.onRemoveGalleryImage,
  });

  final String primaryImageUrl;
  final List<String> galleryImageUrls;
  final ValueChanged<String> onRemoveGalleryImage;

  @override
  Widget build(BuildContext context) {
    final primaryUrl = primaryImageUrl.trim();
    if (primaryUrl.isEmpty && galleryImageUrls.isEmpty) {
      return const ProjectFormSection(
        title: 'Media Preview',
        children: [Text('No images added yet.')],
      );
    }

    return ProjectFormSection(
      title: 'Media Preview',
      children: [
        if (primaryUrl.isNotEmpty) ...[
          Text('Primary image', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          _ImagePreviewTile(url: primaryUrl, label: 'Primary'),
        ],
        if (galleryImageUrls.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text('Gallery', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final url in galleryImageUrls)
                SizedBox(
                  width: 220,
                  child: _ImagePreviewTile(
                    url: url,
                    label: 'Gallery',
                    onRemove: () => onRemoveGalleryImage(url),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _ImagePreviewTile extends StatelessWidget {
  const _ImagePreviewTile({
    required this.url,
    required this.label,
    this.onRemove,
  });

  final String url;
  final String label;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(8),
              ),
              child: Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const _ImageError(),
                loadingBuilder: (context, child, progress) {
                  if (progress == null) {
                    return child;
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ),
                if (onRemove != null)
                  IconButton(
                    tooltip: 'Remove image',
                    onPressed: onRemove,
                    icon: const Icon(Icons.delete_outline),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ImageError extends StatelessWidget {
  const _ImageError();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Color(0xFFFEE2E2),
      child: Center(child: Text('Image failed to load')),
    );
  }
}
