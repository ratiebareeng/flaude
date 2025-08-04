import 'package:claude_chat_clone/core/error/failures.dart';
import 'package:claude_chat_clone/domain/entities/entities.dart';
import 'package:claude_chat_clone/domain/repositories/repositories.dart';
import 'package:dartz/dartz.dart';

import '../base_usecase.dart';

/// Use case for creating a new chat
class CreateChat extends UseCase<String, CreateChatParams> {
  final ChatRepository repository;

  CreateChat(this.repository);

  @override
  Future<Either<Failure, String>> call(CreateChatParams params) async {
    // Validate parameters
    final validationError = params.validate();
    if (validationError != null) {
      return Left(validationError);
    }

    // Call repository to create chat
    return await repository.createChat(params.chat);
  }
}

/// Parameters for the CreateChat use case
class CreateChatParams extends BaseParams {
  /// Chat to create
  final Chat chat;

  const CreateChatParams({
    required this.chat,
  });

  @override
  Failure? validate() {
    if (chat.title.trim().isEmpty) {
      return const ValidationFailure(
          message: 'Chat title cannot be empty');
    }

    return super.validate();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CreateChatParams && other.chat == chat;
  }

  @override
  int get hashCode => chat.hashCode;
}
