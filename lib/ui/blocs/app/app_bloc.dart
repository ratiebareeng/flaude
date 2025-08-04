import 'dart:async';

import 'package:claude_chat_clone/domain/entities/entities.dart';
import 'package:claude_chat_clone/domain/usecases/usecases.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app_event.dart';
import 'app_state.dart';

/// BLoC for managing global app state
class AppBloc extends Bloc<AppEvent, AppState> {
  final GetUser _getUser;
  final SaveUser _saveUser;
  final ClearUserData _clearUserData;
  final GetApiKey _getApiKey;
  final SaveApiKey _saveApiKey;
  final DeleteApiKey _deleteApiKey;
  final ValidateApiKey _validateApiKey;
  final GetModels _getModels;
  final GetSelectedModel _getSelectedModel;
  final SaveSelectedModel _saveSelectedModel;
  final GetThemeMode _getThemeMode;
  final SaveThemeMode _saveThemeMode;
  final GetUserPreferences _getUserPreferences;
  final SaveUserPreferences _saveUserPreferences;
  final SetUserPreference _setUserPreference;

  AppBloc({
    required GetUser getUser,
    required SaveUser saveUser,
    required ClearUserData clearUserData,
    required GetApiKey getApiKey,
    required SaveApiKey saveApiKey,
    required DeleteApiKey deleteApiKey,
    required ValidateApiKey validateApiKey,
    required GetModels getModels,
    required GetSelectedModel getSelectedModel,
    required SaveSelectedModel saveSelectedModel,
    required GetThemeMode getThemeMode,
    required SaveThemeMode saveThemeMode,
    required GetUserPreferences getUserPreferences,
    required SaveUserPreferences saveUserPreferences,
    required SetUserPreference setUserPreference,
  })  : _getUser = getUser,
        _saveUser = saveUser,
        _clearUserData = clearUserData,
        _getApiKey = getApiKey,
        _saveApiKey = saveApiKey,
        _deleteApiKey = deleteApiKey,
        _validateApiKey = validateApiKey,
        _getModels = getModels,
        _getSelectedModel = getSelectedModel,
        _saveSelectedModel = saveSelectedModel,
        _getThemeMode = getThemeMode,
        _saveThemeMode = saveThemeMode,
        _getUserPreferences = getUserPreferences,
        _saveUserPreferences = saveUserPreferences,
        _setUserPreference = setUserPreference,
        super(const AppInitial()) {
    on<AppInitialized>(_onAppInitialized);
    on<AppUserDataRequested>(_onUserDataRequested);
    on<AppApiKeySaved>(_onApiKeySaved);
    on<AppApiKeyDeleted>(_onApiKeyDeleted);
    on<AppApiKeyValidated>(_onApiKeyValidated);
    on<AppModelsRequested>(_onModelsRequested);
    on<AppModelSelected>(_onModelSelected);
    on<AppThemeChanged>(_onThemeChanged);
    on<AppUserPreferencesSaved>(_onUserPreferencesSaved);
    on<AppUserPreferenceSet>(_onUserPreferenceSet);
    on<AppUserSaved>(_onUserSaved);
    on<AppUserDataCleared>(_onUserDataCleared);
    on<AppRefreshed>(_onAppRefreshed);
    on<AppErrorOccurred>(_onErrorOccurred);
    on<AppErrorCleared>(_onErrorCleared);
  }

  /// Delete API key
  Future<void> _onApiKeyDeleted(
    AppApiKeyDeleted event,
    Emitter<AppState> emit,
  ) async {
    if (state is! AppReady) return;

    final currentState = state as AppReady;

    final result = await _deleteApiKey.call();

    result.fold(
      (failure) => emit(AppError(
        'Failed to delete API key',
        details: failure.message,
        previousState: currentState,
      )),
      (_) => emit(AppNeedsConfiguration(
        reason: 'API key has been removed',
        missingRequirements: ['api_key'],
      )),
    );
  }

  /// Save API key
  Future<void> _onApiKeySaved(
    AppApiKeySaved event,
    Emitter<AppState> emit,
  ) async {
    emit(AppValidatingApiKey(event.apiKey));

    try {
      // Save API key
      final saveResult = await _saveApiKey.call(
        SaveApiKeyParams(apiKey: event.apiKey),
      );

      await saveResult.fold(
        (failure) async {
          emit(AppError(
            'Failed to save API key',
            details: failure.message,
          ));
        },
        (_) async {
          // Validate API key
          final validationResult = await _validateApiKey.call(
            ValidateApiKeyParams(apiKey: event.apiKey),
          );

          await validationResult.fold(
            (failure) async {
              emit(AppError(
                'API key validation failed',
                details: failure.message,
              ));
            },
            (isValid) async {
              if (!isValid) {
                emit(const AppError('Invalid API key provided'));
                return;
              }

              // Load models
              final modelsResult = await _getModels.call(
                GetModelsParams(apiKey: event.apiKey),
              );

              await modelsResult.fold(
                (failure) async {
                  emit(AppError(
                    'Failed to load models',
                    details: failure.message,
                  ));
                },
                (models) async {
                  final currentState =
                      state is AppReady ? state as AppReady : const AppReady();

                  final selectedModel = models.isNotEmpty ? models.first : null;

                  // Save selected model if none exists
                  if (selectedModel != null) {
                    await _saveSelectedModel.call(
                      SaveSelectedModelParams(model: selectedModel.id),
                    );
                  }

                  emit(currentState.copyWith(
                    apiKey: event.apiKey,
                    hasApiKey: true,
                    isApiKeyValid: true,
                    availableModels: models,
                    selectedModel: selectedModel,
                  ));
                },
              );
            },
          );
        },
      );
    } catch (e) {
      emit(AppError('Unexpected error: ${e.toString()}'));
    }
  }

  /// Validate API key
  Future<void> _onApiKeyValidated(
    AppApiKeyValidated event,
    Emitter<AppState> emit,
  ) async {
    emit(AppValidatingApiKey(event.apiKey));

    final result = await _validateApiKey.call(
      ValidateApiKeyParams(apiKey: event.apiKey),
    );

    result.fold(
      (failure) => emit(AppError(
        'API key validation failed',
        details: failure.message,
      )),
      (isValid) {
        if (state is AppReady) {
          final currentState = state as AppReady;
          emit(currentState.copyWith(isApiKeyValid: isValid));
        } else {
          emit(AppReady(
            apiKey: event.apiKey,
            hasApiKey: true,
            isApiKeyValid: isValid,
          ));
        }
      },
    );
  }

  /// Initialize the app and load all necessary data
  Future<void> _onAppInitialized(
    AppInitialized event,
    Emitter<AppState> emit,
  ) async {
    emit(const AppLoading());

    try {
      // Load user data
      final userResult = await _getUser.call();
      User? user;

      await userResult.fold(
        (failure) async {
          // User not found, continue with anonymous user
          user = null;
        },
        (userData) async {
          user = userData;
        },
      );

      // Load API key
      final apiKeyResult = await _getApiKey.call();
      String? apiKey;
      bool hasApiKey = false;

      await apiKeyResult.fold(
        (failure) async {
          apiKey = null;
          hasApiKey = false;
        },
        (key) async {
          apiKey = key;
          hasApiKey = key != null && key.isNotEmpty;
        },
      );

      // Load selected model
      final modelResult = await _getSelectedModel.call();
      String? selectedModelId;

      await modelResult.fold(
        (failure) async {
          selectedModelId = null;
        },
        (model) async {
          selectedModelId = model;
        },
      );

      // Load theme mode
      final themeResult = await _getThemeMode.call();
      String themeMode = 'system';

      await themeResult.fold(
        (failure) async {
          themeMode = 'system';
        },
        (theme) async {
          themeMode = theme ?? 'system';
        },
      );

      // Load user preferences
      final preferencesResult = await _getUserPreferences.call();
      Map<String, dynamic> preferences = {};

      await preferencesResult.fold(
        (failure) async {
          preferences = {};
        },
        (prefs) async {
          preferences = prefs;
        },
      );

      // Validate API key if present
      bool isApiKeyValid = false;
      List<AIModel> availableModels = [];
      AIModel? selectedModel;

      if (hasApiKey && apiKey != null) {
        final validationResult = await _validateApiKey.call(
          ValidateApiKeyParams(apiKey: apiKey!),
        );

        await validationResult.fold(
          (failure) async {
            isApiKeyValid = false;
          },
          (isValid) async {
            isApiKeyValid = isValid;

            // Load models if API key is valid
            if (isValid) {
              final modelsResult = await _getModels.call(
                GetModelsParams(apiKey: apiKey!),
              );

              await modelsResult.fold(
                (failure) async {
                  availableModels = [];
                },
                (models) async {
                  availableModels = models;

                  // Find selected model
                  if (selectedModelId != null) {
                    selectedModel = availableModels.firstWhere(
                      (model) => model.id == selectedModelId,
                      orElse: () => availableModels.isNotEmpty
                          ? availableModels.first
                          : throw Exception('No models available'),
                    );
                  } else if (availableModels.isNotEmpty) {
                    selectedModel = availableModels.first;
                  }
                },
              );
            }
          },
        );
      }

      // Check if app needs configuration
      final missingRequirements = <String>[];
      if (!hasApiKey || !isApiKeyValid) {
        missingRequirements.add('api_key');
      }
      if (selectedModel == null && availableModels.isNotEmpty) {
        missingRequirements.add('model');
      }

      if (missingRequirements.isNotEmpty) {
        emit(AppNeedsConfiguration(
          reason: 'App needs to be configured before use',
          missingRequirements: missingRequirements,
        ));
      } else {
        emit(AppReady(
          user: user,
          apiKey: apiKey,
          hasApiKey: hasApiKey,
          availableModels: availableModels,
          selectedModel: selectedModel,
          themeMode: themeMode,
          preferences: preferences,
          isApiKeyValid: isApiKeyValid,
        ));
      }
    } catch (e) {
      emit(AppError('Failed to initialize app: ${e.toString()}'));
    }
  }

  /// Refresh app state
  Future<void> _onAppRefreshed(
    AppRefreshed event,
    Emitter<AppState> emit,
  ) async {
    add(const AppInitialized());
  }

  /// Clear errors and return to previous state
  void _onErrorCleared(
    AppErrorCleared event,
    Emitter<AppState> emit,
  ) {
    if (state is AppError) {
      final errorState = state as AppError;
      if (errorState.previousState != null) {
        emit(errorState.previousState!);
      } else {
        emit(const AppInitial());
        add(const AppInitialized());
      }
    }
  }

  /// Handle error occurred
  void _onErrorOccurred(
    AppErrorOccurred event,
    Emitter<AppState> emit,
  ) {
    emit(AppError(event.message, details: event.details));
  }

  /// Select a model
  Future<void> _onModelSelected(
    AppModelSelected event,
    Emitter<AppState> emit,
  ) async {
    if (state is! AppReady) return;

    final currentState = state as AppReady;

    final selectedModel = currentState.availableModels.firstWhere(
      (model) => model.id == event.modelId,
      orElse: () => throw Exception('Model not found'),
    );

    final result = await _saveSelectedModel.call(
      SaveSelectedModelParams(model: event.modelId),
    );

    result.fold(
      (failure) => emit(AppError(
        'Failed to save selected model',
        details: failure.message,
        previousState: currentState,
      )),
      (_) => emit(currentState.copyWith(selectedModel: selectedModel)),
    );
  }

  /// Load available models
  Future<void> _onModelsRequested(
    AppModelsRequested event,
    Emitter<AppState> emit,
  ) async {
    if (state is! AppReady) return;

    final currentState = state as AppReady;

    if (!currentState.hasApiKey || currentState.apiKey == null) {
      emit(AppError(
        'Cannot load models without API key',
        previousState: currentState,
      ));
      return;
    }

    emit(const AppLoadingModels());

    final result = await _getModels.call(
      GetModelsParams(apiKey: currentState.apiKey!),
    );

    result.fold(
      (failure) => emit(AppError(
        'Failed to load models',
        details: failure.message,
        previousState: currentState,
      )),
      (models) => emit(currentState.copyWith(availableModels: models)),
    );
  }

  /// Change theme mode
  Future<void> _onThemeChanged(
    AppThemeChanged event,
    Emitter<AppState> emit,
  ) async {
    if (state is! AppReady) return;

    final currentState = state as AppReady;

    final result = await _saveThemeMode.call(
      SaveThemeModeParams(themeMode: event.themeMode),
    );

    result.fold(
      (failure) => emit(AppError(
        'Failed to save theme preference',
        details: failure.message,
        previousState: currentState,
      )),
      (_) => emit(currentState.copyWith(themeMode: event.themeMode)),
    );
  }

  /// Clear user data
  Future<void> _onUserDataCleared(
    AppUserDataCleared event,
    Emitter<AppState> emit,
  ) async {
    emit(const AppClearingData());

    final result = await _clearUserData.call();

    result.fold(
      (failure) => emit(AppError(
        'Failed to clear user data',
        details: failure.message,
      )),
      (_) => emit(const AppNeedsConfiguration(
        reason: 'All user data has been cleared',
        missingRequirements: ['api_key', 'model'],
      )),
    );
  }

  /// Load user data
  Future<void> _onUserDataRequested(
    AppUserDataRequested event,
    Emitter<AppState> emit,
  ) async {
    if (state is! AppReady) return;

    final currentState = state as AppReady;

    final result = await _getUser.call();

    result.fold(
      (failure) => emit(AppError(
        'Failed to load user data',
        details: failure.message,
        previousState: currentState,
      )),
      (user) => emit(currentState.copyWith(user: user)),
    );
  }

  /// Set a specific user preference
  Future<void> _onUserPreferenceSet(
    AppUserPreferenceSet event,
    Emitter<AppState> emit,
  ) async {
    if (state is! AppReady) return;

    final currentState = state as AppReady;

    final result = await _setUserPreference.call(
      SetUserPreferenceParams(key: event.key, value: event.value),
    );

    result.fold(
      (failure) => emit(AppError(
        'Failed to save preference',
        details: failure.message,
        previousState: currentState,
      )),
      (_) {
        final updatedPreferences =
            Map<String, dynamic>.from(currentState.preferences);
        updatedPreferences[event.key] = event.value;
        emit(currentState.copyWith(preferences: updatedPreferences));
      },
    );
  }

  /// Save user preferences
  Future<void> _onUserPreferencesSaved(
    AppUserPreferencesSaved event,
    Emitter<AppState> emit,
  ) async {
    if (state is! AppReady) return;

    final currentState = state as AppReady;
    emit(const AppSavingPreferences());

    final result = await _saveUserPreferences.call(
      SaveUserPreferencesParams(preferences: event.preferences),
    );

    result.fold(
      (failure) => emit(AppError(
        'Failed to save preferences',
        details: failure.message,
        previousState: currentState,
      )),
      (_) => emit(currentState.copyWith(preferences: event.preferences)),
    );
  }

  /// Save user data
  Future<void> _onUserSaved(
    AppUserSaved event,
    Emitter<AppState> emit,
  ) async {
    if (state is! AppReady) return;

    final currentState = state as AppReady;
    emit(const AppSavingUser());

    final user = User.create(
      id: event.userId,
      email: event.email,
      displayName: event.displayName,
      photoUrl: event.photoUrl,
      preferences: currentState.preferences,
    );

    final result = await _saveUser.call(SaveUserParams(user: user));

    result.fold(
      (failure) => emit(AppError(
        'Failed to save user data',
        details: failure.message,
        previousState: currentState,
      )),
      (_) => emit(currentState.copyWith(user: user)),
    );
  }
}
