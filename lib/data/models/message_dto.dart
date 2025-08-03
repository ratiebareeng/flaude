// lib/data/models/message_dto.dart
import '../../domain/models/models.dart';

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

  /// Create MessageDTO from Firebase JSON
  factory MessageDTO.fromFirebaseJson(Map<String, dynamic> json) {
    return MessageDTO(
      id: json['id'] as String? ?? '',
      chatId: json['chatId'] as String? ?? '',
      content: json['content'] as String? ?? '',
      isUser: json['isUser'] as bool? ?? false,
      timestamp: _parseTimestamp(json['timestamp']),
      attachments: (json['attachments'] as List?)?.cast<String>(),
      hasArtifact: json['hasArtifact'] as bool?,
      artifact: json['artifact'] as Map<String, dynamic>?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Create MessageDTO from domain Message model
  factory MessageDTO.fromDomain(Message message) {
    return MessageDTO(
      id: message.id,
      chatId: message.chatId,
      content: message.content,
      isUser: message.isUser,
      timestamp: message.timestamp.millisecondsSinceEpoch,
      attachments: message.attachments,
      hasArtifact: message.hasArtifact,
      artifact: message.artifact,
    );
  }

  /// Convert to domain Message model
  Message toDomain() {
    return Message(
      id: id,
      chatId: chatId,
      content: content,
      isUser: isUser,
      timestamp: DateTime.fromMillisecondsSinceEpoch(timestamp),
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
      'content': content,
      'isUser': isUser,
      'timestamp': timestamp,
    };

    if (attachments != null) json['attachments'] = attachments;
    if (hasArtifact != null) json['hasArtifact'] = hasArtifact;
    if (artifact != null) json['artifact'] = artifact;
    if (metadata != null) json['metadata'] = metadata;

    return json;
  }

  /// Convert to Claude API format
  Map<String, dynamic> toClaudeApiJson() {
    return {
      'role': isUser ? 'user' : 'assistant',
      'content': content,
    };
  }

  /// Create from Claude API response
  factory MessageDTO.fromClaudeApiResponse({
    required String id,
    required String chatId,
    required Map<String, dynamic> response,
  }) {
    final content = response['content'] is List 
        ? (response['content'] as List).first['text'] as String
        : response['content'] as String? ?? '';
        
    return MessageDTO(
      id: id,
      chatId: chatId,
      content: content,
      isUser: false,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      metadata: {
        'usage': response['usage'],
        'model': response['model'],
        'stop_reason': response['stop_reason'],
      },
    );
  }

  static int _parseTimestamp(dynamic value) {
    if (value == null) return DateTime.now().millisecondsSinceEpoch;
    if (value is int) return value;
    if (value is String) {
      final parsed = DateTime.tryParse(value);
      return parsed?.millisecondsSinceEpoch ?? DateTime.now().millisecondsSinceEpoch;
    }
    return DateTime.now().millisecondsSinceEpoch;
  }

  @override
  String toString() {
    return 'MessageDTO{id: $id, chatId: $chatId, isUser: $isUser}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MessageDTO && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}