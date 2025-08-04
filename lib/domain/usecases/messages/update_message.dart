import 'package:claude_chat_clone/core/error/failures.dart';
import 'package:claude_chat_clone/domain/entities/entities.dart';
import 'package:claude_chat_clone/domain/repositories/repositories.dart';
import 'package:claude_chat_clone/domain/usecases/base_usecase.dart';
import 'package:dartz/dartz.dart';

/// Use case for updating a message in a chat
class UpdateMessage extends UseCase<void, UpdateMessageParams> {
  final ChatRepository repository;

  UpdateMessage(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateMessageParams params) async {
    // Validate parameters
    final validationError = params.validate();
    if (validationError != null) {
      return Left(validationError);
    }

    // Call repository to update message
    return await repository.updateMessage(params.chatId, params.message);
  }
}

/// Parameters for the UpdateMessage use case
class UpdateMessageParams extends BaseParams {
  /// ID of the chat containing the message
  final String chatId;

  /// Message to update
  final Message message;

  const UpdateMessageParams({
    required this.chatId,
    required this.message,
  });

  @override
  int get hashCode => chatId.hashCode ^ message.hashCode;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UpdateMessageParams &&
        other.chatId == chatId &&
        other.message == message;
  }

  @override
  Failure? validate() {
    if (chatId.trim().isEmpty) {
      return const ValidationFailure(message: 'Chat ID cannot be empty');
    }

    if (message.id.trim().isEmpty) {
      return const ValidationFailure(message: 'Message ID cannot be empty');
    }

    if (message.content.trim().isEmpty) {
      return const ValidationFailure(
          message: 'Message content cannot be empty');
    }

    return super.validate();
  }
}
