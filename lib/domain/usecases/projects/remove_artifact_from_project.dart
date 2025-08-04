import 'package:claude_chat_clone/core/error/failures.dart';
import 'package:claude_chat_clone/domain/repositories/repositories.dart';
import 'package:claude_chat_clone/domain/usecases/base_usecase.dart';
import 'package:dartz/dartz.dart';

/// Use case for removing an artifact from a project
class RemoveArtifactFromProject
    extends UseCase<void, RemoveArtifactFromProjectParams> {
  final ProjectRepository repository;

  RemoveArtifactFromProject(this.repository);

  @override
  Future<Either<Failure, void>> call(
      RemoveArtifactFromProjectParams params) async {
    // Validate parameters
    final validationError = params.validate();
    if (validationError != null) {
      return Left(validationError);
    }

    // Call repository to remove artifact from project
    return await repository.removeArtifactFromProject(
        params.projectId, params.artifactId);
  }
}

/// Parameters for the RemoveArtifactFromProject use case
class RemoveArtifactFromProjectParams extends BaseParams {
  /// ID of the project containing the artifact
  final String projectId;

  /// ID of the artifact to remove
  final String artifactId;

  const RemoveArtifactFromProjectParams({
    required this.projectId,
    required this.artifactId,
  });

  @override
  int get hashCode => projectId.hashCode ^ artifactId.hashCode;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RemoveArtifactFromProjectParams &&
        other.projectId == projectId &&
        other.artifactId == artifactId;
  }

  @override
  Failure? validate() {
    if (projectId.trim().isEmpty) {
      return const ValidationFailure(message: 'Project ID cannot be empty');
    }

    if (artifactId.trim().isEmpty) {
      return const ValidationFailure(message: 'Artifact ID cannot be empty');
    }

    return super.validate();
  }
}
