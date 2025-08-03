import 'package:claude_chat_clone/data/models/user_dto.dart';

/// Abstract interface for user local data operations
abstract class UserLocalDatasource {
  // Cache management
  Future<void> clearAllData();
  Future<void> clearUserPreferences();
  Future<void> deleteApiKey();

  Future<void> deleteUser();
  // API key management
  Future<String?> getApiKey();
  // App state persistence
  Future<String?> getLastSelectedChatId();

  Future<String?> getLastSelectedProjectId();
  Future<bool> getNotificationsEnabled();
  // Recent data caching
  Future<List<String>> getRecentChatIds();
  // App settings
  Future<String?> getSelectedModel();
  Future<List<String>> getStarredChatIds();
  Future<String?> getThemeMode();

  // User profile operations
  Future<UserDTO?> getUser();
  Future<T?> getUserPreference<T>(String key);
  // User preferences
  Future<Map<String, dynamic>> getUserPreferences();
  Future<bool> hasUserData();
  Future<void> removeUserPreference(String key);
  Future<void> saveApiKey(String apiKey);

  Future<void> saveLastSelectedChatId(String chatId);
  Future<void> saveLastSelectedProjectId(String projectId);
  Future<void> saveRecentChatIds(List<String> chatIds);
  Future<void> saveSelectedModel(String model);

  Future<void> saveStarredChatIds(List<String> chatIds);
  Future<void> saveThemeMode(String themeMode);
  Future<void> saveUser(UserDTO user);
  Future<void> saveUserPreferences(Map<String, dynamic> preferences);

  Future<void> setNotificationsEnabled(bool enabled);
  Future<void> setUserPreference(String key, dynamic value);
}
