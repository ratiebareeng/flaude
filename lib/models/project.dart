import 'chat.dart';

class Project {
  final String id;
  final String title;
  final String description;
  final DateTime updatedAt;
  final List<Chat> chats;

  Project({
    required this.id,
    required this.title,
    required this.description,
    required this.updatedAt,
    required this.chats,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      updatedAt: DateTime.parse(json['updatedAt']),
      chats:
          (json['chats'] as List).map((chat) => Chat.fromJson(chat)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'updatedAt': updatedAt.toIso8601String(),
      'chats': chats.map((chat) => chat.toJson()).toList(),
    };
  }
}
