import 'package:equatable/equatable.dart';

import 'message.dart';

/// Chat domain entity representing a conversation
class Chat extends Equatable {
  /// Unique identifier for the chat
  final String id;

  /// Display title of the chat
  final String title;

  /// Optional description of the chat
  final String? description;

  /// List of messages in the chat
  final List<Message> messages;

  /// When the chat was created
  final DateTime createdAt;

  /// When the chat was last updated
  final DateTime? updatedAt;

  /// Optional project ID this chat belongs to
  final String? projectId;

  /// AI model used for this chat
  final String? model;

  /// Additional metadata for the chat
  final Map<String, dynamic>? metadata;

  const Chat({
    required this.id,
    required this.title,
    this.description,
    required this.messages,
    required this.createdAt,
    this.updatedAt,
    this.projectId,
    this.model,
    this.metadata,
  });

  /// Get AI messages only
  List<Message> get aiMessages => messages.where((msg) => !msg.isUser).toList();

  /// Check if the chat belongs to a project
  bool get belongsToProject => projectId != null;

  /// Check if the chat has any messages
  bool get hasMessages => messages.isNotEmpty;

  /// Get the last message in the chat
  Message? get lastMessage => messages.isNotEmpty ? messages.last : null;

  /// Get the number of messages in the chat
  int get messageCount => messages.length;

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        messages,
        createdAt,
        updatedAt,
        projectId,
        model,
        metadata,
      ];

  /// Get user messages only
  List<Message> get userMessages =>
      messages.where((msg) => msg.isUser).toList();

  /// Create a copy of this chat with updated fields
  Chat copyWith({
    String? id,
    String? title,
    String? description,
    List<Message>? messages,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? projectId,
    String? model,
    Map<String, dynamic>? metadata,
  }) {
    return Chat(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      messages: messages ?? this.messages,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      projectId: projectId ?? this.projectId,
      model: model ?? this.model,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  String toString() {
    return 'Chat(id: $id, title: $title, messageCount: $messageCount, '
        'createdAt: $createdAt, projectId: $projectId)';
  }
}
