import 'package:claude_chat_clone/core/error/failures.dart';
import 'package:claude_chat_clone/domain/entities/entities.dart';
import 'package:claude_chat_clone/domain/repositories/repositories.dart';
import 'package:claude_chat_clone/domain/use_cases/base_usecase.dart';
import 'package:dartz/dartz.dart';

/// Use case for searching chats
class SearchChats extends UseCase<List<Chat>, SearchChatsParams> {
  final ChatRepository repository;

  SearchChats(this.repository);

  @override
  Future<Either<Failure, List<Chat>>> call(SearchChatsParams params) async {
    // Validate parameters
    final validationError = params.validate();
    if (validationError != null) {
      return Left(validationError);
    }

    // Call repository to search chats
    return await repository.searchChats(params.query);
  }
}

/// Parameters for the SearchChats use case
class SearchChatsParams extends SearchParams {
  /// Optional project ID to scope the search
  final String? projectId;

  const SearchChatsParams({
    required super.query,
    this.projectId,
    super.limit,
    super.offset,
    super.cursor,
  });

  @override
  int get hashCode {
    return query.hashCode ^
        projectId.hashCode ^
        limit.hashCode ^
        offset.hashCode ^
        cursor.hashCode;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SearchChatsParams &&
        other.query == query &&
        other.projectId == projectId &&
        other.limit == limit &&
        other.offset == offset &&
        other.cursor == cursor;
  }

  @override
  Failure? validate() {
    final baseValidation = super.validate();
    if (baseValidation != null) return baseValidation;

    return null;
  }
}
