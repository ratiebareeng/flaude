import 'package:claude_chat_clone/core/error/failures.dart';
import 'package:claude_chat_clone/domain/entities/entities.dart';
import 'package:claude_chat_clone/domain/repositories/repositories.dart';
import 'package:claude_chat_clone/domain/usecases/base_usecase.dart';
import 'package:dartz/dartz.dart';

/// Use case for retrieving messages from a chat
class GetMessages extends UseCase<List<Message>, GetMessagesParams> {
  final ChatRepository repository;

  GetMessages(this.repository);

  @override
  Future<Either<Failure, List<Message>>> call(GetMessagesParams params) async {
    // Validate parameters
    final validationError = params.validate();
    if (validationError != null) {
      return Left(validationError);
    }

    // Call repository to get chat messages
    return await repository.getChatMessages(params.chatId);
  }
}

/// Parameters for the GetMessages use case
class GetMessagesParams extends PaginatedParams {
  /// ID of the chat to get messages from
  final String chatId;

  const GetMessagesParams({
    required this.chatId,
    super.limit,
    super.offset,
    super.cursor,
  });

  @override
  int get hashCode {
    return chatId.hashCode ^ limit.hashCode ^ offset.hashCode ^ cursor.hashCode;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GetMessagesParams &&
        other.chatId == chatId &&
        other.limit == limit &&
        other.offset == offset &&
        other.cursor == cursor;
  }

  @override
  Failure? validate() {
    final baseValidation = super.validate();
    if (baseValidation != null) return baseValidation;

    if (chatId.trim().isEmpty) {
      return const ValidationFailure(message: 'Chat ID cannot be empty');
    }

    return null;
  }
}
