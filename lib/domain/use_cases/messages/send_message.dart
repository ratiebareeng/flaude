import 'package:claude_chat_clone/core/error/failures.dart';
import 'package:claude_chat_clone/domain/entities/entities.dart';
import 'package:claude_chat_clone/domain/repositories/repositories.dart';
import 'package:claude_chat_clone/domain/use_cases/base_usecase.dart';
import 'package:dartz/dartz.dart';

/// Use case for sending a message to a chat
class SendMessage extends UseCase<void, SendMessageParams> {
  final ChatRepository repository;

  SendMessage(this.repository);

  @override
  Future<Either<Failure, void>> call(SendMessageParams params) async {
    // Validate parameters
    final validationError = params.validate();
    if (validationError != null) {
      return Left(validationError);
    }

    // Call repository to add message
    return await repository.addMessage(params.chatId, params.message);
  }
}

/// Parameters for the SendMessage use case
class SendMessageParams extends BaseParams {
  /// ID of the chat to add the message to
  final String chatId;

  /// Message to send
  final Message message;

  const SendMessageParams({
    required this.chatId,
    required this.message,
  });

  @override
  int get hashCode => chatId.hashCode ^ message.hashCode;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SendMessageParams &&
        other.chatId == chatId &&
        other.message == message;
  }

  @override
  Failure? validate() {
    if (chatId.trim().isEmpty) {
      return const ValidationFailure(message: 'Chat ID cannot be empty');
    }

    if (message.content.trim().isEmpty) {
      return const ValidationFailure(
          message: 'Message content cannot be empty');
    }

    return super.validate();
  }
}
