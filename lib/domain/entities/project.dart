import 'package:equatable/equatable.dart';
import 'artifact.dart';
import 'chat.dart';

/// Project domain entity representing a project that groups chats and artifacts
class Project extends Equatable {
  /// Unique identifier for the project
  final String id;
  
  /// Name of the project
  final String name;
  
  /// Optional description of the project
  final String? description;
  
  /// When the project was created
  final DateTime createdAt;
  
  /// When the project was last updated
  final DateTime updatedAt;
  
  /// List of chats associated with this project
  final List<Chat>? chats;
  
  /// List of artifacts associated with this project
  final List<Artifact>? artifacts;
  
  /// Project settings and configuration
  final ProjectSettings? settings;
  
  /// Tags for categorizing the project
  final List<String>? tags;
  
  /// Color theme for the project (hex color code)
  final String? color;
  
  /// Whether the project is archived
  final bool isArchived;
  
  /// Additional metadata for the project
  final Map<String, dynamic>? metadata;

  const Project({
    required this.id,
    required this.name,
    this.description,
    required this.createdAt,
    required this.updatedAt,
    this.chats,
    this.artifacts,
    this.settings,
    this.tags,
    this.color,
    this.isArchived = false,
    this.metadata,
  });

  /// Create a copy of this project with updated fields
  Project copyWith({
    String? id,
    String? name,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<Chat>? chats,
    List<Artifact>? artifacts,
    ProjectSettings? settings,
    List<String>? tags,
    String? color,
    bool? isArchived,
    Map<String, dynamic>? metadata,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      chats: chats ?? this.chats,
      artifacts: artifacts ?? this.artifacts,
      settings: settings ?? this.settings,
      tags: tags ?? this.tags,
      color: color ?? this.color,
      isArchived: isArchived ?? this.isArchived,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Get the number of chats in this project
  int get chatCount => chats?.length ?? 0;
  
  /// Get the number of artifacts in this project
  int get artifactCount => artifacts?.length ?? 0;
  
  /// Check if the project has any chats
  bool get hasChats => chats != null && chats!.isNotEmpty;
  
  /// Check if the project has any artifacts
  bool get hasArtifacts => artifacts != null && artifacts!.isNotEmpty;
  
  /// Check if the project has any content (chats or artifacts)
  bool get hasContent => hasChats || hasArtifacts;
  
  /// Get the most recent chat in the project
  Chat? get mostRecentChat {
    if (!hasChats) return null;
    
    var sortedChats = List<Chat>.from(chats!)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sortedChats.first;
  }
  
  /// Get the most recent artifact in the project
  Artifact? get mostRecentArtifact {
    if (!hasArtifacts) return null;
    
    var sortedArtifacts = List<Artifact>.from(artifacts!)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sortedArtifacts.first;
  }
  
  /// Check if the project name is valid
  bool get hasValidName => name.trim().isNotEmpty;

  /// Factory constructor for creating a new project
  factory Project.create({
    required String id,
    required String name,
    String? description,
    List<String>? tags,
    String? color,
    ProjectSettings? settings,
    Map<String, dynamic>? metadata,
  }) {
    final now = DateTime.now();
    return Project(
      id: id,
      name: name,
      description: description,
      createdAt: now,
      updatedAt: now,
      tags: tags,
      color: color,
      settings: settings,
      metadata: metadata,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        createdAt,
        updatedAt,
        chats,
        artifacts,
        settings,
        tags,
        color,
        isArchived,
        metadata,
      ];

  @override
  String toString() {
    return 'Project(id: $id, name: $name, chatCount: $chatCount, '
           'artifactCount: $artifactCount, createdAt: $createdAt, '
           'isArchived: $isArchived)';
  }
}

/// Project settings and configuration
class ProjectSettings extends Equatable {
  /// Default AI model for chats in this project
  final String? defaultModel;
  
  /// Default temperature setting for AI responses
  final double? defaultTemperature;
  
  /// Default max tokens for AI responses
  final int? defaultMaxTokens;
  
  /// Whether to auto-save artifacts to this project
  final bool autoSaveArtifacts;
  
  /// Whether to enable notifications for this project
  final bool enableNotifications;
  
  /// Custom system prompt for this project
  final String? systemPrompt;
  
  /// Additional custom settings
  final Map<String, dynamic>? customSettings;

  const ProjectSettings({
    this.defaultModel,
    this.defaultTemperature,
    this.defaultMaxTokens,
    this.autoSaveArtifacts = true,
    this.enableNotifications = true,
    this.systemPrompt,
    this.customSettings,
  });

  /// Create a copy with updated fields
  ProjectSettings copyWith({
    String? defaultModel,
    double? defaultTemperature,
    int? defaultMaxTokens,
    bool? autoSaveArtifacts,
    bool? enableNotifications,
    String? systemPrompt,
    Map<String, dynamic>? customSettings,
  }) {
    return ProjectSettings(
      defaultModel: defaultModel ?? this.defaultModel,
      defaultTemperature: defaultTemperature ?? this.defaultTemperature,
      defaultMaxTokens: defaultMaxTokens ?? this.defaultMaxTokens,
      autoSaveArtifacts: autoSaveArtifacts ?? this.autoSaveArtifacts,
      enableNotifications: enableNotifications ?? this.enableNotifications,
      systemPrompt: systemPrompt ?? this.systemPrompt,
      customSettings: customSettings ?? this.customSettings,
    );
  }

  @override
  List<Object?> get props => [
        defaultModel,
        defaultTemperature,
        defaultMaxTokens,
        autoSaveArtifacts,
        enableNotifications,
        systemPrompt,
        customSettings,
      ];

  @override
  String toString() {
    return 'ProjectSettings(defaultModel: $defaultModel, '
           'autoSaveArtifacts: $autoSaveArtifacts, '
           'enableNotifications: $enableNotifications)';
  }
}