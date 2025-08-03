// lib/data/models/project_dto.dart
import '../../domain/models/models.dart';

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

  /// Create ProjectDTO from Firebase JSON
  factory ProjectDTO.fromFirebaseJson(Map<String, dynamic> json) {
    return ProjectDTO(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      createdAt: json['createdAt'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      updatedAt: json['updatedAt'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      settings: json['settings'] as Map<String, dynamic>?,
      tags: (json['tags'] as List?)?.cast<String>(),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Create ProjectDTO from domain Project model
  factory ProjectDTO.fromDomain(Project project) {
    return ProjectDTO(
      id: project.id,
      name: project.name,
      description: project.description,
      createdAt: project.createdAt.millisecondsSinceEpoch,
      updatedAt: project.updatedAt.millisecondsSinceEpoch,
    );
  }

  /// Convert to domain Project model
  Project toDomain() {
    return Project(
      id: id,
      name: name,
      description: description,
      createdAt: DateTime.fromMillisecondsSinceEpoch(createdAt),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(updatedAt),
    );
  }

  /// Convert to Firebase JSON
  Map<String, dynamic> toFirebaseJson() {
    final json = <String, dynamic>{
      'id': id,
      'name': name,
      'description': description,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };

    if (settings != null) json['settings'] = settings;
    if (tags != null) json['tags'] = tags;
    if (metadata != null) json['metadata'] = metadata;

    return json;
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

  @override
  String toString() {
    return 'ProjectDTO{id: $id, name: $name}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProjectDTO && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}