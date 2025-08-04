import 'package:equatable/equatable.dart';

/// Base class for all app events
abstract class AppEvent extends Equatable {
  const AppEvent();

  @override
  List<Object?> get props => [];
}

/// Event to initialize the app
class AppInitialized extends AppEvent {
  const AppInitialized();
}

/// Event to load user data
class AppUserDataRequested extends AppEvent {
  const AppUserDataRequested();
}

/// Event to save API key
class AppApiKeySaved extends AppEvent {
  final String apiKey;

  const AppApiKeySaved(this.apiKey);

  @override
  List<Object?> get props => [apiKey];
}

/// Event to delete API key
class AppApiKeyDeleted extends AppEvent {
  const AppApiKeyDeleted();
}

/// Event to validate API key
class AppApiKeyValidated extends AppEvent {
  final String apiKey;

  const AppApiKeyValidated(this.apiKey);

  @override
  List<Object?> get props => [apiKey];
}

/// Event to load available models
class AppModelsRequested extends AppEvent {
  const AppModelsRequested();
}

/// Event to select a model
class AppModelSelected extends AppEvent {
  final String modelId;

  const AppModelSelected(this.modelId);

  @override
  List<Object?> get props => [modelId];
}

/// Event to change theme mode
class AppThemeChanged extends AppEvent {
  final String themeMode;

  const AppThemeChanged(this.themeMode);

  @override
  List<Object?> get props => [themeMode];
}

/// Event to save user preferences
class AppUserPreferencesSaved extends AppEvent {
  final Map<String, dynamic> preferences;

  const AppUserPreferencesSaved(this.preferences);

  @override
  List<Object?> get props => [preferences];
}

/// Event to set a specific user preference
class AppUserPreferenceSet extends AppEvent {
  final String key;
  final dynamic value;

  const AppUserPreferenceSet(this.key, this.value);

  @override
  List<Object?> get props => [key, value];
}

/// Event to save user data
class AppUserSaved extends AppEvent {
  final String userId;
  final String? email;
  final String? displayName;
  final String? photoUrl;

  const AppUserSaved({
    required this.userId,
    this.email,
    this.displayName,
    this.photoUrl,
  });

  @override
  List<Object?> get props => [userId, email, displayName, photoUrl];
}

/// Event to clear all user data
class AppUserDataCleared extends AppEvent {
  const AppUserDataCleared();
}

/// Event to refresh app state
class AppRefreshed extends AppEvent {
  const AppRefreshed();
}

/// Event to handle errors
class AppErrorOccurred extends AppEvent {
  final String message;
  final String? details;

  const AppErrorOccurred(this.message, {this.details});

  @override
  List<Object?> get props => [message, details];
}

/// Event to clear errors
class AppErrorCleared extends AppEvent {
  const AppErrorCleared();
}