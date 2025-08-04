import 'package:claude_chat_clone/core/error/failures.dart';
import 'package:claude_chat_clone/domain/entities/entities.dart';
import 'package:claude_chat_clone/domain/repositories/repositories.dart';
import 'package:claude_chat_clone/domain/usecases/base_usecase.dart';
import 'package:dartz/dartz.dart';

/// Use case for clearing all user data
class ClearUserData extends NoParamsUseCase<void> {
  final UserRepository repository;

  ClearUserData(this.repository);

  @override
  Future<Either<Failure, void>> call() async {
    // Call repository to clear all user data
    return await repository.clearAllData();
  }
}

/// Use case for saving user profile data
class SaveUser extends UseCase<void, SaveUserParams> {
  final UserRepository repository;

  SaveUser(this.repository);

  @override
  Future<Either<Failure, void>> call(SaveUserParams params) async {
    // Call repository to save user
    return await repository.saveUser(params.user);
  }
}

/// Parameters for the SaveUser use case
class SaveUserParams extends BaseParams {
  /// User to save
  final User user;

  const SaveUserParams({
    required this.user,
  });

  @override
  int get hashCode => user.hashCode;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SaveUserParams && other.user == user;
  }

  @override
  Failure? validate() {
    if (user.id.trim().isEmpty) {
      return const ValidationFailure(message: 'User ID cannot be empty');
    }

    return super.validate();
  }
}
