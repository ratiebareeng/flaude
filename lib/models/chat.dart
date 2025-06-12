import 'message.dart';

class Chat {
  final String id;
  final String title;
  final List<Message> messages;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? projectId;

  Chat({
    required this.id,
    required this.title,
    required this.messages,
    required this.createdAt,
    this.updatedAt,
    this.projectId,
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      id: json['id'],
      title: json['title'],
      messages: (json['messages'] as List)
          .map((msg) => Message.fromJson(msg))
          .toList(),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json.containsKey('updatedAt')
          ? DateTime.parse(json['updatedAt'])
          : null,
      projectId: json['projectId'],
    );
  }

  // Add message to the chat
  Chat addMessage(Message message) {
    return copyWith(messages: [...messages, message]);
  }

  // Copywith method to create a new Chat instance with updated fields
  Chat copyWith({
    String? id,
    String? title,
    List<Message>? messages,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? projectId,
  }) {
    return Chat(
      id: id ?? this.id,
      title: title ?? this.title,
      messages: messages ?? this.messages,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      projectId: projectId ?? this.projectId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'messages': messages.map((msg) => msg.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'projectId': projectId,
    };
  }
}
