import 'package:claude_chat_clone/core/error/failures.dart';
import 'package:claude_chat_clone/domain/entities/entities.dart';
import 'package:claude_chat_clone/domain/repositories/repositories.dart';
import 'package:claude_chat_clone/domain/usecases/base_usecase.dart';
import 'package:dartz/dartz.dart';

/// Use case for retrieving projects
class GetProjects extends UseCase<List<Project>, GetProjectsParams> {
  final ProjectRepository repository;

  GetProjects(this.repository);

  @override
  Future<Either<Failure, List<Project>>> call(GetProjectsParams params) async {
    // Validate parameters
    final validationError = params.validate();
    if (validationError != null) {
      return Left(validationError);
    }

    // Call repository to get all projects
    return await repository.getAllProjects();
  }
}

/// Parameters for the GetProjects use case
class GetProjectsParams extends PaginatedParams {
  /// Whether to include archived projects
  final bool includeArchived;

  const GetProjectsParams({
    this.includeArchived = false,
    super.limit,
    super.offset,
    super.cursor,
  });

  @override
  int get hashCode {
    return includeArchived.hashCode ^
        limit.hashCode ^
        offset.hashCode ^
        cursor.hashCode;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GetProjectsParams &&
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

/// Use case for watching projects in real-time
class WatchProjects extends StreamUseCase<List<Project>, NoParams> {
  final ProjectRepository repository;

  WatchProjects(this.repository);

  @override
  Stream<Either<Failure, List<Project>>> call(NoParams params) {
    // Call repository to watch all projects
    return repository.watchAllProjects();
  }
}
