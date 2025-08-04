import 'package:claude_chat_clone/core/error/failures.dart';
import 'package:claude_chat_clone/domain/repositories/repositories.dart';
import 'package:claude_chat_clone/domain/use_cases/base_usecase.dart';
import 'package:dartz/dartz.dart';

/// Use case for deleting a message from a chat
class DeleteMessage extends UseCase<void, DeleteMessageParams> {
  final ChatRepository repository;

  DeleteMessage(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteMessageParams params) async {
    // Validate parameters
    final validationError = params.validate();
    if (validationError != null) {
      return Left(validationError);
    }

    // Call repository to delete message
    return await repository.deleteMessage(params.chatId, params.messageId);
  }
}

/// Parameters for the DeleteMessage use case
class DeleteMessageParams extends BaseParams {
  /// ID of the chat containing the message
  final String chatId;

  /// ID of the message to delete
  final String messageId;

  const DeleteMessageParams({
    required this.chatId,
    required this.messageId,
  });

  @override
  int get hashCode => chatId.hashCode ^ messageId.hashCode;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DeleteMessageParams &&
        other.chatId == chatId &&
        other.messageId == messageId;
  }

  @override
  Failure? validate() {
    if (chatId.trim().isEmpty) {
      return const ValidationFailure(message: 'Chat ID cannot be empty');
    }

    if (messageId.trim().isEmpty) {
      return const ValidationFailure(message: 'Message ID cannot be empty');
    }

    return super.validate();
  }
}
