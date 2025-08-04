import 'package:claude_chat_clone/core/error/failures.dart';
import 'package:claude_chat_clone/domain/entities/entities.dart';
import 'package:claude_chat_clone/domain/repositories/repositories.dart';
import 'package:claude_chat_clone/domain/usecases/base_usecase.dart';
import 'package:dartz/dartz.dart';

/// Use case for updating an existing project
class UpdateProject extends UseCase<void, UpdateProjectParams> {
  final ProjectRepository repository;

  UpdateProject(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateProjectParams params) async {
    // Validate parameters
    final validationError = params.validate();
    if (validationError != null) {
      return Left(validationError);
    }

    // Get the original project to check if name has changed
    final originalProjectResult =
        await repository.getProject(params.project.id);

    // If we couldn't get the project, just try to update anyway
    if (originalProjectResult.isLeft()) {
      return await repository.updateProject(params.project);
    }

    // Extract the original project
    final originalProject = originalProjectResult.getOrElse(() => null);

    // If original project doesn't exist, just try to update anyway
    if (originalProject == null) {
      return await repository.updateProject(params.project);
    }

    // Check if name has changed
    if (originalProject.name != params.project.name) {
      // Check if new name is unique
      final nameUniqueResult = await repository.isProjectNameUnique(
        params.project.name,
        excludeProjectId: params.project.id,
      );

      // Handle name uniqueness check failure
      if (nameUniqueResult.isLeft()) {
        return nameUniqueResult.fold(
          (failure) => Left(failure),
          (isUnique) => Right(null), // This won't happen due to early return
        );
      }

      // Extract the result
      final isNameUnique = nameUniqueResult.getOrElse(() => false);

      // Return error if name is not unique
      if (!isNameUnique) {
        return Left(ProjectFailure.nameAlreadyExists(params.project.name));
      }
    }

    // Call repository to update project
    return await repository.updateProject(params.project);
  }
}

/// Parameters for the UpdateProject use case
class UpdateProjectParams extends BaseParams {
  /// Project to update
  final Project project;

  const UpdateProjectParams({
    required this.project,
  });

  @override
  int get hashCode => project.hashCode;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UpdateProjectParams && other.project == project;
  }

  @override
  Failure? validate() {
    if (project.id.trim().isEmpty) {
      return const ValidationFailure(message: 'Project ID cannot be empty');
    }

    if (!project.hasValidName) {
      return const ValidationFailure(message: 'Project name cannot be empty');
    }

    return super.validate();
  }
}
