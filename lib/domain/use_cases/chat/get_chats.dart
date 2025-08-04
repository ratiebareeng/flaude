import 'package:claude_chat_clone/core/error/failures.dart';
import 'package:claude_chat_clone/domain/entities/entities.dart';
import 'package:claude_chat_clone/domain/repositories/repositories.dart';
import 'package:claude_chat_clone/domain/use_cases/base_usecase.dart';
import 'package:dartz/dartz.dart';

/// Use case for retrieving chats with various filtering options
class GetChats extends UseCase<List<Chat>, GetChatsParams> {
  final ChatRepository repository;

  GetChats(this.repository);

  @override
  Future<Either<Failure, List<Chat>>> call(GetChatsParams params) async {
    // Validate parameters
    final validationError = params.validate();
    if (validationError != null) {
      return Left(validationError);
    }

    try {
      // Handle different types of chat retrieval
      switch (params.type) {
        case GetChatsType.all:
          return await repository.getAllChats();

        case GetChatsType.recent:
          return await repository.getRecentChats(limit: params.limit ?? 10);

        case GetChatsType.project:
          if (params.projectId == null) {
            return const Left(ValidationFailure(
                message: 'Project ID is required for project chats'));
          }
          return await repository.getProjectChats(params.projectId!);

        case GetChatsType.single:
          if (params.chatId == null) {
            return const Left(ValidationFailure(
                message: 'Chat ID is required for single chat'));
          }
          final result = await repository.getChat(params.chatId!);
          return result.fold(
            (failure) => Left(failure),
            (chat) => Right(chat != null ? [chat] : []),
          );
      }
    } catch (e) {
      return Left(
          UnknownFailure(message: 'Failed to get chats: ${e.toString()}'));
    }
  }
}

/// Parameters for the GetChats use case
class GetChatsParams extends PaginatedParams {
  /// Type of chat retrieval
  final GetChatsType type;

  /// Project ID (required when type is project)
  final String? projectId;

  /// Chat ID (required when type is single)
  final String? chatId;

  const GetChatsParams({
    required this.type,
    this.projectId,
    this.chatId,
    super.limit,
    super.offset,
    super.cursor,
  });

  @override
  int get hashCode {
    return type.hashCode ^
        projectId.hashCode ^
        chatId.hashCode ^
        limit.hashCode ^
        offset.hashCode ^
        cursor.hashCode;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GetChatsParams &&
        other.type == type &&
        other.projectId == projectId &&
        other.chatId == chatId &&
        other.limit == limit &&
        other.offset == offset &&
        other.cursor == cursor;
  }

  @override
  Failure? validate() {
    final baseValidation = super.validate();
    if (baseValidation != null) return baseValidation;

    switch (type) {
      case GetChatsType.project:
        if (projectId == null || projectId!.trim().isEmpty) {
          return const ValidationFailure(
              message: 'Project ID is required for project chats');
        }
        break;
      case GetChatsType.single:
        if (chatId == null || chatId!.trim().isEmpty) {
          return const ValidationFailure(
              message: 'Chat ID is required for single chat');
        }
        break;
      case GetChatsType.all:
      case GetChatsType.recent:
        // No additional validation required
        break;
    }

    return null;
  }
}

/// Types of chat retrieval
enum GetChatsType {
  /// Get all chats
  all,

  /// Get recent chats with limit
  recent,

  /// Get chats for a specific project
  project,

  /// Get a single chat by ID
  single,
}

/// Use case for watching chats in real-time
class WatchChats extends StreamUseCase<List<Chat>, WatchChatsParams> {
  final ChatRepository repository;

  WatchChats(this.repository);

  @override
  Stream<Either<Failure, List<Chat>>> call(WatchChatsParams params) {
    // Validate parameters
    final validationError = params.validate();
    if (validationError != null) {
      return Stream.value(Left(validationError));
    }

    try {
      // Handle different types of chat watching
      switch (params.type) {
        case WatchChatsType.all:
          return repository.watchAllChats();

        case WatchChatsType.project:
          if (params.projectId == null) {
            return Stream.value(const Left(ValidationFailure(
                message: 'Project ID is required for project chats')));
          }
          return repository.watchProjectChats(params.projectId!);

        case WatchChatsType.single:
          if (params.chatId == null) {
            return Stream.value(const Left(ValidationFailure(
                message: 'Chat ID is required for single chat')));
          }
          return repository.watchChat(params.chatId!).map(
                (either) => either.fold(
                  (failure) => Left(failure),
                  (chat) => Right(chat != null ? [chat] : []),
                ),
              );
      }
    } catch (e) {
      return Stream.value(Left(
          UnknownFailure(message: 'Failed to watch chats: ${e.toString()}')));
    }
  }
}

/// Parameters for the WatchChats use case
class WatchChatsParams extends BaseParams {
  /// Type of chat watching
  final WatchChatsType type;

  /// Project ID (required when type is project)
  final String? projectId;

  /// Chat ID (required when type is single)
  final String? chatId;

  const WatchChatsParams({
    required this.type,
    this.projectId,
    this.chatId,
  });

  @override
  int get hashCode {
    return type.hashCode ^ projectId.hashCode ^ chatId.hashCode;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WatchChatsParams &&
        other.type == type &&
        other.projectId == projectId &&
        other.chatId == chatId;
  }

  @override
  Failure? validate() {
    switch (type) {
      case WatchChatsType.project:
        if (projectId == null || projectId!.trim().isEmpty) {
          return const ValidationFailure(
              message: 'Project ID is required for project chats');
        }
        break;
      case WatchChatsType.single:
        if (chatId == null || chatId!.trim().isEmpty) {
          return const ValidationFailure(
              message: 'Chat ID is required for single chat');
        }
        break;
      case WatchChatsType.all:
        // No additional validation required
        break;
    }

    return null;
  }
}

/// Types of chat watching
enum WatchChatsType {
  /// Watch all chats
  all,

  /// Watch chats for a specific project
  project,

  /// Watch a single chat by ID
  single,
}
