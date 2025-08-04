import 'package:claude_chat_clone/core/error/failures.dart';
import 'package:dartz/dartz.dart';

/// Base class for all use cases providing common functionality
///
/// Use cases represent the business logic of the application and orchestrate
/// data flow between the presentation layer and repositories.
abstract class UseCase<Type, Params> {
  /// Execute the use case with the given parameters
  ///
  /// Returns [Either<Failure, Type>] where:
  /// - [Left] contains a [Failure] if the operation fails
  /// - [Right] contains the result of type [Type] if successful
  Future<Either<Failure, Type>> call(Params params);
}

/// Base class for use cases that don't require parameters
abstract class NoParamsUseCase<Type> {
  /// Execute the use case without parameters
  ///
  /// Returns [Either<Failure, Type>] where:
  /// - [Left] contains a [Failure] if the operation fails
  /// - [Right] contains the result of type [Type] if successful
  Future<Either<Failure, Type>> call();
}

/// Base class for streaming use cases
abstract class StreamUseCase<Type, Params> {
  /// Execute the streaming use case with the given parameters
  ///
  /// Returns [Stream<Either<Failure, Type>>] where each emission contains:
  /// - [Left] with a [Failure] if the operation fails
  /// - [Right] with the result of type [Type] if successful
  Stream<Either<Failure, Type>> call(Params params);
}

/// Base class for streaming use cases that don't require parameters
abstract class NoParamsStreamUseCase<Type> {
  /// Execute the streaming use case without parameters
  ///
  /// Returns [Stream<Either<Failure, Type>>] where each emission contains:
  /// - [Left] with a [Failure] if the operation fails
  /// - [Right] with the result of type [Type] if successful
  Stream<Either<Failure, Type>> call();
}

/// Empty parameters class for use cases that don't need parameters
class NoParams {
  const NoParams();
  
  @override
  bool operator ==(Object other) => other is NoParams;
  
  @override
  int get hashCode => 0;
}

/// Base parameters class with common validation
abstract class BaseParams {
  const BaseParams();
  
  /// Validate the parameters
  /// 
  /// Returns [null] if valid, or a [Failure] if validation fails
  Failure? validate() => null;
}

/// Parameters that include pagination support
abstract class PaginatedParams extends BaseParams {
  /// Maximum number of items to return
  final int? limit;
  
  /// Offset for pagination
  final int? offset; 
  
  /// Cursor for cursor-based pagination
  final String? cursor;
  
  const PaginatedParams({
    this.limit,
    this.offset, 
    this.cursor,
  });
  
  @override
  Failure? validate() {
    if (limit != null && limit! <= 0) {
      return const ValidationFailure(message: 'Limit must be greater than 0');
    }
    
    if (offset != null && offset! < 0) {
      return const ValidationFailure(message: 'Offset must be non-negative');
    }
    
    return super.validate();
  }
}

/// Parameters that include search functionality
abstract class SearchParams extends PaginatedParams {
  /// Search query string
  final String query;
  
  const SearchParams({
    required this.query,
    super.limit,
    super.offset,
    super.cursor,
  });
  
  @override
  Failure? validate() {
    if (query.trim().isEmpty) {
      return const ValidationFailure(message: 'Search query cannot be empty');
    }
    
    return super.validate();
  }
}