/// Data Transfer Object for Artifacts - handles various artifact types
class ArtifactDTO {
  final String id;
  final String title;
  final String type; // 'text', 'code', 'html', 'markdown', etc.
  final String content;
  final String? language; // for code artifacts
  final Map<String, dynamic>? metadata;
  final int createdAt;
  final int? updatedAt;
  final String? projectId;
  final String? messageId;

  const ArtifactDTO({
    required this.id,
    required this.title,
    required this.type,
    required this.content,
    this.language,
    this.metadata,
    required this.createdAt,
    this.updatedAt,
    this.projectId,
    this.messageId,
  });

  /// Create from message artifact map
  factory ArtifactDTO.fromArtifactMap({
    required Map<String, dynamic> artifactMap,
    String? projectId,
    String? messageId,
  }) {
    return ArtifactDTO(
      id: artifactMap['id'] as String,
      title: artifactMap['title'] as String,
      type: artifactMap['type'] as String,
      content: artifactMap['content'] as String,
      language: artifactMap['language'] as String?,
      metadata: artifactMap['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      projectId: projectId,
      messageId: messageId,
    );
  }

  /// Create ArtifactDTO from Firebase JSON
  factory ArtifactDTO.fromFirebaseJson(Map<String, dynamic> json) {
    return ArtifactDTO(
      id: json['id'] as String,
      title: json['title'] as String,
      type: json['type'] as String,
      content: json['content'] as String,
      language: json['language'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: json['createdAt'] as int,
      updatedAt: json['updatedAt'] as int?,
      projectId: json['projectId'] as String?,
      messageId: json['messageId'] as String?,
    );
  }

  @override
  int get hashCode => id.hashCode;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ArtifactDTO && other.id == id;
  }

  /// Create a copy with updated fields
  ArtifactDTO copyWith({
    String? id,
    String? title,
    String? type,
    String? content,
    String? language,
    Map<String, dynamic>? metadata,
    int? createdAt,
    int? updatedAt,
    String? projectId,
    String? messageId,
  }) {
    return ArtifactDTO(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      content: content ?? this.content,
      language: language ?? this.language,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      projectId: projectId ?? this.projectId,
      messageId: messageId ?? this.messageId,
    );
  }

  /// Convert to Map for message artifact
  Map<String, dynamic> toArtifactMap() {
    return {
      'id': id,
      'title': title,
      'type': type,
      'content': content,
      'language': language,
      'metadata': metadata,
    };
  }

  /// Convert to Firebase JSON
  Map<String, dynamic> toFirebaseJson() {
    final json = <String, dynamic>{
      'id': id,
      'title': title,
      'type': type,
      'content': content,
      'createdAt': createdAt,
    };

    if (language != null) json['language'] = language;
    if (metadata != null) json['metadata'] = metadata;
    if (updatedAt != null) json['updatedAt'] = updatedAt;
    if (projectId != null) json['projectId'] = projectId;
    if (messageId != null) json['messageId'] = messageId;

    return json;
  }

  @override
  String toString() {
    return 'ArtifactDTO{id: $id, title: $title, type: $type}';
  }
}
