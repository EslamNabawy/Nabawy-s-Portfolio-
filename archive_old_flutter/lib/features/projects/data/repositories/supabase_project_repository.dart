import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/utils/json_readers.dart';
import '../../domain/entities/project.dart';
import '../../domain/entities/project_image.dart';
import '../../domain/repositories/project_repository.dart';
import '../../domain/value_objects/project_image_upload.dart';

final class SupabaseProjectRepository implements ProjectRepository {
  const SupabaseProjectRepository(
    this._client, {
    this.bucketId = 'portfolio-assets',
  });

  final SupabaseClient _client;
  final String bucketId;

  static const _projectSelect = '*, project_images(*)';

  @override
  Future<List<Project>> listProjects({bool includeDrafts = true}) async {
    try {
      var query = _client.from('projects').select(_projectSelect);
      if (!includeDrafts) {
        query = query.eq('is_published', true);
      }
      final rows = await query
          .order('display_order', ascending: true)
          .order('created_at', ascending: false);
      return rows
          .map((row) => Project.fromJson(JsonMap.from(row)))
          .toList(growable: false);
    } on PostgrestException catch (error) {
      throw DataFailure(error.message, code: error.code, cause: error);
    } on FormatException catch (error) {
      throw DataFailure('Invalid project payload from Supabase.', cause: error);
    } catch (error) {
      throw DataFailure(
        'Unexpected failure while loading projects.',
        cause: error,
      );
    }
  }

  @override
  Future<Project> getProject(String id) async {
    try {
      final row = await _client
          .from('projects')
          .select(_projectSelect)
          .eq('id', id)
          .single();
      return Project.fromJson(JsonMap.from(row));
    } on PostgrestException catch (error) {
      throw DataFailure(error.message, code: error.code, cause: error);
    } on FormatException catch (error) {
      throw DataFailure('Invalid project payload from Supabase.', cause: error);
    } catch (error) {
      throw DataFailure(
        'Unexpected failure while loading project.',
        cause: error,
      );
    }
  }

  @override
  Future<Project> createProject(
    Project project, {
    ProjectImageUpload? image,
  }) async {
    try {
      final imageUrl = image == null
          ? project.imageUrl
          : await uploadProjectImage(image);
      final payload = project.copyWith(imageUrl: imageUrl).toJson()
        ..remove('id')
        ..remove('created_at')
        ..remove('updated_at');

      final row = await _client
          .from('projects')
          .insert(payload)
          .select()
          .single();
      final saved = Project.fromJson(JsonMap.from(row));
      await _replaceProjectImages(
        saved.id,
        project.copyWith(id: saved.id, imageUrl: imageUrl),
      );
      return getProject(saved.id!);
    } on AppException {
      rethrow;
    } on PostgrestException catch (error) {
      throw DataFailure(error.message, code: error.code, cause: error);
    } on FormatException catch (error) {
      throw DataFailure('Invalid project payload from Supabase.', cause: error);
    } catch (error) {
      throw DataFailure(
        'Unexpected failure while creating project.',
        cause: error,
      );
    }
  }

  @override
  Future<Project> updateProject(
    Project project, {
    ProjectImageUpload? image,
  }) async {
    final id = project.id;
    if (id == null || id.trim().isEmpty) {
      throw const ValidationFailure('Project id is required for update.');
    }

    try {
      final imageUrl = image == null
          ? project.imageUrl
          : await uploadProjectImage(image);
      final payload = project.copyWith(imageUrl: imageUrl).toJson()
        ..remove('id')
        ..remove('created_at')
        ..remove('updated_at');

      final row = await _client
          .from('projects')
          .update(payload)
          .eq('id', id)
          .select()
          .single();
      final saved = Project.fromJson(JsonMap.from(row));
      await _replaceProjectImages(
        saved.id,
        project.copyWith(imageUrl: imageUrl),
      );
      return getProject(saved.id!);
    } on AppException {
      rethrow;
    } on PostgrestException catch (error) {
      throw DataFailure(error.message, code: error.code, cause: error);
    } on FormatException catch (error) {
      throw DataFailure('Invalid project payload from Supabase.', cause: error);
    } catch (error) {
      throw DataFailure(
        'Unexpected failure while updating project.',
        cause: error,
      );
    }
  }

  @override
  Future<void> deleteProject(String id) async {
    try {
      await _client.from('projects').delete().eq('id', id);
    } on PostgrestException catch (error) {
      throw DataFailure(error.message, code: error.code, cause: error);
    } catch (error) {
      throw DataFailure(
        'Unexpected failure while deleting project.',
        cause: error,
      );
    }
  }

  @override
  Future<String> uploadProjectImage(ProjectImageUpload image) async {
    image.validate();
    final path = _buildProjectImagePath(image.extension);

    try {
      await _client.storage
          .from(bucketId)
          .uploadBinary(
            path,
            image.bytes,
            fileOptions: FileOptions(
              contentType: image.contentType,
              upsert: false,
            ),
          );
      return _client.storage.from(bucketId).getPublicUrl(path);
    } on StorageException catch (error) {
      throw StorageFailure(error.message, code: error.statusCode, cause: error);
    } catch (error) {
      throw StorageFailure(
        'Unexpected failure while uploading image.',
        cause: error,
      );
    }
  }

  String _buildProjectImagePath(String extension) {
    final timestamp = DateTime.now().toUtc().microsecondsSinceEpoch;
    return 'projects/$timestamp.$extension';
  }

  Future<void> _replaceProjectImages(String? projectId, Project project) async {
    if (projectId == null || projectId.trim().isEmpty) {
      throw const DataFailure('Project id was missing after save.');
    }

    await _client.from('project_images').delete().eq('project_id', projectId);
    final images = _normalizedImages(projectId, project);
    if (images.isEmpty) {
      return;
    }
    await _client
        .from('project_images')
        .insert(
          images
              .map(
                (image) => image.toJson()
                  ..remove('id')
                  ..remove('created_at')
                  ..remove('updated_at'),
              )
              .toList(growable: false),
        );
  }

  List<ProjectImage> _normalizedImages(String projectId, Project project) {
    final images = <ProjectImage>[];
    final seenUrls = <String>{};

    void addImage(ProjectImage image) {
      final url = image.imageUrl.trim();
      if (url.isEmpty || !seenUrls.add(url)) {
        return;
      }
      images.add(
        ProjectImage(
          projectId: projectId,
          imageUrl: url,
          altText: image.altText ?? '${project.title} screenshot',
          displayOrder: images.length,
        ),
      );
    }

    final primaryImageUrl = project.imageUrl;
    if (primaryImageUrl != null && primaryImageUrl.trim().isNotEmpty) {
      addImage(
        ProjectImage(
          projectId: projectId,
          imageUrl: primaryImageUrl,
          altText: '${project.title} primary screenshot',
        ),
      );
    }
    for (final image in project.images) {
      addImage(image);
    }
    return images;
  }
}
