import 'package:claude_chat_clone/core/utils/utils.dart';
import 'package:claude_chat_clone/domain/models/message.dart';

import 'model_helper.dart';

/// Data Transfer Object for Message - handles Firebase RTDB and API serialization
class MessageDTO {
  final String id;
  final String chatId;
  final String content;
  final bool isUser;
  final int timestamp;
  final List<String>? attachments;
  final bool? hasArtifact;
  final Map<String, dynamic>? artifact;
  final Map<String, dynamic>? metadata;

  const MessageDTO({
    required this.id,
    required this.chatId,
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.attachments,
    this.hasArtifact,
    this.artifact,
    this.metadata,
  });

  /// Create from Claude API response
  factory MessageDTO.fromClaudeApiResponse({
    required String id,
    required String chatId,
    required Map<String, dynamic> response,
  }) {
    final content = response['content'] is List
        ? (response['content'] as List).first['text'] as String
        : ModelHelper.parseString(response['content']);

    return MessageDTO(
      id: id,
      chatId: chatId,
      content: ModelHelper.sanitizeString(content, maxLength: 10000),
      isUser: false,
      timestamp: DateTimeUtils.currentTimestampMillis(),
      metadata: {
        'usage': response['usage'],
        'model': response['model'],
        'stop_reason': response['stop_reason'],
        'api_version': response['anthropic-version'],
      },
    );
  }

  /// Create MessageDTO from domain Message model
  factory MessageDTO.fromDomain(Message message) {
    return MessageDTO(
      id: message.id,
      chatId: message.chatId,
      content: ModelHelper.sanitizeString(message.content, maxLength: 10000),
      isUser: message.isUser,
      timestamp: message.timestamp.millisecondsSinceEpoch,
      attachments: message.attachments,
      hasArtifact: message.hasArtifact,
      artifact: message.artifact,
    );
  }

  /// Create MessageDTO from Firebase JSON
  factory MessageDTO.fromFirebaseJson(Map<String, dynamic> json) {
    return ModelHelper.safeParse(
      () => MessageDTO(
        id: ModelHelper.parseString(json['id']),
        chatId: ModelHelper.parseString(json['chatId']),
        content: ModelHelper.parseString(json['content']),
        isUser: ModelHelper.parseBool(json['isUser'], fallback: false),
        timestamp: ModelHelper.parseTimestamp(json['timestamp']),
        attachments: ModelHelper.parseNullableStringList(json['attachments']),
        hasArtifact: ModelHelper.parseBool(json['hasArtifact']),
        artifact: ModelHelper.parseNullableMap(json['artifact']),
        metadata: ModelHelper.parseNullableMap(json['metadata']),
      ),
      MessageDTO(
        id: '',
        chatId: '',
        content: '',
        isUser: false,
        timestamp: DateTimeUtils.currentTimestampMillis(),
      ),
      context: 'MessageDTO.fromFirebaseJson',
    );
  }

  /// Get formatted timestamp for display
  String get formattedTimestamp {
    return DateTimeUtils.formatMessageTimestamp(
        DateTimeUtils.fromMilliseconds(timestamp));
  }

  @override
  int get hashCode => id.hashCode;

  /// Get relative time (e.g., "2 hours ago")
  String get relativeTime {
    return DateTimeUtils.formatRelativeTime(
        DateTimeUtils.fromMilliseconds(timestamp));
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MessageDTO && other.id == id;
  }

  /// Check if message contains sensitive information
  bool containsSensitiveInfo() {
    final lowerContent = content.toLowerCase();

    // Check for potential API keys, passwords, etc.
    final sensitivePatterns = [
      RegExp(r'sk-ant-api03-[A-Za-z0-9_-]{95}'), // Claude API key
      RegExp(r'password\s*[:=]\s*\S+', caseSensitive: false),
      RegExp(r'api[_-]?key\s*[:=]\s*\S+', caseSensitive: false),
      RegExp(r'token\s*[:=]\s*\S+', caseSensitive: false),
    ];

    return sensitivePatterns.any((pattern) => pattern.hasMatch(content));
  }

  /// Get content preview (truncated for display)
  String getContentPreview({int maxLength = 100}) {
    return StringUtils.truncateAtWord(content, maxLength);
  }

  /// Get validation errors
  Map<String, String> getValidationErrors() {
    final errors = <String, String>{};

    if (id.isEmpty) {
      errors['id'] = 'Message ID cannot be empty';
    }

    if (chatId.isEmpty) {
      errors['chatId'] = 'Chat ID cannot be empty';
    }

    final contentValidation = ValidationUtils.validateMessage(content);
    if (!contentValidation.isValid) {
      errors['content'] = contentValidation.errorMessage ?? 'Invalid content';
    }

    if (timestamp <= 0) {
      errors['timestamp'] = 'Invalid timestamp';
    }

    return errors;
  }

  /// Validate message data
  bool isValid() {
    return id.isNotEmpty &&
        chatId.isNotEmpty &&
        ValidationUtils.validateMessage(content).isValid &&
        timestamp > 0;
  }

  /// Convert to Claude API format
  Map<String, dynamic> toClaudeApiJson() {
    return {
      'role': isUser ? 'user' : 'assistant',
      'content': content,
    };
  }

  /// Convert to domain Message model
  Message toDomain() {
    return Message(
      id: id,
      chatId: chatId,
      content: content,
      isUser: isUser,
      timestamp: DateTimeUtils.fromMilliseconds(timestamp),
      attachments: attachments,
      hasArtifact: hasArtifact,
      artifact: artifact,
    );
  }

  /// Convert to Firebase JSON
  Map<String, dynamic> toFirebaseJson() {
    final json = <String, dynamic>{
      'id': id,
      'chatId': chatId,
      'content': ModelHelper.sanitizeString(content, maxLength: 10000),
      'isUser': isUser,
      'timestamp': timestamp,
    };

    if (attachments != null && attachments!.isNotEmpty) {
      json['attachments'] = attachments;
    }
    if (hasArtifact != null) json['hasArtifact'] = hasArtifact;
    if (artifact != null && artifact!.isNotEmpty) {
      json['artifact'] = ModelHelper.cleanMap(artifact!);
    }
    if (metadata != null && metadata!.isNotEmpty) {
      json['metadata'] = ModelHelper.cleanMap(metadata!);
    }

    return ModelHelper.cleanMap(json);
  }

  @override
  String toString() {
    return 'MessageDTO{id: $id, chatId: $chatId, isUser: $isUser}';
  }
}
