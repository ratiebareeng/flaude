import 'package:claude_chat_clone/core/error/failures.dart';
import 'package:claude_chat_clone/domain/entities/entities.dart';
import 'package:claude_chat_clone/domain/repositories/repositories.dart';
import 'package:claude_chat_clone/domain/usecases/base_usecase.dart';
import 'package:dartz/dartz.dart';

/// Use case for searching projects
class SearchProjects extends UseCase<List<Project>, SearchProjectsParams> {
  final ProjectRepository repository;

  SearchProjects(this.repository);

  @override
  Future<Either<Failure, List<Project>>> call(
      SearchProjectsParams params) async {
    // Validate parameters
    final validationError = params.validate();
    if (validationError != null) {
      return Left(validationError);
    }

    // Call repository to search projects
    return await repository.searchProjects(params.query);
  }
}

/// Parameters for the SearchProjects use case
class SearchProjectsParams extends SearchParams {
  /// Whether to include archived projects in search results
  final bool includeArchived;

  const SearchProjectsParams({
    required super.query,
    this.includeArchived = false,
    super.limit,
    super.offset,
    super.cursor,
  });

  @override
  int get hashCode {
    return query.hashCode ^
        includeArchived.hashCode ^
        limit.hashCode ^
        offset.hashCode ^
        cursor.hashCode;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SearchProjectsParams &&
        other.query == query &&
        other.includeArchived == includeArchived &&
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
