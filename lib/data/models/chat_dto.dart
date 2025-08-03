import 'package:claude_chat_clone/core/utils/utils.dart';
import 'package:claude_chat_clone/domain/models/chat.dart';
import 'package:claude_chat_clone/domain/models/message.dart';

import 'model_helper.dart';

/// Data Transfer Object for Chat - handles Firebase RTDB serialization
class ChatDTO {
  final String id;
  final String? userId;
  final String title;
  final String? description;
  final Map<String, dynamic>? messagesMap;
  final int createdAt;
  final int? updatedAt;
  final String? projectId;
  final Map<String, dynamic>? metadata;

  const ChatDTO({
    required this.id,
    this.userId,
    required this.title,
    this.description,
    this.messagesMap,
    required this.createdAt,
    this.updatedAt,
    this.projectId,
    this.metadata,
  });

  /// Create ChatDTO from domain Chat model
  factory ChatDTO.fromDomain(Chat chat) {
    return ChatDTO(
      id: chat.id,
      userId: chat.userId,
      title: StringUtils.truncate(
          ModelHelper.sanitizeString(chat.title, maxLength: 100), 100),
      description: StringUtils.isNullOrEmpty(chat.description)
          ? null
          : StringUtils.truncate(
              ModelHelper.sanitizeString(chat.description, maxLength: 500),
              500),
      messagesMap: null, // Messages handled separately in Firebase
      createdAt: chat.createdAt.millisecondsSinceEpoch,
      updatedAt: chat.updatedAt?.millisecondsSinceEpoch,
      projectId: chat.projectId,
      metadata: null,
    );
  }

  /// Create ChatDTO from Firebase JSON using both ModelHelper and existing utilities
  factory ChatDTO.fromFirebaseJson(Map<String, dynamic> json) {
    return ModelHelper.safeParse(
      () => ChatDTO(
        id: ModelHelper.parseString(json['id']),
        userId: StringUtils.isNullOrEmpty(json['userId'] as String?)
            ? null
            : json['userId'] as String,
        title: ModelHelper.parseString(json['title'], fallback: 'Untitled'),
        description: StringUtils.isNullOrEmpty(json['description'] as String?)
            ? null
            : StringUtils.sanitizeFileName(
                json['description'] as String? ?? ''),
        messagesMap: ModelHelper.parseNullableMap(json['messages']),
        createdAt: ModelHelper.parseTimestamp(json['createdAt']),
        updatedAt: json['updatedAt'] != null
            ? ModelHelper.parseTimestamp(json['updatedAt'])
            : null,
        projectId: StringUtils.isNullOrEmpty(json['projectId'] as String?)
            ? null
            : json['projectId'] as String,
        metadata: ModelHelper.parseNullableMap(json['metadata']),
      ),
      ChatDTO(
        id: '',
        title: 'Untitled',
        createdAt: DateTimeUtils.currentTimestampMillis(),
      ),
      context: 'ChatDTO.fromFirebaseJson',
    );
  }

  @override
  int get hashCode => id.hashCode;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChatDTO && other.id == id;
  }

  /// Create a copy with updated fields
  ChatDTO copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    Map<String, dynamic>? messagesMap,
    int? createdAt,
    int? updatedAt,
    String? projectId,
    Map<String, dynamic>? metadata,
  }) {
    return ChatDTO(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      messagesMap: messagesMap ?? this.messagesMap,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      projectId: projectId ?? this.projectId,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Get validation errors
  Map<String, String> getValidationErrors() {
    final errors = <String, String>{};

    if (id.isEmpty) {
      errors['id'] = 'Chat ID cannot be empty';
    }

    final titleValidation = ValidationUtils.validateChatTitle(title);
    if (!titleValidation.isValid) {
      errors['title'] = titleValidation.errorMessage ?? 'Invalid title';
    }

    if (createdAt <= 0) {
      errors['createdAt'] = 'Invalid creation timestamp';
    }

    return errors;
  }

  /// Validate chat data using existing ValidationUtils
  bool isValid() {
    return id.isNotEmpty &&
        ValidationUtils.validateChatTitle(title).isValid &&
        createdAt > 0;
  }

  /// Convert to domain Chat model
  Chat toDomain({List<Message>? messages}) {
    return Chat(
      id: id,
      userId: userId,
      title: title,
      description: description,
      messages: messages ?? [],
      createdAt: DateTimeUtils.fromMilliseconds(createdAt),
      updatedAt:
          updatedAt != null ? DateTimeUtils.fromMilliseconds(updatedAt!) : null,
      projectId: projectId,
    );
  }

  /// Convert to Firebase JSON (cleaned and validated)
  Map<String, dynamic> toFirebaseJson() {
    final json = <String, dynamic>{
      'id': id,
      'title': ModelHelper.sanitizeString(title, maxLength: 100),
      'createdAt': createdAt,
    };

    if (StringUtils.isNotNullOrEmpty(userId)) json['userId'] = userId;
    if (StringUtils.isNotNullOrEmpty(description)) {
      json['description'] =
          ModelHelper.sanitizeString(description, maxLength: 500);
    }
    if (updatedAt != null) json['updatedAt'] = updatedAt;
    if (StringUtils.isNotNullOrEmpty(projectId)) json['projectId'] = projectId;
    if (metadata != null && metadata!.isNotEmpty) {
      json['metadata'] = ModelHelper.cleanMap(metadata!);
    }

    // Return cleaned map without null/empty values
    return ModelHelper.cleanMap(json);
  }

  @override
  String toString() {
    return 'ChatDTO{id: $id, title: $title, projectId: $projectId}';
  }
}
