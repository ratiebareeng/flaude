import 'package:equatable/equatable.dart';
import 'artifact.dart';

/// Message domain entity representing a single message in a chat
class Message extends Equatable {
  /// Unique identifier for the message
  final String id;
  
  /// ID of the chat this message belongs to
  final String chatId;
  
  /// Content/text of the message
  final String content;
  
  /// Whether this message is from the user (true) or AI (false)
  final bool isUser;
  
  /// When the message was created/sent
  final DateTime timestamp;
  
  /// Optional role for the message (user, assistant, system)
  final String? role;
  
  /// Optional model that generated this message (for AI messages)
  final String? model;
  
  /// Token usage information for this message
  final MessageTokenUsage? tokenUsage;
  
  /// List of artifacts associated with this message
  final List<Artifact>? artifacts;
  
  /// Additional metadata for the message
  final Map<String, dynamic>? metadata;
  
  /// Whether this message is currently being streamed/generated
  final bool isStreaming;
  
  /// Error information if message failed to send/generate
  final String? error;

  const Message({
    required this.id,
    required this.chatId,
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.role,
    this.model,
    this.tokenUsage,
    this.artifacts,
    this.metadata,
    this.isStreaming = false,
    this.error,
  });

  /// Create a copy of this message with updated fields
  Message copyWith({
    String? id,
    String? chatId,
    String? content,
    bool? isUser,
    DateTime? timestamp,
    String? role,
    String? model,
    MessageTokenUsage? tokenUsage,
    List<Artifact>? artifacts,
    Map<String, dynamic>? metadata,
    bool? isStreaming,
    String? error,
  }) {
    return Message(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      content: content ?? this.content,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
      role: role ?? this.role,
      model: model ?? this.model,
      tokenUsage: tokenUsage ?? this.tokenUsage,
      artifacts: artifacts ?? this.artifacts,
      metadata: metadata ?? this.metadata,
      isStreaming: isStreaming ?? this.isStreaming,
      error: error ?? this.error,
    );
  }

  /// Check if this message has artifacts
  bool get hasArtifacts => artifacts != null && artifacts!.isNotEmpty;
  
  /// Check if this message has an error
  bool get hasError => error != null;
  
  /// Check if this message is completed (not streaming and no error)
  bool get isCompleted => !isStreaming && !hasError;
  
  /// Get the effective role for this message
  String get effectiveRole {
    if (role != null) return role!;
    return isUser ? 'user' : 'assistant';
  }
  
  /// Get content length in characters
  int get contentLength => content.length;
  
  /// Check if the message content is empty
  bool get isEmpty => content.trim().isEmpty;

  /// Create a user message
  factory Message.user({
    required String id,
    required String chatId,
    required String content,
    DateTime? timestamp,
    Map<String, dynamic>? metadata,
  }) {
    return Message(
      id: id,
      chatId: chatId,
      content: content,
      isUser: true,
      timestamp: timestamp ?? DateTime.now(),
      role: 'user',
      metadata: metadata,
    );
  }

  /// Create an AI assistant message
  factory Message.assistant({
    required String id,
    required String chatId,
    required String content,
    String? model,
    DateTime? timestamp,
    MessageTokenUsage? tokenUsage,
    List<Artifact>? artifacts,
    Map<String, dynamic>? metadata,
  }) {
    return Message(
      id: id,
      chatId: chatId,
      content: content,
      isUser: false,
      timestamp: timestamp ?? DateTime.now(),
      role: 'assistant',
      model: model,
      tokenUsage: tokenUsage,
      artifacts: artifacts,
      metadata: metadata,
    );
  }

  /// Create a system message
  factory Message.system({
    required String id,
    required String chatId,
    required String content,
    DateTime? timestamp,
    Map<String, dynamic>? metadata,
  }) {
    return Message(
      id: id,
      chatId: chatId,
      content: content,
      isUser: false,
      timestamp: timestamp ?? DateTime.now(),
      role: 'system',
      metadata: metadata,
    );
  }

  @override
  List<Object?> get props => [
        id,
        chatId,
        content,
        isUser,
        timestamp,
        role,
        model,
        tokenUsage,
        artifacts,
        metadata,
        isStreaming,
        error,
      ];

  @override
  String toString() {
    return 'Message(id: $id, chatId: $chatId, isUser: $isUser, '
           'role: $effectiveRole, contentLength: $contentLength, '
           'timestamp: $timestamp)';
  }
}

/// Token usage information for a message
class MessageTokenUsage extends Equatable {
  /// Number of input tokens used
  final int inputTokens;
  
  /// Number of output tokens generated
  final int outputTokens;
  
  /// Total tokens used (input + output)
  final int totalTokens;

  const MessageTokenUsage({
    required this.inputTokens,
    required this.outputTokens,
    required this.totalTokens,
  });

  /// Create a copy with updated fields
  MessageTokenUsage copyWith({
    int? inputTokens,
    int? outputTokens,
    int? totalTokens,
  }) {
    return MessageTokenUsage(
      inputTokens: inputTokens ?? this.inputTokens,
      outputTokens: outputTokens ?? this.outputTokens,
      totalTokens: totalTokens ?? this.totalTokens,
    );
  }

  @override
  List<Object?> get props => [inputTokens, outputTokens, totalTokens];

  @override
  String toString() {
    return 'MessageTokenUsage(input: $inputTokens, output: $outputTokens, total: $totalTokens)';
  }
}