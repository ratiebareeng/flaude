import 'package:claude_chat_clone/core/utils/utils.dart';

import 'model_helper.dart';

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
      id: ModelHelper.parseString(artifactMap['id']),
      title: ModelHelper.parseString(artifactMap['title'],
          fallback: 'Untitled Artifact'),
      type: ModelHelper.parseString(artifactMap['type'], fallback: 'text'),
      content: ModelHelper.parseString(artifactMap['content']),
      language: StringUtils.isNullOrEmpty(artifactMap['language'] as String?)
          ? null
          : artifactMap['language'] as String,
      metadata: ModelHelper.parseNullableMap(artifactMap['metadata']),
      createdAt: DateTimeUtils.currentTimestampMillis(),
      projectId: projectId,
      messageId: messageId,
    );
  }

  /// Create ArtifactDTO from Firebase JSON
  factory ArtifactDTO.fromFirebaseJson(Map<String, dynamic> json) {
    return ModelHelper.safeParse(
      () => ArtifactDTO(
        id: ModelHelper.parseString(json['id']),
        title: ModelHelper.parseString(json['title'],
            fallback: 'Untitled Artifact'),
        type: ModelHelper.parseString(json['type'], fallback: 'text'),
        content: ModelHelper.parseString(json['content']),
        language: StringUtils.isNullOrEmpty(json['language'] as String?)
            ? null
            : json['language'] as String,
        metadata: ModelHelper.parseNullableMap(json['metadata']),
        createdAt: ModelHelper.parseTimestamp(json['createdAt']),
        updatedAt: json['updatedAt'] != null
            ? ModelHelper.parseTimestamp(json['updatedAt'])
            : null,
        projectId: StringUtils.isNullOrEmpty(json['projectId'] as String?)
            ? null
            : json['projectId'] as String,
        messageId: StringUtils.isNullOrEmpty(json['messageId'] as String?)
            ? null
            : json['messageId'] as String,
      ),
      ArtifactDTO(
        id: '',
        title: 'Untitled Artifact',
        type: 'text',
        content: '',
        createdAt: DateTimeUtils.currentTimestampMillis(),
      ),
      context: 'ArtifactDTO.fromFirebaseJson',
    );
  }

  /// Get content character count
  int get characterCount {
    return StringUtils.countCharacters(content, includeSpaces: true);
  }

  /// Get file extension based on type and language
  String get fileExtension {
    switch (type.toLowerCase()) {
      case 'code':
        return _getCodeFileExtension(language ?? 'txt');
      case 'html':
        return 'html';
      case 'markdown':
        return 'md';
      case 'json':
        return 'json';
      case 'yaml':
        return 'yaml';
      case 'xml':
        return 'xml';
      case 'css':
        return 'css';
      case 'sql':
        return 'sql';
      default:
        return 'txt';
    }
  }

  /// Get formatted creation date
  String get formattedCreatedAt {
    return DateTimeUtils.formatDisplayDateTime(
        DateTimeUtils.fromMilliseconds(createdAt));
  }

  /// Get formatted update date
  String? get formattedUpdatedAt {
    return updatedAt != null
        ? DateTimeUtils.formatDisplayDateTime(
            DateTimeUtils.fromMilliseconds(updatedAt!))
        : null;
  }

  @override
  int get hashCode => id.hashCode;

  /// Check if artifact is code-based
  bool get isCodeArtifact {
    return type.toLowerCase() == 'code' ||
        ['html', 'css', 'javascript', 'json', 'xml', 'yaml', 'sql']
            .contains(type.toLowerCase());
  }

  /// Get content line count
  int get lineCount {
    return content.split('\n').length;
  }

  /// Get relative creation time
  String get relativeCreatedAt {
    return DateTimeUtils.formatRelativeTime(
        DateTimeUtils.fromMilliseconds(createdAt));
  }

  /// Get suggested filename
  String get suggestedFilename {
    final cleanTitle = StringUtils.sanitizeFileName(title);
    return '$cleanTitle.$fileExtension';
  }

  /// Get content word count
  int get wordCount {
    return StringUtils.countWords(content);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ArtifactDTO && other.id == id;
  }

  /// Check if artifact content contains sensitive information
  bool containsSensitiveInfo() {
    final lowerContent = content.toLowerCase();

    // Check for potential secrets
    final sensitivePatterns = [
      RegExp(r'sk-ant-api03-[A-Za-z0-9_-]{95}'), // Claude API key
      RegExp(r'password\s*[:=]\s*\S+', caseSensitive: false),
      RegExp(r'api[_-]?key\s*[:=]\s*\S+', caseSensitive: false),
      RegExp(r'secret\s*[:=]\s*\S+', caseSensitive: false),
      RegExp(r'token\s*[:=]\s*\S+', caseSensitive: false),
    ];

    return sensitivePatterns.any((pattern) => pattern.hasMatch(content));
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

  /// Get content preview for display
  String getContentPreview({int maxLength = 200}) {
    return StringUtils.truncateAtWord(content, maxLength);
  }

  /// Search relevance score for a query
  double getSearchScore(String query) {
    if (StringUtils.isNullOrEmpty(query)) return 0.0;

    final lowerQuery = query.toLowerCase();
    final lowerTitle = title.toLowerCase();
    final lowerContent = content.toLowerCase();

    // Exact title match gets highest score
    if (lowerTitle == lowerQuery) return 1.0;

    // Title starts with query gets high score
    if (lowerTitle.startsWith(lowerQuery)) return 0.9;

    // Title contains query gets medium score
    if (lowerTitle.contains(lowerQuery)) return 0.7;

    // Content contains query gets lower score
    if (lowerContent.contains(lowerQuery)) return 0.5;

    // Use string similarity for fuzzy matching
    final titleSimilarity =
        StringUtils.calculateSimilarity(lowerTitle, lowerQuery);
    final contentSimilarity = StringUtils.calculateSimilarity(
        lowerContent.substring(
            0, lowerContent.length > 200 ? 200 : lowerContent.length),
        lowerQuery);

    return (titleSimilarity * 0.8) + (contentSimilarity * 0.2);
  }

  /// Get validation errors
  Map<String, String> getValidationErrors() {
    final errors = <String, String>{};

    if (id.isEmpty) {
      errors['id'] = 'Artifact ID cannot be empty';
    }

    if (title.trim().isEmpty) {
      errors['title'] = 'Artifact title cannot be empty';
    }

    if (content.trim().isEmpty) {
      errors['content'] = 'Artifact content cannot be empty';
    }

    if (!_isValidArtifactType(type)) {
      errors['type'] = 'Invalid artifact type';
    }

    if (createdAt <= 0) {
      errors['createdAt'] = 'Invalid creation timestamp';
    }

    return errors;
  }

  /// Validate artifact data
  bool isValid() {
    return id.isNotEmpty &&
        title.trim().isNotEmpty &&
        content.trim().isNotEmpty &&
        _isValidArtifactType(type) &&
        createdAt > 0;
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
      'title': ModelHelper.sanitizeString(title, maxLength: 200),
      'type': type,
      'content': content, // Don't sanitize content as it might be code
      'createdAt': createdAt,
    };

    if (StringUtils.isNotNullOrEmpty(language)) json['language'] = language;
    if (metadata != null && metadata!.isNotEmpty) {
      json['metadata'] = ModelHelper.cleanMap(metadata!);
    }
    if (updatedAt != null) json['updatedAt'] = updatedAt;
    if (StringUtils.isNotNullOrEmpty(projectId)) json['projectId'] = projectId;
    if (StringUtils.isNotNullOrEmpty(messageId)) json['messageId'] = messageId;

    return ModelHelper.cleanMap(json);
  }

  @override
  String toString() {
    return 'ArtifactDTO{id: $id, title: $title, type: $type}';
  }

  /// Create a copy with updated timestamp
  ArtifactDTO touch() {
    return copyWith(updatedAt: DateTimeUtils.currentTimestampMillis());
  }

  /// Helper method to get file extension for code artifacts
  static String _getCodeFileExtension(String language) {
    switch (language.toLowerCase()) {
      case 'javascript':
      case 'js':
        return 'js';
      case 'typescript':
      case 'ts':
        return 'ts';
      case 'python':
      case 'py':
        return 'py';
      case 'dart':
        return 'dart';
      case 'java':
        return 'java';
      case 'kotlin':
        return 'kt';
      case 'swift':
        return 'swift';
      case 'go':
        return 'go';
      case 'rust':
        return 'rs';
      case 'c':
        return 'c';
      case 'cpp':
      case 'c++':
        return 'cpp';
      case 'csharp':
      case 'c#':
        return 'cs';
      case 'php':
        return 'php';
      case 'ruby':
        return 'rb';
      case 'shell':
      case 'bash':
        return 'sh';
      default:
        return 'txt';
    }
  }

  /// Helper method to validate artifact types
  static bool _isValidArtifactType(String type) {
    const validTypes = [
      'text',
      'code',
      'html',
      'markdown',
      'json',
      'yaml',
      'xml',
      'css',
      'javascript',
      'python',
      'dart',
      'java',
      'sql'
    ];
    return validTypes.contains(type.toLowerCase());
  }
}
