import 'dart:async';

import 'package:claude_chat_clone/domain/entities/entities.dart';
import 'package:claude_chat_clone/domain/usecases/usecases.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import 'chat_event.dart';
import 'chat_state.dart';

/// BLoC for managing individual chat state
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final CreateChat _createChat;
  final UpdateChat _updateChat;
  final GetChats _getChats;
  final GetMessages _getMessages;
  final SendMessage _sendMessage;
  final UpdateMessage _updateMessage;
  final DeleteMessage _deleteMessage;
  final WatchMessages _watchMessages;
  final SendPrompt _sendPrompt;
  final SendConversation _sendConversation;

  final Uuid _uuid = Uuid();
  StreamSubscription? _messagesSubscription;

  ChatBloc({
    required CreateChat createChat,
    required UpdateChat updateChat,
    required GetChats getChats,
    required GetMessages getMessages,
    required SendMessage sendMessage,
    required UpdateMessage updateMessage,
    required DeleteMessage deleteMessage,
    required WatchMessages watchMessages,
    required SendPrompt sendPrompt,
    required SendConversation sendConversation,
  })  : _createChat = createChat,
        _updateChat = updateChat,
        _getChats = getChats,
        _getMessages = getMessages,
        _sendMessage = sendMessage,
        _updateMessage = updateMessage,
        _deleteMessage = deleteMessage,
        _watchMessages = watchMessages,
        _sendPrompt = sendPrompt,
        _sendConversation = sendConversation,
        super(const ChatInitial()) {
    on<ChatInitialized>(_onChatInitialized);
    on<ChatLoaded>(_onChatLoaded);
    on<ChatMessageSent>(_onMessageSent);
    on<ChatMessageResent>(_onMessageResent);
    on<ChatMessageDeleted>(_onMessageDeleted);
    on<ChatMessageUpdated>(_onMessageUpdated);
    on<ChatTitleUpdated>(_onTitleUpdated);
    on<ChatSettingsUpdated>(_onSettingsUpdated);
    on<ChatArtifactAdded>(_onArtifactAdded);
    on<ChatArtifactViewed>(_onArtifactViewed);
    on<ChatSaved>(_onChatSaved);
    on<ChatRefreshed>(_onChatRefreshed);
    on<ChatSubscriptionStarted>(_onSubscriptionStarted);
    on<ChatSubscriptionStopped>(_onSubscriptionStopped);
    on<ChatMessagesReceived>(_onMessagesReceived);
    on<ChatAIResponseStarted>(_onAIResponseStarted);
    on<ChatAIResponsePartial>(_onAIResponsePartial);
    on<ChatAIResponseCompleted>(_onAIResponseCompleted);
    on<ChatAIResponseFailed>(_onAIResponseFailed);
    on<ChatResponseRegenerated>(_onResponseRegenerated);
    on<ChatExportedEvent>(_onChatExported);
    on<ChatMessagesSearched>(_onMessagesSearched);
    on<ChatMessageSearchCleared>(_onMessageSearchCleared);
    on<ChatErrorCleared>(_onErrorCleared);
    on<ChatErrorOccurred>(_onErrorOccurred);
  }

  @override
  Future<void> close() {
    _messagesSubscription?.cancel();
    return super.close();
  }

  /// Get AI response
  Future<void> _getAIResponse({
    required String content,
    required String chatId,
    required List<Message> messages,
    required String apiKey,
    required String modelId,
    int? maxTokens,
    double? temperature,
  }) async {
    try {
      AIResponse response;

      if (messages.length > 1) {
        // Use conversation endpoint for multi-turn chats
        final conversationResult = await _sendConversation.call(
          SendConversationParams(
            message: content,
            conversationHistory: messages.where((m) => !m.isUser).toList(),
            model: modelId,
            apiKey: apiKey,
            maxTokens: maxTokens,
            temperature: temperature,
          ),
        );

        response = await conversationResult.fold(
          (failure) async {
            add(ChatAIResponseFailed(
              error: failure.message,
              messageId: _uuid.v4(),
            ));
            throw Exception(failure.message);
          },
          (aiResponse) async => aiResponse,
        );
      } else {
        // Use single prompt endpoint for first message
        final promptResult = await _sendPrompt.call(
          SendPromptParams(
            message: content,
            model: modelId,
            apiKey: apiKey,
            maxTokens: maxTokens,
            temperature: temperature,
          ),
        );

        response = await promptResult.fold(
          (failure) async {
            add(ChatAIResponseFailed(
              error: failure.message,
              messageId: _uuid.v4(),
            ));
            throw Exception(failure.message);
          },
          (aiResponse) async => aiResponse,
        );
      }

      add(ChatAIResponseCompleted(
        response: response,
        messageId: _uuid.v4(),
      ));
    } catch (e) {
      add(ChatAIResponseFailed(
        error: e.toString(),
        messageId: _uuid.v4(),
      ));
    }
  }

  /// Handle AI response completion
  Future<void> _onAIResponseCompleted(
    ChatAIResponseCompleted event,
    Emitter<ChatState> emit,
  ) async {
    if (state is! ChatAIResponding) return;

    final currentState = state as ChatAIResponding;

    try {
      // Create AI message
      final aiMessage = Message.assistant(
        id: event.messageId,
        chatId: currentState.chat.id,
        content: event.response.content,
        model: event.response.model,
        tokenUsage: MessageTokenUsage(
          inputTokens: event.response.usage.inputTokens,
          outputTokens: event.response.usage.outputTokens,
          totalTokens: event.response.usage.totalTokens,
        ),
        artifacts: event.response.artifacts,
      );

      // Save AI message
      final sendResult = await _sendMessage.call(
        SendMessageParams(
          chatId: currentState.chat.id,
          message: aiMessage,
        ),
      );

      sendResult.fold(
        (failure) => emit(ChatError(
          message: 'Failed to save AI response',
          details: failure.message,
          previousState: ChatReady(
            chat: currentState.chat,
            messages: currentState.messages,
          ),
        )),
        (_) {
          final updatedMessages = [...currentState.messages, aiMessage];
          emit(ChatReady(
            chat: currentState.chat,
            messages: updatedMessages,
            isNewChat: false,
          ));
        },
      );
    } catch (e) {
      emit(ChatError(
        message: 'Failed to process AI response',
        details: e.toString(),
        previousState: ChatReady(
          chat: currentState.chat,
          messages: currentState.messages,
        ),
      ));
    }
  }

  /// Handle AI response failure
  void _onAIResponseFailed(
    ChatAIResponseFailed event,
    Emitter<ChatState> emit,
  ) {
    if (state is! ChatAIResponding) return;

    final currentState = state as ChatAIResponding;

    // Create error message
    final errorMessage = Message.assistant(
      id: event.messageId,
      chatId: currentState.chat.id,
      content: 'Sorry, I encountered an error: ${event.error}',
      //error: event.error,
    );

    emit(ChatReady(
      chat: currentState.chat,
      messages: [...currentState.messages, errorMessage],
      isNewChat: false,
    ));
  }

  void _onAIResponsePartial(
      ChatAIResponsePartial event, Emitter<ChatState> emit) {
    // Implementation for partial AI response (streaming)
  }

  void _onAIResponseStarted(
      ChatAIResponseStarted event, Emitter<ChatState> emit) {
    // Implementation for AI response started
  }

  void _onArtifactAdded(ChatArtifactAdded event, Emitter<ChatState> emit) {
    // Implementation for adding artifacts
  }

  /// Handle artifact viewing
  void _onArtifactViewed(
    ChatArtifactViewed event,
    Emitter<ChatState> emit,
  ) {
    if (state is! ChatReady) return;

    final currentState = state as ChatReady;

    emit(currentState.copyWith(currentArtifact: event.artifact));
  }

  void _onChatExported(ChatExportedEvent event, Emitter<ChatState> emit) {
    // Implementation for exporting chat
  }

  /// Initialize a chat (new or existing)
  Future<void> _onChatInitialized(
    ChatInitialized event,
    Emitter<ChatState> emit,
  ) async {
    emit(const ChatLoading());

    try {
      if (event.chatId != null) {
        // Load existing chat
        add(ChatLoaded(event.chatId!));
      } else {
        // Create new chat
        final now = DateTime.now();
        final chat = Chat(
          id: '', // Will be assigned when saved
          title: event.initialTitle ?? 'New Chat',
          messages: [],
          createdAt: now,
          updatedAt: now,
          projectId: event.projectId,
        );

        emit(ChatReady(
          chat: chat,
          messages: [],
          isNewChat: true,
        ));
      }
    } catch (e) {
      emit(ChatError(
        message: 'Failed to initialize chat',
        details: e.toString(),
      ));
    }
  }

  /// Load an existing chat
  Future<void> _onChatLoaded(
    ChatLoaded event,
    Emitter<ChatState> emit,
  ) async {
    try {
      // Get the specific chat
      final chatResult = await _getChats.call(
        GetChatsParams(type: GetChatsType.single, chatId: event.chatId),
      );

      await chatResult.fold(
        (failure) async {
          emit(ChatError(
            message: 'Failed to load chat',
            details: failure.message,
          ));
        },
        (chats) async {
          if (chats.isEmpty) {
            emit(const ChatError(message: 'Chat not found'));
            return;
          }

          final chat = chats.first;

          // Load messages
          final messagesResult = await _getMessages.call(
            GetMessagesParams(chatId: event.chatId),
          );

          messagesResult.fold(
            (failure) => emit(ChatError(
              message: 'Failed to load messages',
              details: failure.message,
            )),
            (messages) {
              emit(ChatReady(
                chat: chat,
                messages: messages,
                isNewChat: false,
              ));

              // Start listening for real-time updates
              add(const ChatSubscriptionStarted());
            },
          );
        },
      );
    } catch (e) {
      emit(ChatError(
        message: 'Unexpected error loading chat',
        details: e.toString(),
      ));
    }
  }

  void _onChatRefreshed(ChatRefreshed event, Emitter<ChatState> emit) {
    // Implementation for refreshing chat
  }

  void _onChatSaved(ChatSaved event, Emitter<ChatState> emit) {
    // Implementation for saving chat
  }

  /// Clear errors
  void _onErrorCleared(
    ChatErrorCleared event,
    Emitter<ChatState> emit,
  ) {
    if (state is ChatError) {
      final errorState = state as ChatError;
      if (errorState.previousState != null) {
        emit(errorState.previousState!);
      } else {
        emit(const ChatInitial());
      }
    }
  }

  /// Handle error occurred
  void _onErrorOccurred(
    ChatErrorOccurred event,
    Emitter<ChatState> emit,
  ) {
    emit(ChatError(
      message: event.message,
      details: event.details,
      previousState: state is ChatError ? null : state,
    ));
  }

  /// Delete a message
  Future<void> _onMessageDeleted(
    ChatMessageDeleted event,
    Emitter<ChatState> emit,
  ) async {
    if (state is! ChatReady) return;

    final currentState = state as ChatReady;

    emit(ChatDeletingMessage(
      chat: currentState.chat,
      messages: currentState.messages,
      messageId: event.messageId,
    ));

    final result = await _deleteMessage.call(
      DeleteMessageParams(
        chatId: currentState.chat.id,
        messageId: event.messageId,
      ),
    );

    result.fold(
      (failure) => emit(ChatError(
        message: 'Faile message',
        details: failure.message,
        previousState: currentState,
      )),
      (_) {
        final updatedMessages = currentState.messages
            .where((m) => m.id != event.messageId)
            .toList();

        emit(currentState.copyWith(messages: updatedMessages));
      },
    );
  }

  // Placeholder implementations for remaining events
  void _onMessageResent(ChatMessageResent event, Emitter<ChatState> emit) {
    // Implementation for resending failed messages
  }

  /// Clear message search
  void _onMessageSearchCleared(
    ChatMessageSearchCleared event,
    Emitter<ChatState> emit,
  ) {
    if (state is! ChatReady) return;

    final currentState = state as ChatReady;

    emit(currentState.copyWith(clearSearch: true));
  }

  /// Send a message
  Future<void> _onMessageSent(
    ChatMessageSent event,
    Emitter<ChatState> emit,
  ) async {
    if (state is! ChatReady) return;

    final currentState = state as ChatReady;

    try {
      // Create user message
      final userMessage = Message.user(
        id: _uuid.v4(),
        chatId: currentState.chat.id,
        content: event.content,
        metadata: event.metadata,
      );

      // If chat is new, create it first
      Chat chat = currentState.chat;
      if (currentState.isNewChat) {
        final createResult = await _createChat.call(
          CreateChatParams(chat: currentState.chat),
        );

        await createResult.fold(
          (failure) async {
            emit(ChatError(
              message: 'Failed to create chat',
              details: failure.message,
              previousState: currentState,
            ));
            return;
          },
          (chatId) async {
            chat = currentState.chat.copyWith(id: chatId);
          },
        );
      }

      // Update user message with correct chat ID
      final updatedUserMessage = userMessage.copyWith(chatId: chat.id);

      emit(ChatSendingMessage(
        chat: chat,
        messages: currentState.messages,
        pendingMessage: updatedUserMessage,
      ));

      // Send user message
      final sendResult = await _sendMessage.call(
        SendMessageParams(
          chatId: chat.id,
          message: updatedUserMessage,
        ),
      );

      await sendResult.fold(
        (failure) async {
          emit(ChatError(
            message: 'Failed to send message',
            details: failure.message,
            previousState: currentState,
          ));
        },
        (_) async {
          final updatedMessages = [
            ...currentState.messages,
            updatedUserMessage
          ];

          // Get AI response if API key and model are provided
          if (event.apiKey != null && event.modelId != null) {
            emit(ChatAIResponding(
              chat: chat,
              messages: updatedMessages,
              isStreaming: true,
            ));

            add(const ChatAIResponseStarted());

            // Send to AI
            await _getAIResponse(
              content: event.content,
              chatId: chat.id,
              messages: updatedMessages,
              apiKey: event.apiKey!,
              modelId: event.modelId!,
              maxTokens: event.maxTokens,
              temperature: event.temperature,
            );
          } else {
            emit(ChatReady(
              chat: chat,
              messages: updatedMessages,
              isNewChat: false,
            ));
          }
        },
      );
    } catch (e) {
      emit(ChatError(
        message: 'Unexpected error sending message',
        details: e.toString(),
        previousState: currentState,
      ));
    }
  }

  /// Handle received messages from subscription
  void _onMessagesReceived(
    ChatMessagesReceived event,
    Emitter<ChatState> emit,
  ) {
    if (state is! ChatReady) return;

    final currentState = state as ChatReady;

    emit(currentState.copyWith(messages: event.messages));
  }

  /// Search messages
  void _onMessagesSearched(
    ChatMessagesSearched event,
    Emitter<ChatState> emit,
  ) {
    if (state is! ChatReady) return;

    final currentState = state as ChatReady;

    if (event.query.isEmpty) {
      emit(currentState.copyWith(clearSearch: true));
      return;
    }

    final searchResults = currentState.messages.where((message) {
      return message.content.toLowerCase().contains(event.query.toLowerCase());
    }).toList();

    emit(currentState.copyWith(
      searchResults: searchResults,
      searchQuery: event.query,
    ));
  }

  void _onMessageUpdated(ChatMessageUpdated event, Emitter<ChatState> emit) {
    // Implementation for updating messages
  }

  void _onResponseRegenerated(
      ChatResponseRegenerated event, Emitter<ChatState> emit) {
    // Implementation for regenerating responses
  }

  void _onSettingsUpdated(ChatSettingsUpdated event, Emitter<ChatState> emit) {
    // Implementation for updating chat settings
  }

  /// Start listening to real-time message updates
  void _onSubscriptionStarted(
    ChatSubscriptionStarted event,
    Emitter<ChatState> emit,
  ) {
    if (state is! ChatReady) return;

    final currentState = state as ChatReady;

    _messagesSubscription?.cancel();
    _messagesSubscription = _watchMessages
        .call(WatchMessagesParams(chatId: currentState.chat.id))
        .listen(
      (result) {
        result.fold(
          (failure) => add(ChatErrorOccurred(
            'Lost connection to messages',
            details: failure.message,
          )),
          (messages) => add(ChatMessagesReceived(messages)),
        );
      },
    );

    emit(currentState.copyWith(isListening: true));
  }

  /// Stop listening to real-time updates
  void _onSubscriptionStopped(
    ChatSubscriptionStopped event,
    Emitter<ChatState> emit,
  ) {
    if (state is! ChatReady) return;

    final currentState = state as ChatReady;

    _messagesSubscription?.cancel();
    _messagesSubscription = null;

    emit(currentState.copyWith(isListening: false));
  }

  /// Update chat title
  Future<void> _onTitleUpdated(
    ChatTitleUpdated event,
    Emitter<ChatState> emit,
  ) async {
    if (state is! ChatReady) return;

    final currentState = state as ChatReady;

    emit(ChatUpdatingTitle(
      chat: currentState.chat,
      messages: currentState.messages,
      newTitle: event.title,
    ));

    final updatedChat = currentState.chat.copyWith(
      title: event.title,
      updatedAt: DateTime.now(),
    );

    final result = await _updateChat.call(
      UpdateChatParams(chat: updatedChat),
    );

    result.fold(
      (failure) => emit(ChatError(
        message: 'Faile chat title',
        details: failure.message,
        previousState: currentState,
      )),
      (_) => emit(currentState.copyWith(chat: updatedChat)),
    );
  }
}
