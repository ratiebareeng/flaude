import 'package:claude_chat_clone/core/error/failures.dart';
import 'package:claude_chat_clone/domain/repositories/repositories.dart';
import 'package:claude_chat_clone/domain/usecases/base_usecase.dart';
import 'package:dartz/dartz.dart';

/// Use case for getting the selected model
class GetSelectedModel extends NoParamsUseCase<String?> {
  final UserRepository repository;

  GetSelectedModel(this.repository);

  @override
  Future<Either<Failure, String?>> call() async {
    // Call repository to get selected model
    return await repository.getSelectedModel();
  }
}

/// Use case for getting the theme mode
class GetThemeMode extends NoParamsUseCase<String?> {
  final UserRepository repository;

  GetThemeMode(this.repository);

  @override
  Future<Either<Failure, String?>> call() async {
    // Call repository to get theme mode
    return await repository.getThemeMode();
  }
}

/// Use case for retrieving a specific user preference
class GetUserPreference<T> extends UseCase<T?, GetUserPreferenceParams> {
  final UserRepository repository;

  GetUserPreference(this.repository);

  @override
  Future<Either<Failure, T?>> call(GetUserPreferenceParams params) async {
    // Call repository to get specific user preference
    return await repository.getUserPreference<T>(params.key);
  }
}

/// Parameters for the GetUserPreference use case
class GetUserPreferenceParams extends BaseParams {
  /// Preference key to retrieve
  final String key;

  const GetUserPreferenceParams({
    required this.key,
  });

  @override
  int get hashCode => key.hashCode;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GetUserPreferenceParams && other.key == key;
  }

  @override
  Failure? validate() {
    if (key.trim().isEmpty) {
      return const ValidationFailure(message: 'Preference key cannot be empty');
    }

    return super.validate();
  }
}

/// Use case for retrieving all user preferences
class GetUserPreferences extends NoParamsUseCase<Map<String, dynamic>> {
  final UserRepository repository;

  GetUserPreferences(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call() async {
    // Call repository to get user preferences
    return await repository.getUserPreferences();
  }
}
