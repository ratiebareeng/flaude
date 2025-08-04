import 'package:claude_chat_clone/core/error/failures.dart';
import 'package:claude_chat_clone/domain/repositories/repositories.dart';
import 'package:claude_chat_clone/domain/usecases/base_usecase.dart';
import 'package:dartz/dartz.dart';

/// Use case for deleting the stored Claude API key
class DeleteApiKey extends NoParamsUseCase<void> {
  final UserRepository repository;

  DeleteApiKey(this.repository);

  @override
  Future<Either<Failure, void>> call() async {
    // Call repository to delete API key
    return await repository.deleteApiKey();
  }
}

/// Use case for retrieving the stored Claude API key
class GetApiKey extends NoParamsUseCase<String?> {
  final UserRepository repository;

  GetApiKey(this.repository);

  @override
  Future<Either<Failure, String?>> call() async {
    // Call repository to get API key
    return await repository.getApiKey();
  }
}
