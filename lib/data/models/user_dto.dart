// lib/data/models/user_dto.dart
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
    return UserDTO(
      id: json['id'] as String,
      email: json['email'] as String?,
      displayName: json['displayName'] as String?,
      photoUrl: json['photoUrl'] as String?,
      apiKey: json['apiKey'] as String?,
      defaultModel: json['defaultModel'] as String?,
      preferences: json['preferences'] as Map<String, dynamic>?,
      settings: json['settings'] as Map<String, dynamic>?,
      createdAt: json['createdAt'] as int?,
      lastLoginAt: json['lastLoginAt'] as int?,
    );
  }

  /// Convert to Firebase JSON
  Map<String, dynamic> toFirebaseJson() {
    final json = <String, dynamic>{
      'id': id,
    };

    if (email != null) json['email'] = email;
    if (displayName != null) json['displayName'] = displayName;
    if (photoUrl != null) json['photoUrl'] = photoUrl;
    if (apiKey != null) json['apiKey'] = apiKey;
    if (defaultModel != null) json['defaultModel'] = defaultModel;
    if (preferences != null) json['preferences'] = preferences;
    if (settings != null) json['settings'] = settings;
    if (createdAt != null) json['createdAt'] = createdAt;
    if (lastLoginAt != null) json['lastLoginAt'] = lastLoginAt;

    return json;
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

  @override
  String toString() {
    return 'UserDTO{id: $id, email: $email, displayName: $displayName}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserDTO && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}