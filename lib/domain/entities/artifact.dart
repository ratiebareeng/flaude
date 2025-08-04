import 'package:equatable/equatable.dart';

/// Artifact domain entity representing generated code, documents, or other content
class Artifact extends Equatable {
  /// Unique identifier for the artifact
  final String id;
  
  /// Title/name of the artifact
  final String title;
  
  /// Type of artifact (code, document, image, etc.)
  final String type;
  
  /// The actual content of the artifact
  final String content;
  
  /// Language/format of the content (for code artifacts)
  final String? language;
  
  /// Additional metadata about the artifact
  final Map<String, dynamic>? metadata;
  
  /// When the artifact was created
  final DateTime createdAt;
  
  /// When the artifact was last updated
  final DateTime? updatedAt;
  
  /// Project ID this artifact belongs to (if any)
  final String? projectId;
  
  /// Message ID that generated this artifact (if any)
  final String? messageId;
  
  /// Size of the artifact in bytes
  final int? sizeBytes;
  
  /// Whether the artifact is executable/runnable
  final bool isExecutable;
  
  /// Version of the artifact (for tracking changes)
  final int version;
  
  /// Tags for categorizing the artifact
  final List<String>? tags;

  const Artifact({
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
    this.sizeBytes,
    this.isExecutable = false,
    this.version = 1,
    this.tags,
  });

  /// Create a copy of this artifact with updated fields
  Artifact copyWith({
    String? id,
    String? title,
    String? type,
    String? content,
    String? language,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? projectId,
    String? messageId,
    int? sizeBytes,
    bool? isExecutable,
    int? version,
    List<String>? tags,
  }) {
    return Artifact(
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
      sizeBytes: sizeBytes ?? this.sizeBytes,
      isExecutable: isExecutable ?? this.isExecutable,
      version: version ?? this.version,
      tags: tags ?? this.tags,
    );
  }

  /// Get the artifact type enum
  ArtifactType get artifactType => ArtifactType.fromString(type);
  
  /// Check if the artifact belongs to a project
  bool get belongsToProject => projectId != null;
  
  /// Check if the artifact was generated from a message
  bool get wasGeneratedFromMessage => messageId != null;
  
  /// Get content length in characters
  int get contentLength => content.length;
  
  /// Get estimated size in bytes (if not provided)
  int get estimatedSizeBytes => sizeBytes ?? content.length;
  
  /// Check if the artifact has tags
  bool get hasTags => tags != null && tags!.isNotEmpty;
  
  /// Check if the artifact has been updated since creation
  bool get hasBeenUpdated => updatedAt != null && updatedAt!.isAfter(createdAt);
  
  /// Get file extension based on language or type
  String get fileExtension {
    if (language != null) {
      return _getExtensionForLanguage(language!);
    }
    return _getExtensionForType(type);
  }
  
  /// Get MIME type for the artifact
  String get mimeType {
    switch (artifactType) {
      case ArtifactType.code:
        return 'text/plain';
      case ArtifactType.html:
        return 'text/html';
      case ArtifactType.markdown:
        return 'text/markdown';
      case ArtifactType.json:
        return 'application/json';
      case ArtifactType.xml:
        return 'application/xml';
      case ArtifactType.svg:
        return 'image/svg+xml';
      case ArtifactType.react:
        return 'text/jsx';
      case ArtifactType.image:
        return 'image/*';
      case ArtifactType.document:
        return 'text/plain';
      case ArtifactType.other:
        return 'application/octet-stream';
    }
  }

  /// Convert artifact to a map format for storage/transmission
  Map<String, dynamic> toArtifactMap() {
    return {
      'id': id,
      'title': title,
      'type': type,
      'content': content,
      'language': language,
      'metadata': metadata,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
      'projectId': projectId,
      'messageId': messageId,
      'sizeBytes': sizeBytes,
      'isExecutable': isExecutable,
      'version': version,
      'tags': tags,
    };
  }

  /// Create artifact from map
  factory Artifact.fromArtifactMap(Map<String, dynamic> map) {
    return Artifact(
      id: map['id'] as String,
      title: map['title'] as String,
      type: map['type'] as String,
      content: map['content'] as String,
      language: map['language'] as String?,
      metadata: map['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      updatedAt: map['updatedAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int)
          : null,
      projectId: map['projectId'] as String?,
      messageId: map['messageId'] as String?,
      sizeBytes: map['sizeBytes'] as int?,
      isExecutable: map['isExecutable'] as bool? ?? false,
      version: map['version'] as int? ?? 1,
      tags: (map['tags'] as List<dynamic>?)?.cast<String>(),
    );
  }

  /// Factory constructor for code artifact
  factory Artifact.code({
    required String id,
    required String title,
    required String content,
    required String language,
    String? projectId,
    String? messageId,
    bool isExecutable = false,
    List<String>? tags,
    Map<String, dynamic>? metadata,
  }) {
    return Artifact(
      id: id,
      title: title,
      type: 'code',
      content: content,
      language: language,
      projectId: projectId,
      messageId: messageId,
      isExecutable: isExecutable,
      tags: tags,
      metadata: metadata,
      createdAt: DateTime.now(),
    );
  }

  /// Factory constructor for HTML artifact
  factory Artifact.html({
    required String id,
    required String title,
    required String content,
    String? projectId,
    String? messageId,
    List<String>? tags,
    Map<String, dynamic>? metadata,
  }) {
    return Artifact(
      id: id,
      title: title,
      type: 'html',
      content: content,
      language: 'html',
      projectId: projectId,
      messageId: messageId,
      isExecutable: true,
      tags: tags,
      metadata: metadata,
      createdAt: DateTime.now(),
    );
  }

  /// Factory constructor for React component artifact
  factory Artifact.react({
    required String id,
    required String title,
    required String content,
    String? projectId,
    String? messageId,
    List<String>? tags,
    Map<String, dynamic>? metadata,
  }) {
    return Artifact(
      id: id,
      title: title,
      type: 'react',
      content: content,
      language: 'jsx',
      projectId: projectId,
      messageId: messageId,
      isExecutable: true,
      tags: tags,
      metadata: metadata,
      createdAt: DateTime.now(),
    );
  }

  /// Factory constructor for document artifact
  factory Artifact.document({
    required String id,
    required String title,
    required String content,
    String? format,
    String? projectId,
    String? messageId,
    List<String>? tags,
    Map<String, dynamic>? metadata,
  }) {
    return Artifact(
      id: id,
      title: title,
      type: 'document',
      content: content,
      language: format,
      projectId: projectId,
      messageId: messageId,
      tags: tags,
      metadata: metadata,
      createdAt: DateTime.now(),
    );
  }

  /// Get file extension for a programming language
  String _getExtensionForLanguage(String language) {
    switch (language.toLowerCase()) {
      case 'dart':
        return '.dart';
      case 'javascript':
      case 'js':
        return '.js';
      case 'typescript':
      case 'ts':
        return '.ts';
      case 'python':
      case 'py':
        return '.py';
      case 'java':
        return '.java';
      case 'html':
        return '.html';
      case 'css':
        return '.css';
      case 'json':
        return '.json';
      case 'xml':
        return '.xml';
      case 'markdown':
      case 'md':
        return '.md';
      case 'jsx':
        return '.jsx';
      case 'tsx':
        return '.tsx';
      case 'svg':
        return '.svg';
      default:
        return '.txt';
    }
  }

  /// Get file extension for artifact type
  String _getExtensionForType(String type) {
    switch (type.toLowerCase()) {
      case 'code':
        return '.txt';
      case 'html':
        return '.html';
      case 'markdown':
        return '.md';
      case 'json':
        return '.json';
      case 'xml':
        return '.xml';
      case 'svg':
        return '.svg';
      case 'react':
        return '.jsx';
      case 'document':
        return '.txt';
      default:
        return '.txt';
    }
  }

  @override
  List<Object?> get props => [
        id,
        title,
        type,
        content,
        language,
        metadata,
        createdAt,
        updatedAt,
        projectId,
        messageId,
        sizeBytes,
        isExecutable,
        version,
        tags,
      ];

  @override
  String toString() {
    return 'Artifact(id: $id, title: $title, type: $type, '
           'language: $language, contentLength: $contentLength, '
           'version: $version, createdAt: $createdAt)';
  }
}

/// Enumeration of artifact types
enum ArtifactType {
  code,
  html,
  markdown,
  json,
  xml,
  svg,
  react,
  image,
  document,
  other;

  /// Create ArtifactType from string
  static ArtifactType fromString(String type) {
    switch (type.toLowerCase()) {
      case 'code':
        return ArtifactType.code;
      case 'html':
        return ArtifactType.html;
      case 'markdown':
      case 'md':
        return ArtifactType.markdown;
      case 'json':
        return ArtifactType.json;
      case 'xml':
        return ArtifactType.xml;
      case 'svg':
        return ArtifactType.svg;
      case 'react':
      case 'jsx':
        return ArtifactType.react;
      case 'image':
        return ArtifactType.image;
      case 'document':
      case 'text':
        return ArtifactType.document;
      default:
        return ArtifactType.other;
    }
  }

  /// Get display name for the artifact type
  String get displayName {
    switch (this) {
      case ArtifactType.code:
        return 'Code';
      case ArtifactType.html:
        return 'HTML';
      case ArtifactType.markdown:
        return 'Markdown';
      case ArtifactType.json:
        return 'JSON';
      case ArtifactType.xml:
        return 'XML';
      case ArtifactType.svg:
        return 'SVG';
      case ArtifactType.react:
        return 'React Component';
      case ArtifactType.image:
        return 'Image';
      case ArtifactType.document:
        return 'Document';
      case ArtifactType.other:
        return 'Other';
    }
  }

  /// Get icon name for the artifact type
  String get iconName {
    switch (this) {
      case ArtifactType.code:
        return 'code';
      case ArtifactType.html:
        return 'html';
      case ArtifactType.markdown:
        return 'markdown';
      case ArtifactType.json:
        return 'json';
      case ArtifactType.xml:
        return 'xml';
      case ArtifactType.svg:
        return 'image';
      case ArtifactType.react:
        return 'react';
      case ArtifactType.image:
        return 'image';
      case ArtifactType.document:
        return 'document';
      case ArtifactType.other:
        return 'file';
    }
  }
}