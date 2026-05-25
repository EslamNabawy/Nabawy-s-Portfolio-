import '../entities/project.dart';
import '../value_objects/project_image_upload.dart';

abstract interface class ProjectRepository {
  Future<List<Project>> listProjects({bool includeDrafts = true});

  Future<Project> getProject(String id);

  Future<Project> createProject(Project project, {ProjectImageUpload? image});

  Future<Project> updateProject(Project project, {ProjectImageUpload? image});

  Future<void> deleteProject(String id);

  Future<String> uploadProjectImage(ProjectImageUpload image);
}
