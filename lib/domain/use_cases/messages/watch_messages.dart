import 'package:claude_chat_clone/core/error/failures.dart';
import 'package:claude_chat_clone/domain/entities/entities.dart';
import 'package:claude_chat_clone/domain/repositories/repositories.dart';
import 'package:claude_chat_clone/domain/use_cases/base_usecase.dart';
import 'package:dartz/dartz.dart';

/// Use case for watching messages in a chat in real-time
class WatchMessages extends StreamUseCase<List<Message>, WatchMessagesParams> {
  final ChatRepository repository;

  WatchMessages(this.repository);

  @override
  Stream<Either<Failure, List<Message>>> call(WatchMessagesParams params) {
    // Validate parameters
    final validationError = params.validate();
    if (validationError != null) {
      return Stream.value(Left(validationError));
    }

    // Call repository to watch chat messages
    return repository.watchChatMessages(params.chatId);
  }
}

/// Parameters for the WatchMessages use case
class WatchMessagesParams extends BaseParams {
  /// ID of the chat to watch messages from
  final String chatId;

  const WatchMessagesParams({
    required this.chatId,
  });

  @override
  int get hashCode => chatId.hashCode;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WatchMessagesParams && other.chatId == chatId;
  }

  @override
  Failure? validate() {
    if (chatId.trim().isEmpty) {
      return const ValidationFailure(message: 'Chat ID cannot be empty');
    }

    return super.validate();
  }
}
