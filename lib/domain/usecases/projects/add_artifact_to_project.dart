import 'package:claude_chat_clone/core/error/failures.dart';
import 'package:claude_chat_clone/domain/entities/entities.dart';
import 'package:claude_chat_clone/domain/repositories/repositories.dart';
import 'package:claude_chat_clone/domain/usecases/base_usecase.dart';
import 'package:dartz/dartz.dart';

/// Use case for adding an artifact to a project
class AddArtifactToProject extends UseCase<void, AddArtifactToProjectParams> {
  final ProjectRepository repository;

  AddArtifactToProject(this.repository);

  @override
  Future<Either<Failure, void>> call(AddArtifactToProjectParams params) async {
    // Validate parameters
    final validationError = params.validate();
    if (validationError != null) {
      return Left(validationError);
    }

    // Call repository to add artifact to project
    return await repository.addArtifactToProject(
        params.projectId, params.artifact);
  }
}

/// Parameters for the AddArtifactToProject use case
class AddArtifactToProjectParams extends BaseParams {
  /// ID of the project to add the artifact to
  final String projectId;

  /// Artifact to add
  final Artifact artifact;

  const AddArtifactToProjectParams({
    required this.projectId,
    required this.artifact,
  });

  @override
  int get hashCode => projectId.hashCode ^ artifact.hashCode;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AddArtifactToProjectParams &&
        other.projectId == projectId &&
        other.artifact == artifact;
  }

  @override
  Failure? validate() {
    if (projectId.trim().isEmpty) {
      return const ValidationFailure(message: 'Project ID cannot be empty');
    }

    if (artifact.id.trim().isEmpty) {
      return const ValidationFailure(message: 'Artifact ID cannot be empty');
    }

    if (artifact.title.trim().isEmpty) {
      return const ValidationFailure(message: 'Artifact title cannot be empty');
    }

    if (artifact.content.trim().isEmpty) {
      return const ValidationFailure(
          message: 'Artifact content cannot be empty');
    }

    return super.validate();
  }
}
