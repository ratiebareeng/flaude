import 'package:claude_chat_clone/core/utils/utils.dart';

import 'model_helper.dart';

/// Data Transfer Object for User - handles Firebase Auth and user data
class UserDTO {
  final String id;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final String? apiKey;
  final String? defaultModel;
  final Map<String, dynamic>? preferences;
  final Map<String, dynamic>? settings;
  final int? createdAt;
  final int? lastLoginAt;

  const UserDTO({
    required this.id,
    this.email,
    this.displayName,
    this.photoUrl,
    this.apiKey,
    this.defaultModel,
    this.preferences,
    this.settings,
    this.createdAt,
    this.lastLoginAt,
  });

  /// Create UserDTO from Firebase JSON
  factory UserDTO.fromFirebaseJson(Map<String, dynamic> json) {
    return ModelHelper.safeParse(
      () => UserDTO(
        id: ModelHelper.parseString(json['id']),
        email: StringUtils.isNullOrEmpty(json['email'] as String?)
            ? null
            : json['email'] as String,
        displayName: StringUtils.isNullOrEmpty(json['displayName'] as String?)
            ? null
            : ModelHelper.sanitizeString(json['displayName'] as String?,
                maxLength: 100),
        photoUrl: StringUtils.isNullOrEmpty(json['photoUrl'] as String?)
            ? null
            : json['photoUrl'] as String,
        apiKey: StringUtils.isNullOrEmpty(json['apiKey'] as String?)
            ? null
            : json['apiKey'] as String,
        defaultModel: StringUtils.isNullOrEmpty(json['defaultModel'] as String?)
            ? null
            : json['defaultModel'] as String,
        preferences: ModelHelper.parseNullableMap(json['preferences']),
        settings: ModelHelper.parseNullableMap(json['settings']),
        createdAt: json['createdAt'] != null
            ? ModelHelper.parseTimestamp(json['createdAt'])
            : null,
        lastLoginAt: json['lastLoginAt'] != null
            ? ModelHelper.parseTimestamp(json['lastLoginAt'])
            : null,
      ),
      UserDTO(id: ''),
      context: 'UserDTO.fromFirebaseJson',
    );
  }

  /// Get formatted creation date
  String? get formattedCreatedAt {
    return createdAt != null
        ? DateTimeUtils.formatDisplayDateTime(
            DateTimeUtils.fromMilliseconds(createdAt!))
        : null;
  }

  /// Get formatted last login date
  String? get formattedLastLogin {
    return lastLoginAt != null
        ? DateTimeUtils.formatDisplayDateTime(
            DateTimeUtils.fromMilliseconds(lastLoginAt!))
        : null;
  }

  @override
  int get hashCode => id.hashCode;

  /// Check if user has valid API key
  bool get hasValidApiKey {
    return apiKey != null && ValidationUtils.validateApiKey(apiKey).isValid;
  }

  /// Get user initials for avatar display
  String get initials {
    if (StringUtils.isNotNullOrEmpty(displayName)) {
      return StringUtils.extractInitials(displayName!, maxInitials: 2);
    }
    if (StringUtils.isNotNullOrEmpty(email)) {
      return StringUtils.extractInitials(email!.split('@')[0], maxInitials: 2);
    }
    return StringUtils.extractInitials(id, maxInitials: 2);
  }

  /// Get masked email for display
  String? get maskedEmail {
    return email != null ? StringUtils.maskEmail(email!) : null;
  }

  /// Get relative last login time
  String? get relativeLastLogin {
    return lastLoginAt != null
        ? DateTimeUtils.formatRelativeTime(
            DateTimeUtils.fromMilliseconds(lastLoginAt!))
        : null;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserDTO && other.id == id;
  }

  /// Create a copy with updated fields
  UserDTO copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    String? apiKey,
    String? defaultModel,
    Map<String, dynamic>? preferences,
    Map<String, dynamic>? settings,
    int? createdAt,
    int? lastLoginAt,
  }) {
    return UserDTO(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      apiKey: apiKey ?? this.apiKey,
      defaultModel: defaultModel ?? this.defaultModel,
      preferences: preferences ?? this.preferences,
      settings: settings ?? this.settings,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }

  /// Get user preferences with defaults
  T getPreference<T>(String key, T defaultValue) {
    if (preferences == null) return defaultValue;

    final value = preferences![key];
    if (value is T) return value;

    // Try to parse the value
    try {
      if (T == String)
        return ModelHelper.parseString(value, fallback: defaultValue as String)
            as T;
      if (T == int)
        return ModelHelper.parseInt(value, fallback: defaultValue as int) as T;
      if (T == double)
        return ModelHelper.parseDouble(value, fallback: defaultValue as double)
            as T;
      if (T == bool)
        return ModelHelper.parseBool(value, fallback: defaultValue as bool)
            as T;
    } catch (e) {
      // Return default if parsing fails
    }

    return defaultValue;
  }

  /// Get validation errors
  Map<String, String> getValidationErrors() {
    final errors = <String, String>{};

    if (id.isEmpty) {
      errors['id'] = 'User ID cannot be empty';
    }

    if (email != null) {
      final emailValidation = ValidationUtils.validateEmail(email);
      if (!emailValidation.isValid) {
        errors['email'] = emailValidation.errorMessage ?? 'Invalid email';
      }
    }

    if (apiKey != null) {
      final apiKeyValidation = ValidationUtils.validateApiKey(apiKey);
      if (!apiKeyValidation.isValid) {
        errors['apiKey'] = apiKeyValidation.errorMessage ?? 'Invalid API key';
      }
    }

    if (photoUrl != null) {
      final urlValidation = ValidationUtils.validateUrl(photoUrl);
      if (!urlValidation.isValid) {
        errors['photoUrl'] = urlValidation.errorMessage ?? 'Invalid photo URL';
      }
    }

    return errors;
  }

  /// Check if user is active (logged in recently)
  bool isActive({Duration threshold = const Duration(days: 30)}) {
    if (lastLoginAt == null) return false;

    final lastLogin = DateTimeUtils.fromMilliseconds(lastLoginAt!);
    final cutoff = DateTime.now().subtract(threshold);

    return lastLogin.isAfter(cutoff);
  }

  /// Validate user data
  bool isValid() {
    return id.isNotEmpty &&
        (email == null || ValidationUtils.validateEmail(email).isValid) &&
        (apiKey == null || ValidationUtils.validateApiKey(apiKey).isValid) &&
        (photoUrl == null || ValidationUtils.validateUrl(photoUrl).isValid);
  }

  /// Remove user preference
  UserDTO removePreference(String key) {
    if (preferences == null) return this;
    final newPreferences = Map<String, dynamic>.from(preferences!);
    newPreferences.remove(key);
    return copyWith(preferences: newPreferences);
  }

  /// Set user preference
  UserDTO setPreference(String key, dynamic value) {
    final newPreferences = Map<String, dynamic>.from(preferences ?? {});
    newPreferences[key] = value;
    return copyWith(preferences: newPreferences);
  }

  /// Convert to Firebase JSON
  Map<String, dynamic> toFirebaseJson() {
    final json = <String, dynamic>{
      'id': id,
    };

    if (StringUtils.isNotNullOrEmpty(email)) json['email'] = email;
    if (StringUtils.isNotNullOrEmpty(displayName)) {
      json['displayName'] =
          ModelHelper.sanitizeString(displayName, maxLength: 100);
    }
    if (StringUtils.isValidUrl(photoUrl ?? '')) json['photoUrl'] = photoUrl;
    if (StringUtils.isNotNullOrEmpty(apiKey)) json['apiKey'] = apiKey;
    if (StringUtils.isNotNullOrEmpty(defaultModel))
      json['defaultModel'] = defaultModel;

    if (preferences != null && preferences!.isNotEmpty) {
      json['preferences'] = ModelHelper.cleanMap(preferences!);
    }
    if (settings != null && settings!.isNotEmpty) {
      json['settings'] = ModelHelper.cleanMap(settings!);
    }

    if (createdAt != null) json['createdAt'] = createdAt;
    if (lastLoginAt != null) json['lastLoginAt'] = lastLoginAt;

    return ModelHelper.cleanMap(json);
  }

  @override
  String toString() {
    return 'UserDTO{id: $id, email: $maskedEmail, displayName: $displayName}';
  }

  /// Update last login timestamp
  UserDTO updateLastLogin() {
    return copyWith(lastLoginAt: DateTimeUtils.currentTimestampMillis());
  }
}
