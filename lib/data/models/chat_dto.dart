import 'package:claude_chat_clone/domain/models/chat.dart';
import 'package:claude_chat_clone/domain/models/message.dart';

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
      title: chat.title,
      description: chat.description,
      messagesMap: null, // Messages handled separately in Firebase
      createdAt: chat.createdAt.millisecondsSinceEpoch,
      updatedAt: chat.updatedAt?.millisecondsSinceEpoch,
      projectId: chat.projectId,
      metadata: null,
    );
  }

  /// Create ChatDTO from Firebase JSON
  factory ChatDTO.fromFirebaseJson(Map<String, dynamic> json) {
    return ChatDTO(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String?,
      title: json['title'] as String? ?? 'Untitled',
      description: json['description'] as String?,
      messagesMap: json['messages'] as Map<String, dynamic>?,
      createdAt: _parseTimestamp(json['createdAt']),
      updatedAt: _parseTimestamp(json['updatedAt']),
      projectId: json['projectId'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
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

  /// Convert to domain Chat model
  Chat toDomain({List<Message>? messages}) {
    return Chat(
      id: id,
      userId: userId,
      title: title,
      description: description,
      messages: messages ?? [],
      createdAt: DateTime.fromMillisecondsSinceEpoch(createdAt),
      updatedAt: updatedAt != null
          ? DateTime.fromMillisecondsSinceEpoch(updatedAt!)
          : null,
      projectId: projectId,
    );
  }

  /// Convert to Firebase JSON (without messages)
  Map<String, dynamic> toFirebaseJson() {
    final json = <String, dynamic>{
      'id': id,
      'title': title,
      'createdAt': createdAt,
    };

    if (userId != null) json['userId'] = userId;
    if (description != null) json['description'] = description;
    if (updatedAt != null) json['updatedAt'] = updatedAt;
    if (projectId != null) json['projectId'] = projectId;
    if (metadata != null) json['metadata'] = metadata;

    return json;
  }

  @override
  String toString() {
    return 'ChatDTO{id: $id, title: $title, projectId: $projectId}';
  }

  static int _parseTimestamp(dynamic value) {
    if (value == null) return DateTime.now().millisecondsSinceEpoch;
    if (value is int) return value;
    if (value is String) {
      final parsed = DateTime.tryParse(value);
      return parsed?.millisecondsSinceEpoch ??
          DateTime.now().millisecondsSinceEpoch;
    }
    return DateTime.now().millisecondsSinceEpoch;
  }
}
