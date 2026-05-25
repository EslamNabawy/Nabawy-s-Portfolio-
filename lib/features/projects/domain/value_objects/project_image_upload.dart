import 'dart:typed_data';

import '../../../../core/errors/app_exception.dart';

final class ProjectImageUpload {
  const ProjectImageUpload({
    required this.bytes,
    required this.fileName,
    required this.contentType,
  });

  static const int maxBytes = 5 * 1024 * 1024;
  static const Set<String> allowedContentTypes = <String>{
    'image/jpeg',
    'image/png',
    'image/webp',
    'image/avif',
  };

  final Uint8List bytes;
  final String fileName;
  final String contentType;

  String get extension {
    final normalized = fileName.trim().toLowerCase();
    final dotIndex = normalized.lastIndexOf('.');
    if (dotIndex < 0 || dotIndex == normalized.length - 1) {
      throw const ValidationFailure('Image file name must include extension.');
    }
    return normalized.substring(dotIndex + 1);
  }

  void validate() {
    if (bytes.isEmpty) {
      throw const ValidationFailure('Image file is empty.');
    }
    if (bytes.length > maxBytes) {
      throw const ValidationFailure('Image file exceeds 5 MB limit.');
    }
    if (!allowedContentTypes.contains(contentType.toLowerCase())) {
      throw ValidationFailure('Unsupported image content type: $contentType.');
    }
  }
}
