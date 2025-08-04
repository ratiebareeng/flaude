import 'package:claude_chat_clone/core/error/failures.dart';
import 'package:claude_chat_clone/domain/repositories/repositories.dart';
import 'package:claude_chat_clone/domain/use_cases/base_usecase.dart';
import 'package:dartz/dartz.dart';

/// Use case for deleting a chat
class DeleteChat extends UseCase<void, DeleteChatParams> {
  final ChatRepository repository;

  DeleteChat(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteChatParams params) async {
    // Validate parameters
    final validationError = params.validate();
    if (validationError != null) {
      return Left(validationError);
    }

    // Call repository to delete chat
    return await repository.deleteChat(params.chatId);
  }
}

/// Parameters for the DeleteChat use case
class DeleteChatParams extends BaseParams {
  /// ID of the chat to delete
  final String chatId;

  const DeleteChatParams({
    required this.chatId,
  });

  @override
  int get hashCode => chatId.hashCode;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DeleteChatParams && other.chatId == chatId;
  }

  @override
  Failure? validate() {
    if (chatId.trim().isEmpty) {
      return const ValidationFailure(message: 'Chat ID cannot be empty');
    }

    return super.validate();
  }
}
