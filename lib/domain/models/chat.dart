import 'message.dart';

class Chat {
  final String id;
  final String? userId;
  final String title;
  final String? description;
  final List<Message> messages;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? projectId;

  Chat({
    required this.id,
    this.userId,
    required this.title,
    this.description,
    required this.messages,
    required this.createdAt,
    this.updatedAt,
    this.projectId,
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      id: json['id'],
      userId: json.containsKey('userId') ? json['userId'] as String? : null,
      title: json.containsKey('title') ? json['title'] as String : 'Untitled',
      description: json.containsKey('description')
          ? json['description'] as String?
          : null,
      messages: json.containsKey('messages')
          ? (json['messages'] as List)
              .map((msg) => Message.fromJson(msg))
              .toList()
          : [],
      createdAt: json.containsKey('createdAt')
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json.containsKey('updatedAt')
          ? DateTime.parse(json['updatedAt'])
          : null,
      projectId: json.containsKey('projectId') ? json['projectId'] : null,
    );
  }

  // get last message in the chat
  Message? get lastMessage {
    if (messages.isEmpty) return null;
    return messages.last;
  }

  // Add message to the chat
  Chat addMessage(Message message) {
    return copyWith(
      updatedAt: DateTime.now(),
      messages: [...messages, message],
    );
  }

  // Clear messages in the chat
  Chat clearMessages() {
    return copyWith(
      updatedAt: DateTime.now(),
      messages: [],
    );
  }

  // Copywith method to create a new Chat instance with updated fields
  Chat copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    List<Message>? messages,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? projectId,
  }) {
    return Chat(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      messages: messages ?? this.messages,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      projectId: projectId ?? this.projectId,
    );
  }

  Map<String, dynamic> toJson({bool? withMessages = false}) {
    if (withMessages == false) {
      return {
        'id': id,
        'userId': userId,
        'title': title,
        'description': description,
        'createdAt': createdAt.toIso8601String(),
        'projectId': projectId,
        'updatedAt': updatedAt?.toIso8601String(),
      };
    }
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'description': description,
      'messages': messages.map((msg) => msg.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'projectId': projectId,
    };
  }
}
