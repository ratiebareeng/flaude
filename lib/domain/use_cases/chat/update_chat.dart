import 'package:claude_chat_clone/core/error/failures.dart';
import 'package:claude_chat_clone/domain/entities/entities.dart';
import 'package:claude_chat_clone/domain/repositories/repositories.dart';
import 'package:claude_chat_clone/domain/use_cases/base_usecase.dart';
import 'package:dartz/dartz.dart';

/// Use case for updating an existing chat
class UpdateChat extends UseCase<void, UpdateChatParams> {
  final ChatRepository repository;

  UpdateChat(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateChatParams params) async {
    // Validate parameters
    final validationError = params.validate();
    if (validationError != null) {
      return Left(validationError);
    }

    // Call repository to update chat
    return await repository.updateChat(params.chat);
  }
}

/// Parameters for the UpdateChat use case
class UpdateChatParams extends BaseParams {
  /// Chat to update
  final Chat chat;

  const UpdateChatParams({
    required this.chat,
  });

  @override
  int get hashCode => chat.hashCode;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UpdateChatParams && other.chat == chat;
  }

  @override
  Failure? validate() {
    if (chat.id.trim().isEmpty) {
      return const ValidationFailure(message: 'Chat ID cannot be empty');
    }

    if (chat.title.trim().isEmpty) {
      return const ValidationFailure(message: 'Chat title cannot be empty');
    }

    return super.validate();
  }
}
