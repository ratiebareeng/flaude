import 'package:claude_chat_clone/core/utils/utils.dart';
import 'package:claude_chat_clone/domain/models/project.dart';

import 'model_helper.dart';

/// Data Transfer Object for Project - handles Firebase RTDB serialization
class ProjectDTO {
  final String id;
  final String name;
  final String description;
  final int createdAt;
  final int updatedAt;
  final Map<String, dynamic>? settings;
  final List<String>? tags;
  final Map<String, dynamic>? metadata;

  const ProjectDTO({
    required this.id,
    required this.name,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
    this.settings,
    this.tags,
    this.metadata,
  });

  /// Create ProjectDTO from domain Project model
  factory ProjectDTO.fromDomain(Project project) {
    return ProjectDTO(
      id: project.id,
      name: StringUtils.truncate(
          ModelHelper.sanitizeString(project.name, maxLength: 50), 50),
      description: StringUtils.truncate(
          ModelHelper.sanitizeString(project.description, maxLength: 500), 500),
      createdAt: project.createdAt.millisecondsSinceEpoch,
      updatedAt: project.updatedAt.millisecondsSinceEpoch,
    );
  }

  /// Create ProjectDTO from Firebase JSON
  factory ProjectDTO.fromFirebaseJson(Map<String, dynamic> json) {
    return ModelHelper.safeParse(
      () => ProjectDTO(
        id: ModelHelper.parseString(json['id']),
        name: ModelHelper.parseString(json['name']),
        description: ModelHelper.parseString(json['description']),
        createdAt: ModelHelper.parseTimestamp(json['createdAt']),
        updatedAt: ModelHelper.parseTimestamp(json['updatedAt']),
        settings: ModelHelper.parseNullableMap(json['settings']),
        tags: ModelHelper.parseNullableStringList(json['tags']),
        metadata: ModelHelper.parseNullableMap(json['metadata']),
      ),
      ProjectDTO(
        id: '',
        name: 'Untitled Project',
        description: '',
        createdAt: DateTimeUtils.currentTimestampMillis(),
        updatedAt: DateTimeUtils.currentTimestampMillis(),
      ),
      context: 'ProjectDTO.fromFirebaseJson',
    );
  }

  /// Get formatted creation date
  String get formattedCreatedAt {
    return DateTimeUtils.formatDisplayDateTime(
        DateTimeUtils.fromMilliseconds(createdAt));
  }

  /// Get formatted update date
  String get formattedUpdatedAt {
    return DateTimeUtils.formatDisplayDateTime(
        DateTimeUtils.fromMilliseconds(updatedAt));
  }

  @override
  int get hashCode => id.hashCode;

  /// Get project initials for avatar display
  String get initials {
    return StringUtils.extractInitials(name, maxInitials: 2);
  }

  /// Get relative update time (e.g., "Updated 2 hours ago")
  String get relativeUpdateTime {
    return 'Updated ${DateTimeUtils.formatRelativeTime(DateTimeUtils.fromMilliseconds(updatedAt))}';
  }

  /// Generate a slug from the project name
  String get slug {
    return StringUtils.toSlug(name);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProjectDTO && other.id == id;
  }

  /// Create a copy with updated fields
  ProjectDTO copyWith({
    String? id,
    String? name,
    String? description,
    int? createdAt,
    int? updatedAt,
    Map<String, dynamic>? settings,
    List<String>? tags,
    Map<String, dynamic>? metadata,
  }) {
    return ProjectDTO(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      settings: settings ?? this.settings,
      tags: tags ?? this.tags,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Search relevance score for a query
  double getSearchScore(String query) {
    if (StringUtils.isNullOrEmpty(query)) return 0.0;

    final lowerQuery = query.toLowerCase();
    final lowerName = name.toLowerCase();
    final lowerDesc = description.toLowerCase();

    // Exact name match gets highest score
    if (lowerName == lowerQuery) return 1.0;

    // Name starts with query gets high score
    if (lowerName.startsWith(lowerQuery)) return 0.9;

    // Name contains query gets medium score
    if (lowerName.contains(lowerQuery)) return 0.7;

    // Description contains query gets lower score
    if (lowerDesc.contains(lowerQuery)) return 0.5;

    // Use string similarity for fuzzy matching
    final nameSimilarity =
        StringUtils.calculateSimilarity(lowerName, lowerQuery);
    final descSimilarity =
        StringUtils.calculateSimilarity(lowerDesc, lowerQuery);

    return (nameSimilarity * 0.7) + (descSimilarity * 0.3);
  }

  /// Get validation errors
  Map<String, String> getValidationErrors() {
    final errors = <String, String>{};

    if (id.isEmpty) {
      errors['id'] = 'Project ID cannot be empty';
    }

    final nameValidation = ValidationUtils.validateProjectName(name);
    if (!nameValidation.isValid) {
      errors['name'] = nameValidation.errorMessage ?? 'Invalid name';
    }

    final descValidation =
        ValidationUtils.validateProjectDescription(description);
    if (!descValidation.isValid) {
      errors['description'] =
          descValidation.errorMessage ?? 'Invalid description';
    }

    if (createdAt <= 0) {
      errors['createdAt'] = 'Invalid creation timestamp';
    }

    if (updatedAt <= 0) {
      errors['updatedAt'] = 'Invalid update timestamp';
    }

    return errors;
  }

  /// Validate project data
  bool isValid() {
    return id.isNotEmpty &&
        ValidationUtils.validateProjectName(name).isValid &&
        ValidationUtils.validateProjectDescription(description).isValid &&
        createdAt > 0 &&
        updatedAt > 0;
  }

  /// Convert to domain Project model
  Project toDomain() {
    return Project(
      id: id,
      name: name,
      description: description,
      createdAt: DateTimeUtils.fromMilliseconds(createdAt),
      updatedAt: DateTimeUtils.fromMilliseconds(updatedAt),
    );
  }

  /// Convert to Firebase JSON
  Map<String, dynamic> toFirebaseJson() {
    final json = <String, dynamic>{
      'id': id,
      'name': ModelHelper.sanitizeString(name, maxLength: 50),
      'description': ModelHelper.sanitizeString(description, maxLength: 500),
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };

    if (settings != null && settings!.isNotEmpty) {
      json['settings'] = ModelHelper.cleanMap(settings!);
    }
    if (tags != null && tags!.isNotEmpty) {
      json['tags'] = tags!.where((tag) => tag.trim().isNotEmpty).toList();
    }
    if (metadata != null && metadata!.isNotEmpty) {
      json['metadata'] = ModelHelper.cleanMap(metadata!);
    }

    return ModelHelper.cleanMap(json);
  }

  @override
  String toString() {
    return 'ProjectDTO{id: $id, name: $name}';
  }

  /// Create a copy with updated timestamp
  ProjectDTO touch() {
    return copyWith(updatedAt: DateTimeUtils.currentTimestampMillis());
  }
}
