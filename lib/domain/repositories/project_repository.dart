import 'package:claude_chat_clone/core/error/failures.dart';
import 'package:claude_chat_clone/domain/entities/entities.dart';
import 'package:dartz/dartz.dart';

/// Abstract repository interface for project-related operations
///
/// Defines the contract for project and artifact data operations that will be
/// implemented by the data layer. Uses Either<Failure, T> for comprehensive error handling.
abstract class ProjectRepository {
  // ============================================================================
  // PROJECT CRUD OPERATIONS
  // ============================================================================

  /// Add an artifact to a project
  ///
  /// Returns [Right] with void on success, [Left] with [ProjectFailure] on error
  Future<Either<Failure, void>> addArtifactToProject(
    String projectId,
    Artifact artifact,
  );

  /// Create a new project
  ///
  /// Returns [Right] with the project ID on success, [Left] with [ProjectFailure] on error
  Future<Either<Failure, String>> createProject(Project project);

  /// Delete a project and all its associated data
  ///
  /// Returns [Right] with void on success, [Left] with [ProjectFailure] on error
  Future<Either<Failure, void>> deleteProject(String projectId);

  /// Get all projects for the current user
  ///
  /// Returns [Right] with list of projects, [Left] with [ProjectFailure] on error
  Future<Either<Failure, List<Project>>> getAllProjects();

  /// Get a specific project by ID
  ///
  /// Returns [Right] with project (nullable), [Left] with [ProjectFailure] on error
  Future<Either<Failure, Project?>> getProject(String projectId);

  // ============================================================================
  // PROJECT QUERY OPERATIONS
  // ============================================================================

  /// Get all artifacts for a specific project
  ///
  /// Returns [Right] with list of artifacts, [Left] with [ProjectFailure] on error
  Future<Either<Failure, List<Artifact>>> getProjectArtifacts(String projectId);

  /// Get projects by exact name match
  ///
  /// Returns [Right] with list of matching projects, [Left] with [ProjectFailure] on error
  Future<Either<Failure, List<Project>>> getProjectsByName(String name);

  /// Check if a project name is unique
  ///
  /// Optionally exclude a specific project ID from the uniqueness check
  /// Returns [Right] with boolean result, [Left] with [ProjectFailure] on error
  Future<Either<Failure, bool>> isProjectNameUnique(
    String name, {
    String? excludeProjectId,
  });

  /// Check if a project exists
  ///
  /// Returns [Right] with boolean result, [Left] with [ProjectFailure] on error
  Future<Either<Failure, bool>> projectExists(String projectId);

  // ============================================================================
  // ARTIFACT OPERATIONS
  // ============================================================================

  /// Remove an artifact from a project
  ///
  /// Returns [Right] with void on success, [Left] with [ProjectFailure] on error
  Future<Either<Failure, void>> removeArtifactFromProject(
    String projectId,
    String artifactId,
  );

  /// Search projects by query string
  ///
  /// Searches through project names and descriptions
  /// Returns [Right] with matching projects, [Left] with [ProjectFailure] on error
  Future<Either<Failure, List<Project>>> searchProjects(String query);

  /// Update an existing project
  ///
  /// Returns [Right] with void on success, [Left] with [ProjectFailure] on error
  Future<Either<Failure, void>> updateProject(Project project);

  // ============================================================================
  // REAL-TIME OPERATIONS
  // ============================================================================

  /// Watch all projects in real-time
  ///
  /// Returns a stream that emits [Right] with all projects or [Left] with [ProjectFailure]
  Stream<Either<Failure, List<Project>>> watchAllProjects();

  /// Watch a specific project in real-time
  ///
  /// Returns a stream that emits [Right] with project (nullable) or [Left] with [ProjectFailure]
  Stream<Either<Failure, Project?>> watchProject(String projectId);
}
