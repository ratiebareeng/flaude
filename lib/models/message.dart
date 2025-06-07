class Message {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final List<String>? attachments;

  Message({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.attachments,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      content: json['content'],
      isUser: json['isUser'],
      timestamp: DateTime.parse(json['timestamp']),
      attachments: json['attachments']?.cast<String>(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
      'attachments': attachments,
    };
  }
}
