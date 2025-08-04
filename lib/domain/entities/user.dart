import 'package:equatable/equatable.dart';

/// User domain entity representing a user of the application
class User extends Equatable {
  /// Unique identifier for the user
  final String id;
  
  /// User's email address
  final String? email;
  
  /// User's display name
  final String? displayName;
  
  /// URL to user's profile photo
  final String? photoUrl;
  
  /// User's Claude API key (encrypted/hashed in storage)
  final String? apiKey;
  
  /// User's preferred default AI model
  final String? defaultModel;
  
  /// User preferences (theme, notifications, etc.)
  final Map<String, dynamic> preferences;
  
  /// User settings (model configs, etc.)
  final Map<String, dynamic> settings;
  
  /// When the user account was created
  final DateTime? createdAt;
  
  /// When the user last logged in
  final DateTime? lastLoginAt;
  
  /// User's subscription/plan information
  final UserSubscription? subscription;
  
  /// User's usage statistics
  final UserUsageStats? usageStats;

  const User({
    required this.id,
    this.email,
    this.displayName,
    this.photoUrl,
    this.apiKey,
    this.defaultModel,
    this.preferences = const {},
    this.settings = const {},
    this.createdAt,
    this.lastLoginAt,
    this.subscription,
    this.usageStats,
  });

  /// Create a copy of this user with updated fields
  User copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    String? apiKey,
    String? defaultModel,
    Map<String, dynamic>? preferences,
    Map<String, dynamic>? settings,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    UserSubscription? subscription,
    UserUsageStats? usageStats,
  }) {
    return User(
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
      subscription: subscription ?? this.subscription,
      usageStats: usageStats ?? this.usageStats,
    );
  }

  /// Check if user has a valid API key
  bool get hasApiKey => apiKey != null && apiKey!.trim().isNotEmpty;
  
  /// Check if user has a complete profile
  bool get hasCompleteProfile => 
      displayName != null && displayName!.trim().isNotEmpty;
  
  /// Get user's display name or fallback to email
  String get displayNameOrEmail => 
      displayName?.isNotEmpty == true ? displayName! : 
      email?.isNotEmpty == true ? email! : 'Anonymous User';
  
  /// Get user's initials for avatar
  String get initials {
    final name = displayNameOrEmail;
    if (name.length < 2) return name.toUpperCase();
    
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, 2).toUpperCase();
  }
  
  /// Check if user is a new user (created within last 7 days)
  bool get isNewUser {
    if (createdAt == null) return false;
    return DateTime.now().difference(createdAt!).inDays <= 7;
  }
  
  /// Get specific preference value
  T? getPreference<T>(String key) {
    return preferences[key] as T?;
  }
  
  /// Get specific setting value
  T? getSetting<T>(String key) {
    return settings[key] as T?;
  }
  
  /// Get theme preference
  String get themeMode => getPreference<String>('theme') ?? 'system';
  
  /// Get notifications enabled preference
  bool get notificationsEnabled => getPreference<bool>('notifications') ?? true;
  
  /// Get auto-save preference
  bool get autoSaveEnabled => getPreference<bool>('auto_save') ?? true;

  /// Factory constructor for creating a new user
  factory User.create({
    required String id,
    String? email,
    String? displayName,
    String? photoUrl,
    String? apiKey,
    String? defaultModel,
    Map<String, dynamic>? preferences,
    Map<String, dynamic>? settings,
  }) {
    final now = DateTime.now();
    return User(
      id: id,
      email: email,
      displayName: displayName,
      photoUrl: photoUrl,
      apiKey: apiKey,
      defaultModel: defaultModel,
      preferences: preferences ?? {},
      settings: settings ?? {},
      createdAt: now,
      lastLoginAt: now,
    );
  }

  /// Factory constructor for anonymous user
  factory User.anonymous(String id) {
    return User.create(
      id: id,
      displayName: 'Anonymous User',
      preferences: {
        'theme': 'system',
        'notifications': false,
        'auto_save': true,
      },
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        displayName,
        photoUrl,
        apiKey,
        defaultModel,
        preferences,
        settings,
        createdAt,
        lastLoginAt,
        subscription,
        usageStats,
      ];

  @override
  String toString() {
    return 'User(id: $id, displayName: $displayName, email: $email, '
           'hasApiKey: $hasApiKey, createdAt: $createdAt)';
  }
}

/// User subscription information
class UserSubscription extends Equatable {
  /// Type of subscription (free, pro, enterprise)
  final String type;
  
  /// When the subscription started
  final DateTime startDate;
  
  /// When the subscription expires (null for lifetime)
  final DateTime? expiryDate;
  
  /// Whether the subscription is currently active
  final bool isActive;
  
  /// Monthly token allowance
  final int? monthlyTokenLimit;
  
  /// Additional features enabled
  final List<String> enabledFeatures;

  const UserSubscription({
    required this.type,
    required this.startDate,
    this.expiryDate,
    this.isActive = true,
    this.monthlyTokenLimit,
    this.enabledFeatures = const [],
  });

  /// Check if subscription is expired
  bool get isExpired => 
      expiryDate != null && DateTime.now().isAfter(expiryDate!);
  
  /// Check if subscription is valid (active and not expired)
  bool get isValid => isActive && !isExpired;
  
  /// Check if user has feature enabled
  bool hasFeature(String feature) => enabledFeatures.contains(feature);

  @override
  List<Object?> get props => [
        type,
        startDate,
        expiryDate,
        isActive,
        monthlyTokenLimit,
        enabledFeatures,
      ];
}

/// User usage statistics
class UserUsageStats extends Equatable {
  /// Total tokens used this month
  final int monthlyTokensUsed;
  
  /// Total tokens used all time
  final int totalTokensUsed;
  
  /// Number of chats created
  final int totalChats;
  
  /// Number of projects created
  final int totalProjects;
  
  /// Number of artifacts created
  final int totalArtifacts;
  
  /// Last reset date for monthly stats
  final DateTime lastResetDate;
  
  /// Additional usage metrics
  final Map<String, dynamic>? additionalMetrics;

  const UserUsageStats({
    this.monthlyTokensUsed = 0,
    this.totalTokensUsed = 0,
    this.totalChats = 0,
    this.totalProjects = 0,
    this.totalArtifacts = 0,
    required this.lastResetDate,
    this.additionalMetrics,
  });

  /// Create a copy with updated fields
  UserUsageStats copyWith({
    int? monthlyTokensUsed,
    int? totalTokensUsed,
    int? totalChats,
    int? totalProjects,
    int? totalArtifacts,
    DateTime? lastResetDate,
    Map<String, dynamic>? additionalMetrics,
  }) {
    return UserUsageStats(
      monthlyTokensUsed: monthlyTokensUsed ?? this.monthlyTokensUsed,
      totalTokensUsed: totalTokensUsed ?? this.totalTokensUsed,
      totalChats: totalChats ?? this.totalChats,
      totalProjects: totalProjects ?? this.totalProjects,
      totalArtifacts: totalArtifacts ?? this.totalArtifacts,
      lastResetDate: lastResetDate ?? this.lastResetDate,
      additionalMetrics: additionalMetrics ?? this.additionalMetrics,
    );
  }

  @override
  List<Object?> get props => [
        monthlyTokensUsed,
        totalTokensUsed,
        totalChats,
        totalProjects,
        totalArtifacts,
        lastResetDate,
        additionalMetrics,
      ];
}