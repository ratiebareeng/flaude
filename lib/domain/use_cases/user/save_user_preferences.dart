import 'package:claude_chat_clone/core/error/failures.dart';
import 'package:claude_chat_clone/domain/repositories/repositories.dart';
import 'package:claude_chat_clone/domain/use_cases/base_usecase.dart';
import 'package:dartz/dartz.dart';

/// Use case for saving the selected model
class SaveSelectedModel extends UseCase<void, SaveSelectedModelParams> {
  final UserRepository repository;

  SaveSelectedModel(this.repository);

  @override
  Future<Either<Failure, void>> call(SaveSelectedModelParams params) async {
    // Validate parameters
    final validationError = params.validate();
    if (validationError != null) {
      return Left(validationError);
    }

    // Call repository to save selected model
    return await repository.saveSelectedModel(params.model);
  }
}

/// Parameters for the SaveSelectedModel use case
class SaveSelectedModelParams extends BaseParams {
  /// Model ID to save as selected
  final String model;

  const SaveSelectedModelParams({
    required this.model,
  });

  @override
  int get hashCode => model.hashCode;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SaveSelectedModelParams && other.model == model;
  }

  @override
  Failure? validate() {
    if (model.trim().isEmpty) {
      return const ValidationFailure(message: 'Model ID cannot be empty');
    }

    return super.validate();
  }
}

/// Use case for saving the theme mode
class SaveThemeMode extends UseCase<void, SaveThemeModeParams> {
  final UserRepository repository;

  SaveThemeMode(this.repository);

  @override
  Future<Either<Failure, void>> call(SaveThemeModeParams params) async {
    // Validate parameters
    final validationError = params.validate();
    if (validationError != null) {
      return Left(validationError);
    }

    // Call repository to save theme mode
    return await repository.saveThemeMode(params.themeMode);
  }
}

/// Parameters for the SaveThemeMode use case
class SaveThemeModeParams extends BaseParams {
  /// Theme mode to save
  final String themeMode;

  const SaveThemeModeParams({
    required this.themeMode,
  });

  @override
  int get hashCode => themeMode.hashCode;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SaveThemeModeParams && other.themeMode == themeMode;
  }

  @override
  Failure? validate() {
    if (themeMode.trim().isEmpty) {
      return const ValidationFailure(message: 'Theme mode cannot be empty');
    }

    // Validate theme mode
    if (!['light', 'dark', 'system'].contains(themeMode.toLowerCase())) {
      return const ValidationFailure(
          message: 'Invalid theme mode. Must be one of: light, dark, system');
    }

    return super.validate();
  }
}

/// Use case for saving all user preferences
class SaveUserPreferences extends UseCase<void, SaveUserPreferencesParams> {
  final UserRepository repository;

  SaveUserPreferences(this.repository);

  @override
  Future<Either<Failure, void>> call(SaveUserPreferencesParams params) async {
    // Call repository to save user preferences
    return await repository.saveUserPreferences(params.preferences);
  }
}

/// Parameters for the SaveUserPreferences use case
class SaveUserPreferencesParams extends BaseParams {
  /// Preferences map to save
  final Map<String, dynamic> preferences;

  const SaveUserPreferencesParams({
    required this.preferences,
  });

  @override
  int get hashCode => preferences.hashCode;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SaveUserPreferencesParams &&
        other.preferences == preferences;
  }
}

/// Use case for setting a specific user preference
class SetUserPreference extends UseCase<void, SetUserPreferenceParams> {
  final UserRepository repository;

  SetUserPreference(this.repository);

  @override
  Future<Either<Failure, void>> call(SetUserPreferenceParams params) async {
    // Call repository to set specific user preference
    return await repository.setUserPreference(params.key, params.value);
  }
}

/// Parameters for the SetUserPreference use case
class SetUserPreferenceParams extends BaseParams {
  /// Preference key to set
  final String key;

  /// Preference value to set
  final dynamic value;

  const SetUserPreferenceParams({
    required this.key,
    required this.value,
  });

  @override
  int get hashCode => key.hashCode ^ value.hashCode;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SetUserPreferenceParams &&
        other.key == key &&
        other.value == value;
  }

  @override
  Failure? validate() {
    if (key.trim().isEmpty) {
      return const ValidationFailure(message: 'Preference key cannot be empty');
    }

    return super.validate();
  }
}
