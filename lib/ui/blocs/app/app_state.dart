import 'package:equatable/equatable.dart';
import 'package:claude_chat_clone/domain/entities/entities.dart';

/// Base class for all app states
abstract class AppState extends Equatable {
  const AppState();

  @override
  List<Object?> get props => [];
}

/// Initial state when app starts
class AppInitial extends AppState {
  const AppInitial();
}

/// State when app is loading/initializing
class AppLoading extends AppState {
  const AppLoading();
}

/// State when app is ready to use
class AppReady extends AppState {
  final User? user;
  final String? apiKey;
  final bool hasApiKey;
  final List<AIModel> availableModels;
  final AIModel? selectedModel;
  final String themeMode;
  final Map<String, dynamic> preferences;
  final bool isApiKeyValid;

  const AppReady({
    this.user,
    this.apiKey,
    this.hasApiKey = false,
    this.availableModels = const [],
    this.selectedModel,
    this.themeMode = 'system',
    this.preferences = const {},
    this.isApiKeyValid = false,
  });

  @override
  List<Object?> get props => [
        user,
        apiKey,
        hasApiKey,
        availableModels,
        selectedModel,
        themeMode,
        preferences,
        isApiKeyValid,
      ];

  /// Check if the app is properly configured
  bool get isConfigured => hasApiKey && isApiKeyValid && selectedModel != null;

  /// Get display name for user
  String get userDisplayName =>
      user?.displayNameOrEmail ?? 'Anonymous User';

  /// Check if notifications are enabled
  bool get notificationsEnabled =>
      preferences['notifications'] as bool? ?? true;

  /// Check if auto-save is enabled
  bool get autoSaveEnabled => preferences['auto_save'] as bool? ?? true;

  /// Get preferred language
  String get preferredLanguage => preferences['language'] as String? ?? 'en';

  AppReady copyWith({
    User? user,
    String? apiKey,
    bool? hasApiKey,
    List<AIModel>? availableModels,
    AIModel? selectedModel,
    String? themeMode,
    Map<String, dynamic>? preferences,
    bool? isApiKeyValid,
  }) {
    return AppReady(
      user: user ?? this.user,
      apiKey: apiKey ?? this.apiKey,
      hasApiKey: hasApiKey ?? this.hasApiKey,
      availableModels: availableModels ?? this.availableModels,
      selectedModel: selectedModel ?? this.selectedModel,
      themeMode: themeMode ?? this.themeMode,
      preferences: preferences ?? this.preferences,
      isApiKeyValid: isApiKeyValid ?? this.isApiKeyValid,
    );
  }
}

/// State when API key is being validated
class AppValidatingApiKey extends AppState {
  final String apiKey;

  const AppValidatingApiKey(this.apiKey);

  @override
  List<Object?> get props => [apiKey];
}

/// State when models are being loaded
class AppLoadingModels extends AppState {
  const AppLoadingModels();
}

/// State when user preferences are being saved
class AppSavingPreferences extends AppState {
  const AppSavingPreferences();
}

/// State when user data is being saved
class AppSavingUser extends AppState {
  const AppSavingUser();
}

/// State when user data is being cleared
class AppClearingData extends AppState {
  const AppClearingData();
}

/// State when an error occurs
class AppError extends AppState {
  final String message;
  final String? details;
  final AppState? previousState;

  const AppError(
    this.message, {
    this.details,
    this.previousState,
  });

  @override
  List<Object?> get props => [message, details, previousState];

  /// Check if this is a configuration error
  bool get isConfigurationError =>
      message.toLowerCase().contains('api key') ||
      message.toLowerCase().contains('configuration');

  /// Check if this is a network error
  bool get isNetworkError =>
      message.toLowerCase().contains('network') ||
      message.toLowerCase().contains('connection') ||
      message.toLowerCase().contains('timeout');

  /// Check if this is a validation error
  bool get isValidationError =>
      message.toLowerCase().contains('validation') ||
      message.toLowerCase().contains('invalid');
}

/// State when app needs to be configured (missing API key, etc.)
class AppNeedsConfiguration extends AppState {
  final String reason;
  final List<String> missingRequirements;

  const AppNeedsConfiguration({
    required this.reason,
    this.missingRequirements = const [],
  });

  @override
  List<Object?> get props => [reason, missingRequirements];

  /// Check if API key is missing
  bool get needsApiKey => missingRequirements.contains('api_key');

  /// Check if model selection is missing
  bool get needsModelSelection => missingRequirements.contains('model');

  /// Check if user profile is incomplete
  bool get needsUserProfile => missingRequirements.contains('user_profile');
}

/// State when app is performing initial setup
class AppInitialSetup extends AppState {
  final int currentStep;
  final int totalSteps;
  final String currentStepDescription;

  const AppInitialSetup({
    required this.currentStep,
    required this.totalSteps,
    required this.currentStepDescription,
  });

  @override
  List<Object?> get props => [currentStep, totalSteps, currentStepDescription];

  /// Calculate setup progress (0.0 to 1.0)
  double get progress => currentStep / totalSteps;

  /// Check if setup is complete
  bool get isComplete => currentStep >= totalSteps;
}