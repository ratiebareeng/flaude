import 'package:claude_chat_clone/core/error/failures.dart';
import 'package:claude_chat_clone/domain/entities/entities.dart';
import 'package:dartz/dartz.dart';

/// Abstract repository interface for user-related operations
///
/// Defines the contract for user data, preferences, and local storage operations
/// that will be implemented by the data layer. Uses Either<Failure, T> for
/// comprehensive error handling.
abstract class UserRepository {
  // ============================================================================
  // USER PROFILE OPERATIONS
  // ============================================================================

  /// Clear all user data and preferences
  ///
  /// Returns [Right] with void on success, [Left] with [DatabaseFailure] on error
  Future<Either<Failure, void>> clearAllData();

  /// Clear all user preferences
  ///
  /// Returns [Right] with void on success, [Left] with [DatabaseFailure] on error
  Future<Either<Failure, void>> clearUserPreferences();

  /// Delete stored API key
  ///
  /// Returns [Right] with void on success, [Left] with [ConfigurationFailure] on error
  Future<Either<Failure, void>> deleteApiKey();

  /// Delete user profile data
  ///
  /// Returns [Right] with void on success, [Left] with [DatabaseFailure] on error
  Future<Either<Failure, void>> deleteUser();

  // ============================================================================
  // API KEY MANAGEMENT
  // ============================================================================

  /// Get stored Claude API key
  ///
  /// Returns [Right] with API key (nullable), [Left] with [ConfigurationFailure] on error
  Future<Either<Failure, String?>> getApiKey();

  /// Get last selected chat ID
  ///
  /// Returns [Right] with chat ID (nullable), [Left] with [DatabaseFailure] on error
  Future<Either<Failure, String?>> getLastSelectedChatId();

  /// Get last selected project ID
  ///
  /// Returns [Right] with project ID (nullable), [Left] with [DatabaseFailure] on error
  Future<Either<Failure, String?>> getLastSelectedProjectId();

  // ============================================================================
  // USER PREFERENCES
  // ============================================================================

  /// Get notifications enabled status
  ///
  /// Returns [Right] with boolean result, [Left] with [DatabaseFailure] on error
  Future<Either<Failure, bool>> getNotificationsEnabled();

  /// Get list of recent chat IDs
  ///
  /// Returns [Right] with chat ID list, [Left] with [DatabaseFailure] on error
  Future<Either<Failure, List<String>>> getRecentChatIds();

  /// Get selected AI model
  ///
  /// Returns [Right] with model string (nullable), [Left] with [DatabaseFailure] on error
  Future<Either<Failure, String?>> getSelectedModel();

  /// Get list of starred chat IDs
  ///
  /// Returns [Right] with chat ID list, [Left] with [DatabaseFailure] on error
  Future<Either<Failure, List<String>>> getStarredChatIds();

  /// Get theme mode preference
  ///
  /// Returns [Right] with theme mode (nullable), [Left] with [DatabaseFailure] on error
  Future<Either<Failure, String?>> getThemeMode();

  /// Get user profile data
  ///
  /// Returns [Right] with user (nullable), [Left] with [DatabaseFailure] on error
  Future<Either<Failure, User?>> getUser();

  // ============================================================================
  // APP SETTINGS
  // ============================================================================

  /// Get a specific user preference
  ///
  /// Returns [Right] with preference value (nullable), [Left] with [DatabaseFailure] on error
  Future<Either<Failure, T?>> getUserPreference<T>(String key);

  /// Get all user preferences
  ///
  /// Returns [Right] with preferences map, [Left] with [DatabaseFailure] on error
  Future<Either<Failure, Map<String, dynamic>>> getUserPreferences();

  /// Check if user data exists locally
  ///
  /// Returns [Right] with boolean result, [Left] with [DatabaseFailure] on error
  Future<Either<Failure, bool>> hasUserData();

  /// Remove a specific user preference
  ///
  /// Returns [Right] with void on success, [Left] with [DatabaseFailure] on error
  Future<Either<Failure, void>> removeUserPreference(String key);

  /// Save Claude API key securely
  ///
  /// Returns [Right] with void on success, [Left] with [ConfigurationFailure] on error
  Future<Either<Failure, void>> saveApiKey(String apiKey);

  /// Save last selected chat ID
  ///
  /// Returns [Right] with void on success, [Left] with [DatabaseFailure] on error
  Future<Either<Failure, void>> saveLastSelectedChatId(String chatId);

  // ============================================================================
  // APP STATE PERSISTENCE
  // ============================================================================

  /// Save last selected project ID
  ///
  /// Returns [Right] with void on success, [Left] with [DatabaseFailure] on error
  Future<Either<Failure, void>> saveLastSelectedProjectId(String projectId);

  /// Save list of recent chat IDs
  ///
  /// Returns [Right] with void on success, [Left] with [DatabaseFailure] on error
  Future<Either<Failure, void>> saveRecentChatIds(List<String> chatIds);

  /// Save selected AI model
  ///
  /// Returns [Right] with void on success, [Left] with [DatabaseFailure] on error
  Future<Either<Failure, void>> saveSelectedModel(String model);

  /// Save list of starred chat IDs
  ///
  /// Returns [Right] with void on success, [Left] with [DatabaseFailure] on error
  Future<Either<Failure, void>> saveStarredChatIds(List<String> chatIds);

  // ============================================================================
  // RECENT DATA CACHING
  // ============================================================================

  /// Save theme mode preference
  ///
  /// Returns [Right] with void on success, [Left] with [DatabaseFailure] on error
  Future<Either<Failure, void>> saveThemeMode(String themeMode);

  /// Save user profile data
  ///
  /// Returns [Right] with void on success, [Left] with [DatabaseFailure] on error
  Future<Either<Failure, void>> saveUser(User user);

  /// Save user preferences map
  ///
  /// Returns [Right] with void on success, [Left] with [DatabaseFailure] on error
  Future<Either<Failure, void>> saveUserPreferences(
    Map<String, dynamic> preferences,
  );

  /// Set notifications enabled/disabled
  ///
  /// Returns [Right] with void on success, [Left] with [DatabaseFailure] on error
  Future<Either<Failure, void>> setNotificationsEnabled(bool enabled);

  // ============================================================================
  // DATA MANAGEMENT
  // ============================================================================

  /// Set a specific user preference
  ///
  /// Returns [Right] with void on success, [Left] with [DatabaseFailure] on error
  Future<Either<Failure, void>> setUserPreference(String key, dynamic value);
}
