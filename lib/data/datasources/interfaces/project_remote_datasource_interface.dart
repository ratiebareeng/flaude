import 'package:claude_chat_clone/data/models/data_models.dart';

/// Abstract interface for project remote data operations
abstract class ProjectRemoteDatasource {
  // Artifact operations
  Future<void> addArtifactToProject(String projectId, ArtifactDTO artifact);
  // Project CRUD operations
  Future<String> createProject(ProjectDTO project);
  Future<void> deleteProject(String projectId);
  Future<List<ProjectDTO>> getAllProjects();
  Future<ProjectDTO?> getProject(String projectId);
  Future<List<ArtifactDTO>> getProjectArtifacts(String projectId);

  Future<List<ProjectDTO>> getProjectsByName(String name);
  // Utility operations
  Future<bool> isProjectNameUnique(String name, {String? excludeProjectId});

  Future<bool> projectExists(String projectId);
  Future<void> removeArtifactFromProject(String projectId, String artifactId);

  // Search and filter operations
  Future<List<ProjectDTO>> searchProjects(String query);
  Future<void> updateProject(ProjectDTO project);
  // Stream operations for real-time updates
  Stream<List<ProjectDTO>> watchAllProjects();

  Stream<ProjectDTO?> watchProject(String projectId);
}
