import 'package:claude_chat_clone/core/error/failures.dart';
import 'package:claude_chat_clone/domain/entities/entities.dart';
import 'package:claude_chat_clone/domain/repositories/repositories.dart';
import 'package:claude_chat_clone/domain/usecases/base_usecase.dart';
import 'package:dartz/dartz.dart';

/// Use case for retrieving the current user profile
class GetUser extends NoParamsUseCase<User?> {
  final UserRepository repository;

  GetUser(this.repository);

  @override
  Future<Either<Failure, User?>> call() async {
    // Call repository to get user
    return await repository.getUser();
  }
}

/// Use case for checking if user data exists
class HasUserData extends NoParamsUseCase<bool> {
  final UserRepository repository;

  HasUserData(this.repository);

  @override
  Future<Either<Failure, bool>> call() async {
    // Call repository to check if user data exists
    return await repository.hasUserData();
  }
}
