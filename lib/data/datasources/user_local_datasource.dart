import 'dart:convert';

import 'package:claude_chat_clone/core/constants/constants.dart';
import 'package:claude_chat_clone/core/error/exceptions.dart';
import 'package:claude_chat_clone/core/utils/utils.dart';
import 'package:claude_chat_clone/data/datasources/base/local_datasource.dart';
import 'package:claude_chat_clone/data/datasources/interfaces/user_local_datasource_interface.dart';
import 'package:claude_chat_clone/data/models/data_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// SharedPreferences implementation of user local datasource
class UserLocalDatasourceImpl extends LocalDatasource
    implements UserLocalDatasource {
  // Keys for SharedPreferences
  static const String _userKey = 'user_data';
  static const String _apiKeyKey = 'api_key';
  static const String _preferencesKey = 'user_preferences';
  static const String _selectedModelKey = 'selected_model';
  static const String _themeModeKey = 'theme_mode';
  static const String _notificationsKey = 'notifications_enabled';
  static const String _recentChatsKey = 'recent_chat_ids';
  static const String _starredChatsKey = 'starred_chat_ids';
  static const String _lastChatIdKey = 'last_selected_chat_id';
  static const String _lastProjectIdKey = 'last_selected_project_id';
  static const String _firstRunKey = 'first_run';

  @override
  Future<void> clearAllData() async {
    return performStorageOperation(
      () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
      },
      context: 'UserLocalDatasource.clearAllData',
      customMessage: 'Failed to clear all user data',
    );
  }

  @override
  Future<void> clearUserPreferences() async {
    return performStorageOperation(
      () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(_preferencesKey);
      },
      context: 'UserLocalDatasource.clearUserPreferences',
      customMessage: 'Failed to clear user preferences',
    );
  }

  @override
  Future<void> deleteApiKey() async {
    return performStorageOperation(
      () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(_apiKeyKey);
      },
      context: 'UserLocalDatasource.deleteApiKey',
      customMessage: 'Failed to delete API key',
    );
  }

  @override
  Future<void> deleteUser() async {
    return performStorageOperation(
      () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(_userKey);
      },
      context: 'UserLocalDatasource.deleteUser',
      customMessage: 'Failed to delete user data',
    );
  }

  @override
  Future<String?> getApiKey() async {
    return performStorageOperation(
      () async {
        final prefs = await SharedPreferences.getInstance();
        final encryptedKey = prefs.getString(_apiKeyKey);

        if (encryptedKey == null || encryptedKey.isEmpty) {
          return null;
        }

        // For security, you might want to encrypt/decrypt the API key
        // For now, we'll store it as-is but validate the format
        if (ValidationUtils.validateApiKey(encryptedKey).isValid) {
          return encryptedKey;
        }

        // Invalid API key stored, remove it
        await prefs.remove(_apiKeyKey);
        return null;
      },
      context: 'UserLocalDatasource.getApiKey',
      customMessage: 'Failed to retrieve API key',
    );
  }

  @override
  Future<String?> getLastSelectedChatId() async {
    return performStorageOperation(
      () async {
        final prefs = await SharedPreferences.getInstance();
        return prefs.getString(_lastChatIdKey);
      },
      context: 'UserLocalDatasource.getLastSelectedChatId',
    );
  }

  @override
  Future<String?> getLastSelectedProjectId() async {
    return performStorageOperation(
      () async {
        final prefs = await SharedPreferences.getInstance();
        return prefs.getString(_lastProjectIdKey);
      },
      context: 'UserLocalDatasource.getLastSelectedProjectId',
    );
  }

  @override
  Future<bool> getNotificationsEnabled() async {
    return performStorageOperation(
      () async {
        final prefs = await SharedPreferences.getInstance();
        return prefs.getBool(_notificationsKey) ?? true; // Default to enabled
      },
      context: 'UserLocalDatasource.getNotificationsEnabled',
    );
  }

  @override
  Future<List<String>> getRecentChatIds() async {
    return performStorageOperation(
      () async {
        final prefs = await SharedPreferences.getInstance();
        final idsJson = prefs.getString(_recentChatsKey);

        if (idsJson == null || idsJson.isEmpty) {
          return <String>[];
        }

        try {
          final List<dynamic> idsList = jsonDecode(idsJson);
          return idsList.map((id) => id.toString()).toList();
        } catch (e) {
          // Corrupted data, remove it
          await prefs.remove(_recentChatsKey);
          return <String>[];
        }
      },
      context: 'UserLocalDatasource.getRecentChatIds',
      customMessage: 'Failed to retrieve recent chat IDs',
    );
  }

  @override
  Future<String?> getSelectedModel() async {
    return performStorageOperation(
      () async {
        final prefs = await SharedPreferences.getInstance();
        final model = prefs.getString(_selectedModelKey);

        // Return default model if none stored or invalid
        return model ?? ApiConstants.defaultModelId;
      },
      context: 'UserLocalDatasource.getSelectedModel',
    );
  }

  @override
  Future<List<String>> getStarredChatIds() async {
    return performStorageOperation(
      () async {
        final prefs = await SharedPreferences.getInstance();
        final idsJson = prefs.getString(_starredChatsKey);

        if (idsJson == null || idsJson.isEmpty) {
          return <String>[];
        }

        try {
          final List<dynamic> idsList = jsonDecode(idsJson);
          return idsList.map((id) => id.toString()).toList();
        } catch (e) {
          // Corrupted data, remove it
          await prefs.remove(_starredChatsKey);
          return <String>[];
        }
      },
      context: 'UserLocalDatasource.getStarredChatIds',
      customMessage: 'Failed to retrieve starred chat IDs',
    );
  }

  @override
  Future<String?> getThemeMode() async {
    return performStorageOperation(
      () async {
        final prefs = await SharedPreferences.getInstance();
        return prefs.getString(_themeModeKey) ?? 'dark'; // Default to dark
      },
      context: 'UserLocalDatasource.getThemeMode',
    );
  }

  @override
  Future<UserDTO?> getUser() async {
    return performStorageOperation(
      () async {
        final prefs = await SharedPreferences.getInstance();
        final userJson = prefs.getString(_userKey);

        if (userJson == null || userJson.isEmpty) {
          return null;
        }

        try {
          final userData = jsonDecode(userJson) as Map<String, dynamic>;
          final user = UserDTO.fromFirebaseJson(userData);

          return user.isValid() ? user : null;
        } catch (e) {
          // Corrupted user data, remove it
          await prefs.remove(_userKey);
          return null;
        }
      },
      context: 'UserLocalDatasource.getUser',
      customMessage: 'Failed to retrieve user data',
    );
  }

  @override
  Future<T?> getUserPreference<T>(String key) async {
    return performStorageOperation(
      () async {
        final preferences = await getUserPreferences();
        final value = preferences[key];

        if (value is T) {
          return value;
        }

        return null;
      },
      context: 'UserLocalDatasource.getUserPreference',
      customMessage: 'Failed to retrieve user preference',
    );
  }

  @override
  Future<Map<String, dynamic>> getUserPreferences() async {
    return performStorageOperation(
      () async {
        final prefs = await SharedPreferences.getInstance();
        final prefsJson = prefs.getString(_preferencesKey);

        if (prefsJson == null || prefsJson.isEmpty) {
          return <String, dynamic>{};
        }

        try {
          return Map<String, dynamic>.from(jsonDecode(prefsJson));
        } catch (e) {
          // Corrupted preferences, remove them
          await prefs.remove(_preferencesKey);
          return <String, dynamic>{};
        }
      },
      context: 'UserLocalDatasource.getUserPreferences',
      customMessage: 'Failed to retrieve user preferences',
    );
  }

  @override
  Future<bool> hasUserData() async {
    return performStorageOperation(
      () async {
        final prefs = await SharedPreferences.getInstance();
        return prefs.containsKey(_userKey) ||
            prefs.containsKey(_apiKeyKey) ||
            prefs.containsKey(_preferencesKey);
      },
      context: 'UserLocalDatasource.hasUserData',
    );
  }

  @override
  Future<void> removeUserPreference(String key) async {
    return performStorageOperation(
      () async {
        final preferences = await getUserPreferences();
        preferences.remove(key);
        await saveUserPreferences(preferences);
      },
      context: 'UserLocalDatasource.removeUserPreference',
      customMessage: 'Failed to remove user preference',
    );
  }

  @override
  Future<void> saveApiKey(String apiKey) async {
    return performStorageOperation(
      () async {
        // Validate API key before saving
        final validation = ValidationUtils.validateApiKey(apiKey);
        if (!validation.isValid) {
          throw ValidationException.invalidInput(
            field: 'apiKey',
            reason: validation.errorMessage ?? 'Invalid API key',
          );
        }

        final prefs = await SharedPreferences.getInstance();

        // For security, you might want to encrypt the API key here
        // For now, we'll store it as-is
        await prefs.setString(_apiKeyKey, apiKey.trim());
      },
      context: 'UserLocalDatasource.saveApiKey',
      customMessage: 'Failed to save API key',
    );
  }

  @override
  Future<void> saveLastSelectedChatId(String chatId) async {
    return performStorageOperation(
      () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_lastChatIdKey, chatId);
      },
      context: 'UserLocalDatasource.saveLastSelectedChatId',
    );
  }

  @override
  Future<void> saveLastSelectedProjectId(String projectId) async {
    return performStorageOperation(
      () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_lastProjectIdKey, projectId);
      },
      context: 'UserLocalDatasource.saveLastSelectedProjectId',
    );
  }

  @override
  Future<void> saveRecentChatIds(List<String> chatIds) async {
    return performStorageOperation(
      () async {
        final prefs = await SharedPreferences.getInstance();

        // Limit to maximum recent chats
        final limitedIds = chatIds.take(AppConstants.maxRecentChats).toList();
        final idsJson = jsonEncode(limitedIds);

        await prefs.setString(_recentChatsKey, idsJson);
      },
      context: 'UserLocalDatasource.saveRecentChatIds',
      customMessage: 'Failed to save recent chat IDs',
    );
  }

  @override
  Future<void> saveSelectedModel(String model) async {
    return performStorageOperation(
      () async {
        if (StringUtils.isNullOrEmpty(model)) {
          throw ValidationException.invalidInput(
            field: 'model',
            reason: 'Model cannot be empty',
          );
        }

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_selectedModelKey, model.trim());
      },
      context: 'UserLocalDatasource.saveSelectedModel',
      customMessage: 'Failed to save selected model',
    );
  }

  @override
  Future<void> saveStarredChatIds(List<String> chatIds) async {
    return performStorageOperation(
      () async {
        final prefs = await SharedPreferences.getInstance();

        // Limit to maximum starred chats
        final limitedIds = chatIds.take(AppConstants.maxStarredChats).toList();
        final idsJson = jsonEncode(limitedIds);

        await prefs.setString(_starredChatsKey, idsJson);
      },
      context: 'UserLocalDatasource.saveStarredChatIds',
      customMessage: 'Failed to save starred chat IDs',
    );
  }

  @override
  Future<void> saveThemeMode(String themeMode) async {
    return performStorageOperation(
      () async {
        // Validate theme mode
        const validThemes = ['light', 'dark', 'system'];
        if (!validThemes.contains(themeMode.toLowerCase())) {
          throw ValidationException.invalidInput(
            field: 'themeMode',
            reason:
                'Invalid theme mode. Must be one of: ${validThemes.join(', ')}',
          );
        }

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_themeModeKey, themeMode.toLowerCase());
      },
      context: 'UserLocalDatasource.saveThemeMode',
      customMessage: 'Failed to save theme mode',
    );
  }

  @override
  Future<void> saveUser(UserDTO user) async {
    return performStorageOperation(
      () async {
        if (!user.isValid()) {
          throw ValidationException.multipleErrors(user.getValidationErrors());
        }

        final prefs = await SharedPreferences.getInstance();

        // Update last login timestamp
        final updatedUser = user.updateLastLogin();

        final userJson = jsonEncode(updatedUser.toFirebaseJson());
        await prefs.setString(_userKey, userJson);
      },
      context: 'UserLocalDatasource.saveUser',
      customMessage: 'Failed to save user data',
    );
  }

  @override
  Future<void> saveUserPreferences(Map<String, dynamic> preferences) async {
    return performStorageOperation(
      () async {
        final prefs = await SharedPreferences.getInstance();

        // Clean the preferences map to remove null/invalid values
        final cleanedPrefs = preferences.entries
            .where((entry) => entry.value != null)
            .fold<Map<String, dynamic>>(
          {},
          (map, entry) => map..[entry.key] = entry.value,
        );

        final prefsJson = jsonEncode(cleanedPrefs);
        await prefs.setString(_preferencesKey, prefsJson);
      },
      context: 'UserLocalDatasource.saveUserPreferences',
      customMessage: 'Failed to save user preferences',
    );
  }

  @override
  Future<void> setNotificationsEnabled(bool enabled) async {
    return performStorageOperation(
      () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_notificationsKey, enabled);
      },
      context: 'UserLocalDatasource.setNotificationsEnabled',
    );
  }

  @override
  Future<void> setUserPreference(String key, dynamic value) async {
    return performStorageOperation(
      () async {
        if (StringUtils.isNullOrEmpty(key)) {
          throw ValidationException.invalidInput(
            field: 'key',
            reason: 'Preference key cannot be empty',
          );
        }

        final preferences = await getUserPreferences();
        preferences[key] = value;
        await saveUserPreferences(preferences);
      },
      context: 'UserLocalDatasource.setUserPreference',
      customMessage: 'Failed to set user preference',
    );
  }
}
