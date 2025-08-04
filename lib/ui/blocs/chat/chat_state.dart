import 'package:equatable/equatable.dart';
import 'package:claude_chat_clone/domain/entities/entities.dart';

/// Base class for all chat states
abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

/// Initial state when chat is first created
class ChatInitial extends ChatState {
  const ChatInitial();
}

/// State when chat is being loaded or initialized
class ChatLoading extends ChatState {
  const ChatLoading();
}

/// State when chat is ready and loaded
class ChatReady extends ChatState {
  final Chat chat;
  final List<Message> messages;
  final bool isNewChat;
  final bool isListening;
  final Artifact? currentArtifact;
  final List<Message> searchResults;
  final String? searchQuery;
  final Map<String, dynamic> chatSettings;

  const ChatReady({
    required this.chat,
    required this.messages,
    this.isNewChat = false,
    this.isListening = false,
    this.currentArtifact,
    this.searchResults = const [],
    this.searchQuery,
    this.chatSettings = const {},
  });

  @override
  List<Object?> get props => [
        chat,
        messages,
        isNewChat,
        isListening,
        currentArtifact,
        searchResults,
        searchQuery,
        chatSettings,
      ];

  /// Get the number of messages in the chat
  int get messageCount => messages.length;

  /// Check if the chat has any messages
  bool get hasMessages => messages.isNotEmpty;

  /// Get the last message in the chat
  Message? get lastMessage => messages.isNotEmpty ? messages.last : null;

  /// Get user messages only
  List<Message> get userMessages => messages.where((m) => m.isUser).toList();

  /// Get AI messages only
  List<Message> get aiMessages => messages.where((m) => !m.isUser).toList();

  /// Check if there are any artifacts in the chat
  bool get hasArtifacts => messages.any((m) => m.hasArtifacts);

  /// Get all artifacts from the chat
  List<Artifact> get allArtifacts {
    final artifacts = <Artifact>[];
    for (final message in messages) {
      if (message.hasArtifacts && message.artifacts != null) {
        artifacts.addAll(message.artifacts!);
      }
    }
    return artifacts;
  }

  /// Check if chat is associated with a project
  bool get belongsToProject => chat.belongsToProject;

  /// Get project ID if chat belongs to a project
  String? get projectId => chat.projectId;

  /// Check if search is active
  bool get isSearching => searchQuery != null && searchQuery!.isNotEmpty;

  /// Get effective messages (search results if searching, otherwise all messages)
  List<Message> get effectiveMessages => isSearching ? searchResults : messages;

  /// Get chat model from settings
  String? get selectedModel => chatSettings['model'] as String?;

  /// Get temperature setting
  double? get temperature => chatSettings['temperature'] as double?;

  /// Get max tokens setting
  int? get maxTokens => chatSettings['maxTokens'] as int?;

  ChatReady copyWith({
    Chat? chat,
    List<Message>? messages,
    bool? isNewChat,
    bool? isListening,
    Artifact? currentArtifact,
    List<Message>? searchResults,
    String? searchQuery,
    Map<String, dynamic>? chatSettings,
    bool clearCurrentArtifact = false,
    bool clearSearch = false,
  }) {
    return ChatReady(
      chat: chat ?? this.chat,
      messages: messages ?? this.messages,
      isNewChat: isNewChat ?? this.isNewChat,
      isListening: isListening ?? this.isListening,
      currentArtifact: clearCurrentArtifact ? null : (currentArtifact ?? this.currentArtifact),
      searchResults: clearSearch ? [] : (searchResults ?? this.searchResults),
      searchQuery: clearSearch ? null : (searchQuery ?? this.searchQuery),
      chatSettings: chatSettings ?? this.chatSettings,
    );
  }
}

/// State when a message is being sent
class ChatSendingMessage extends ChatState {
  final Chat chat;
  final List<Message> messages;
  final Message pendingMessage;
  final bool isAIResponding;

  const ChatSendingMessage({
    required this.chat,
    required this.messages,
    required this.pendingMessage,
    this.isAIResponding = false,
  });

  @override
  List<Object?> get props => [chat, messages, pendingMessage, isAIResponding];

  /// Get all messages including the pending one
  List<Message> get allMessages => [...messages, pendingMessage];
}

/// State when AI is responding (streaming or processing)
class ChatAIResponding extends ChatState {
  final Chat chat;
  final List<Message> messages;
  final Message? partialResponse;
  final String? currentContent;
  final bool isStreaming;

  const ChatAIResponding({
    required this.chat,
    required this.messages,
    this.partialResponse,
    this.currentContent,
    this.isStreaming = false,
  });

  @override
  List<Object?> get props => [
        chat,
        messages,
        partialResponse,
        currentContent,
        isStreaming,
      ];

  /// Get all messages including partial response if present
  List<Message> get allMessages {
    if (partialResponse != null) {
      return [...messages, partialResponse!];
    }
    return messages;
  }
}

/// State when chat is being saved
class ChatSaving extends ChatState {
  final Chat chat;
  final List<Message> messages;

  const ChatSaving({
    required this.chat,
    required this.messages,
  });

  @override
  List<Object?> get props => [chat, messages];
}

/// State when chat title is being updated
class ChatUpdatingTitle extends ChatState {
  final Chat chat;
  final List<Message> messages;
  final String newTitle;

  const ChatUpdatingTitle({
    required this.chat,
    required this.messages,
    required this.newTitle,
  });

  @override
  List<Object?> get props => [chat, messages, newTitle];
}

/// State when a message is being deleted
class ChatDeletingMessage extends ChatState {
  final Chat chat;
  final List<Message> messages;
  final String messageId;

  const ChatDeletingMessage({
    required this.chat,
    required this.messages,
    required this.messageId,
  });

  @override
  List<Object?> get props => [chat, messages, messageId];
}

/// State when chat is being exported
class ChatExporting extends ChatState {
  final Chat chat;
  final List<Message> messages;
  final String format;

  const ChatExporting({
    required this.chat,
    required this.messages,
    required this.format,
  });

  @override
  List<Object?> get props => [chat, messages, format];
}

/// State when an error occurs
class ChatError extends ChatState {
  final String message;
  final String? details;
  final ChatState? previousState;
  final String? errorCode;

  const ChatError({
    required this.message,
    this.details,
    this.previousState,
    this.errorCode,
  });

  @override
  List<Object?> get props => [message, details, previousState, errorCode];

  /// Check if this is a network error
  bool get isNetworkError =>
      errorCode == 'network' ||
      message.toLowerCase().contains('network') ||
      message.toLowerCase().contains('connection');

  /// Check if this is an API error
  bool get isApiError =>
      errorCode == 'api' ||
      message.toLowerCase().contains('api') ||
      message.toLowerCase().contains('unauthorized');

  /// Check if this is a validation error
  bool get isValidationError =>
      errorCode == 'validation' ||
      message.toLowerCase().contains('validation') ||
      message.toLowerCase().contains('invalid');

  /// Check if this is a storage error
  bool get isStorageError =>
      errorCode == 'storage' ||
      message.toLowerCase().contains('storage') ||
      message.toLowerCase().contains('database');

  /// Check if the error is recoverable
  bool get isRecoverable => isNetworkError || isApiError;
}

/// State when chat export is complete
class ChatExported extends ChatState {
  final Chat chat;
  final List<Message> messages;
  final String exportedContent;
  final String format;
  final String? filePath;

  const ChatExported({
    required this.chat,
    required this.messages,
    required this.exportedContent,
    required this.format,
    this.filePath,
  });

  @override
  List<Object?> get props => [chat, messages, exportedContent, format, filePath];
}

/// State when chat needs to be configured (missing API key, model, etc.)
class ChatNeedsConfiguration extends ChatState {
  final String reason;
  final List<String> missingRequirements;

  const ChatNeedsConfiguration({
    required this.reason,
    this.missingRequirements = const [],
  });

  @override
  List<Object?> get props => [reason, missingRequirements];

  /// Check if API key is missing
  bool get needsApiKey => missingRequirements.contains('api_key');

  /// Check if model selection is missing
  bool get needsModel => missingRequirements.contains('model');
}