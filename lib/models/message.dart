class Message {
  final String id;
  final String chatId;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final List<String>? attachments;
  final bool? hasArtifact;
  final Map<String, dynamic>? artifact;

  Message({
    required this.id,
    required this.chatId,
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.attachments,
    this.hasArtifact = false,
    this.artifact,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      chatId: json['chatId'],
      content: json['content'],
      isUser: json['isUser'],
      timestamp: DateTime.parse(json['timestamp']),
      attachments: json['attachments']?.cast<String>(),
      hasArtifact: json['hasArtifact'] ?? false,
      artifact: json['artifact'] != null
          ? Map<String, dynamic>.from(json['artifact'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chatId': chatId,
      'content': content,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
      'attachments': attachments,
      'hasArtifact': hasArtifact,
      'artifact': artifact,
    };
  }
}
