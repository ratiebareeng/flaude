import 'package:claude_chat_clone/core/error/failures.dart';
import 'package:claude_chat_clone/domain/entities/entities.dart';
import 'package:claude_chat_clone/domain/repositories/repositories.dart';
import 'package:claude_chat_clone/domain/usecases/base_usecase.dart';
import 'package:dartz/dartz.dart';

/// Use case for retrieving artifacts from a project
class GetProjectArtifacts
    extends UseCase<List<Artifact>, GetProjectArtifactsParams> {
  final ProjectRepository repository;

  GetProjectArtifacts(this.repository);

  @override
  Future<Either<Failure, List<Artifact>>> call(
      GetProjectArtifactsParams params) async {
    // Validate parameters
    final validationError = params.validate();
    if (validationError != null) {
      return Left(validationError);
    }

    // Call repository to get project artifacts
    return await repository.getProjectArtifacts(params.projectId);
  }
}

/// Parameters for the GetProjectArtifacts use case
class GetProjectArtifactsParams extends PaginatedParams {
  /// ID of the project to get artifacts from
  final String projectId;

  /// Optional filter by artifact type
  final String? artifactType;

  const GetProjectArtifactsParams({
    required this.projectId,
    this.artifactType,
    super.limit,
    super.offset,
    super.cursor,
  });

  @override
  int get hashCode {
    return projectId.hashCode ^
        artifactType.hashCode ^
        limit.hashCode ^
        offset.hashCode ^
        cursor.hashCode;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GetProjectArtifactsParams &&
        other.projectId == projectId &&
        other.artifactType == artifactType &&
        other.limit == limit &&
        other.offset == offset &&
        other.cursor == cursor;
  }

  @override
  Failure? validate() {
    final baseValidation = super.validate();
    if (baseValidation != null) return baseValidation;

    if (projectId.trim().isEmpty) {
      return const ValidationFailure(message: 'Project ID cannot be empty');
    }

    return null;
  }
}
