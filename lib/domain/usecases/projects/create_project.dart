import 'package:claude_chat_clone/core/error/failures.dart';
import 'package:claude_chat_clone/domain/entities/entities.dart';
import 'package:claude_chat_clone/domain/repositories/repositories.dart';
import 'package:claude_chat_clone/domain/usecases/base_usecase.dart';
import 'package:dartz/dartz.dart';

/// Use case for creating a new project
class CreateProject extends UseCase<String, CreateProjectParams> {
  final ProjectRepository repository;

  CreateProject(this.repository);

  @override
  Future<Either<Failure, String>> call(CreateProjectParams params) async {
    // Validate parameters
    final validationError = params.validate();
    if (validationError != null) {
      return Left(validationError);
    }

    // Check if project name is unique
    final nameUniqueResult =
        await repository.isProjectNameUnique(params.project.name);

    // Handle name uniqueness check failure
    if (nameUniqueResult.isLeft()) {
      return nameUniqueResult.fold(
        (failure) => Left(failure),
        (isUnique) => Right(''), // This won't happen due to early return
      );
    }

    // Extract the result
    final isNameUnique = nameUniqueResult.getOrElse(() => false);

    // Return error if name is not unique
    if (!isNameUnique) {
      return Left(ProjectFailure.nameAlreadyExists(params.project.name));
    }

    // Call repository to create project
    return await repository.createProject(params.project);
  }
}

/// Parameters for the CreateProject use case
class CreateProjectParams extends BaseParams {
  /// Project to create
  final Project project;

  const CreateProjectParams({
    required this.project,
  });

  @override
  int get hashCode => project.hashCode;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CreateProjectParams && other.project == project;
  }

  @override
  Failure? validate() {
    if (!project.hasValidName) {
      return const ValidationFailure(message: 'Project name cannot be empty');
    }

    return super.validate();
  }
}
