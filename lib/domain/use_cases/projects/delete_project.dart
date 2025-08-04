import 'package:claude_chat_clone/core/error/failures.dart';
import 'package:claude_chat_clone/domain/repositories/repositories.dart';
import 'package:claude_chat_clone/domain/use_cases/base_usecase.dart';
import 'package:dartz/dartz.dart';

/// Use case for deleting a project
class DeleteProject extends UseCase<void, DeleteProjectParams> {
  final ProjectRepository repository;
  final ChatRepository chatRepository;

  DeleteProject(this.repository, this.chatRepository);

  @override
  Future<Either<Failure, void>> call(DeleteProjectParams params) async {
    // Validate parameters
    final validationError = params.validate();
    if (validationError != null) {
      return Left(validationError);
    }

    // Check if project has associated chats
    final chatCountResult =
        await chatRepository.getChatCountForProject(params.projectId);

    // Return error if chat count check fails
    if (chatCountResult.isLeft()) {
      return chatCountResult.fold(
        (failure) => Left(failure),
        (_) => Right(null), // This won't happen due to early return
      );
    }

    // Extract chat count
    final chatCount = chatCountResult.getOrElse(() => 0);

    // Check if project has chats and force flag is not set
    if (chatCount > 0 && !params.force) {
      return Left(ProjectFailure.hasChats());
    }

    // Call repository to delete project
    return await repository.deleteProject(params.projectId);
  }
}

/// Parameters for the DeleteProject use case
class DeleteProjectParams extends BaseParams {
  /// ID of the project to delete
  final String projectId;

  /// Whether to force deletion even if project has chats
  final bool force;

  const DeleteProjectParams({
    required this.projectId,
    this.force = false,
  });

  @override
  int get hashCode => projectId.hashCode ^ force.hashCode;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DeleteProjectParams &&
        other.projectId == projectId &&
        other.force == force;
  }

  @override
  Failure? validate() {
    if (projectId.trim().isEmpty) {
      return const ValidationFailure(message: 'Project ID cannot be empty');
    }

    return super.validate();
  }
}
