import 'package:claude_chat_clone/domain/entities/entities.dart';
import 'package:equatable/equatable.dart';

/// Event when AI response is complete
class ChatAIResponseCompleted extends ChatEvent {
  final AIResponse response;
  final String messageId;

  const ChatAIResponseCompleted({
    required this.response,
    required this.messageId,
  });

  @override
  List<Object?> get props => [response, messageId];
}

/// Event when AI response fails
class ChatAIResponseFailed extends ChatEvent {
  final String error;
  final String messageId;

  const ChatAIResponseFailed({
    required this.error,
    required this.messageId,
  });

  @override
  List<Object?> get props => [error, messageId];
}

/// Event for partial AI response (streaming)
class ChatAIResponsePartial extends ChatEvent {
  final String partialContent;
  final String messageId;

  const ChatAIResponsePartial({
    required this.partialContent,
    required this.messageId,
  });

  @override
  List<Object?> get props => [partialContent, messageId];
}

/// Event to handle AI response streaming
class ChatAIResponseStarted extends ChatEvent {
  const ChatAIResponseStarted();
}

/// Event to add an artifact to the chat
class ChatArtifactAdded extends ChatEvent {
  final Artifact artifact;

  const ChatArtifactAdded(this.artifact);

  @override
  List<Object?> get props => [artifact];
}

/// Event to view an artifact
class ChatArtifactViewed extends ChatEvent {
  final Artifact artifact;

  const ChatArtifactViewed(this.artifact);

  @override
  List<Object?> get props => [artifact];
}

/// Event to clear errors
class ChatErrorCleared extends ChatEvent {
  const ChatErrorCleared();
}

/// Event to handle errors
class ChatErrorOccurred extends ChatEvent {
  final String message;
  final String? details;

  const ChatErrorOccurred(this.message, {this.details});

  @override
  List<Object?> get props => [message, details];
}

/// Base class for all chat events
abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

/// Event to export chat
class ChatExportedEvent extends ChatEvent {
  final String format; // 'json', 'markdown', 'txt'

  const ChatExportedEvent(this.format);

  @override
  List<Object?> get props => [format];
}

/// Event to initialize a chat (new or existing)
class ChatInitialized extends ChatEvent {
  final String? chatId;
  final String? projectId;
  final String? initialTitle;

  const ChatInitialized({
    this.chatId,
    this.projectId,
    this.initialTitle,
  });

  @override
  List<Object?> get props => [chatId, projectId, initialTitle];
}

/// Event to load an existing chat
class ChatLoaded extends ChatEvent {
  final String chatId;

  const ChatLoaded(this.chatId);

  @override
  List<Object?> get props => [chatId];
}

/// Event to delete a message
class ChatMessageDeleted extends ChatEvent {
  final String messageId;

  const ChatMessageDeleted(this.messageId);

  @override
  List<Object?> get props => [messageId];
}

/// Event to resend a failed message
class ChatMessageResent extends ChatEvent {
  final String messageId;
  final String? apiKey;
  final String? modelId;

  const ChatMessageResent({
    required this.messageId,
    this.apiKey,
    this.modelId,
  });

  @override
  List<Object?> get props => [messageId, apiKey, modelId];
}

/// Event to clear message search
class ChatMessageSearchCleared extends ChatEvent {
  const ChatMessageSearchCleared();
}

/// Event to send a message
class ChatMessageSent extends ChatEvent {
  final String content;
  final String? apiKey;
  final String? modelId;
  final int? maxTokens;
  final double? temperature;
  final List<String>? attachments;
  final Map<String, dynamic>? metadata;

  const ChatMessageSent({
    required this.content,
    this.apiKey,
    this.modelId,
    this.maxTokens,
    this.temperature,
    this.attachments,
    this.metadata,
  });

  @override
  List<Object?> get props => [
        content,
        apiKey,
        modelId,
        maxTokens,
        temperature,
        attachments,
        metadata,
      ];
}

/// Event when messages are received from subscription
class ChatMessagesReceived extends ChatEvent {
  final List<Message> messages;

  const ChatMessagesReceived(this.messages);

  @override
  List<Object?> get props => [messages];
}

/// Event to search within chat messages
class ChatMessagesSearched extends ChatEvent {
  final String query;

  const ChatMessagesSearched(this.query);

  @override
  List<Object?> get props => [query];
}

/// Event to update a message
class ChatMessageUpdated extends ChatEvent {
  final Message message;

  const ChatMessageUpdated(this.message);

  @override
  List<Object?> get props => [message];
}

/// Event to refresh chat data
class ChatRefreshed extends ChatEvent {
  const ChatRefreshed();
}

/// Event to regenerate last AI response
class ChatResponseRegenerated extends ChatEvent {
  final String? apiKey;
  final String? modelId;

  const ChatResponseRegenerated({
    this.apiKey,
    this.modelId,
  });

  @override
  List<Object?> get props => [apiKey, modelId];
}

/// Event to save chat (if it's a new chat)
class ChatSaved extends ChatEvent {
  const ChatSaved();
}

/// Event to update chat settings
class ChatSettingsUpdated extends ChatEvent {
  final String? model;
  final double? temperature;
  final int? maxTokens;
  final Map<String, dynamic>? metadata;

  const ChatSettingsUpdated({
    this.model,
    this.temperature,
    this.maxTokens,
    this.metadata,
  });

  @override
  List<Object?> get props => [model, temperature, maxTokens, metadata];
}

/// Event to start listening to real-time updates
class ChatSubscriptionStarted extends ChatEvent {
  const ChatSubscriptionStarted();
}

/// Event to stop listening to real-time updates
class ChatSubscriptionStopped extends ChatEvent {
  const ChatSubscriptionStopped();
}

/// Event to update chat title
class ChatTitleUpdated extends ChatEvent {
  final String title;

  const ChatTitleUpdated(this.title);

  @override
  List<Object?> get props => [title];
}
