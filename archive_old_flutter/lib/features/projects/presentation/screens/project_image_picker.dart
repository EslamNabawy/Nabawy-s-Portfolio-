import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

import '../../../../core/errors/app_exception.dart';
import '../../domain/repositories/project_repository.dart';
import '../../domain/value_objects/project_image_upload.dart';
import 'project_form_support.dart';

Future<String?> pickAndUploadProjectImage(ProjectRepository repository) async {
  final result = await FilePicker.pickFiles(
    type: FileType.custom,
    allowedExtensions: const ['jpg', 'jpeg', 'png', 'webp', 'avif'],
    withData: true,
  );
  if (result == null || result.files.isEmpty) {
    return null;
  }

  final file = result.files.single;
  final bytes = file.bytes;
  if (bytes == null) {
    throw const ValidationFailure('Could not read selected image bytes.');
  }

  return repository.uploadProjectImage(
    ProjectImageUpload(
      bytes: Uint8List.fromList(bytes),
      fileName: file.name,
      contentType: contentTypeFor(file.extension),
    ),
  );
}
