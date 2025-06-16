// lib/services/chat_service.dart
import 'dart:developer';

import 'package:claude_chat_clone/models/models.dart';
import 'package:claude_chat_clone/repositories/chat_repository.dart';
import 'package:claude_chat_clone/services/claude_api_service.dart';
import 'package:claude_chat_clone/services/global_keys.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class ChatService {
  static final ChatService _instance = ChatService._internal();
  static ChatService get instance => _instance;

  final ChatRepository _chatRepository = ChatRepository.instance;
  final ClaudeApiService _claudeApiService = ClaudeApiService();
  final Uuid _uuid = Uuid();

  // You'll need to implement settings service to get API key
  String? _apiKey;
  final String _defaultModel = 'claude-3-sonnet-20240229';

  factory ChatService() => _instance;
  ChatService._internal();

  /// Initialize the service with API key
  void initialize(String apiKey) {
    _apiKey = apiKey;
  }

  Future<Chat?> initChatService(String chatId) async {
    // Initialize chat service with API key (you'll need to get this from settings)
    // ChatService.instance.initialize('your-api-key-here');

    try {
      // Load existing chat
      final existingChat = await ChatService.instance.getChat(chatId);

      if (existingChat != null) {
        return existingChat;
      }

      // Chat not found, create new one
      final newChat = await ChatService.instance.createChat();

      // Show error if chat creation fails
      if (newChat == null) {
        scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(content: Text('Failed to create new chat')),
        );
        return null;
      }

      return newChat;
    } catch (e) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text('Failed to initialize chat: $e')),
      );
      return null;
    }
  }

  /// Send a message and handle the complete flow
  Future<SendMessageResult> sendMessage({
    required String chatId,
    required String content,
    String? model,
  }) async {
    try {
      // 1. Validate inputs
      if (content.trim().isEmpty) {
        return SendMessageResult.error('Message cannot be empty');
      }

      if (_apiKey == null || _apiKey!.isEmpty) {
        return SendMessageResult.error('API key not configured');
      }

      // 2. Get or create chat
      Chat? chat = await getChat(chatId);
      bool isNewChat = chat == null;

      if (isNewChat) {
        // Create new chat
        chat = Chat(
          id: chatId.isEmpty ? _uuid.v4() : chatId,
          title: _generateChatTitle(content),
          messages: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final created = await _chatRepository.createChat(chat);
        if (!created) {
          return SendMessageResult.error('Failed to create chat');
        }
      }

      // 3. Create and save user message
      final userMessage = Message(
        id: _uuid.v4(),
        chatId: chat.id,
        content: content.trim(),
        isUser: true,
        timestamp: DateTime.now(),
      );

      final userMessageSaved =
          await _chatRepository.addMessage(chat.id, userMessage);
      if (!userMessageSaved) {
        return SendMessageResult.error('Failed to save user message');
      }

      // 4. Get conversation history for API call
      final (historySuccess, messages) =
          await _chatRepository.readChatMessages(chat.id);
      if (!historySuccess) {
        return SendMessageResult.error('Failed to load conversation history');
      }

      List<Message> conversationHistory = messages ?? [];

      // 5. Send to Claude API
      try {
        final aiResponse = await _claudeApiService.sendMessage(
          message: content,
          model: model ?? _defaultModel,
          apiKey: _apiKey!,
          conversationHistory: conversationHistory,
        );

        // 6. Create and save AI response message
        final aiMessage = Message(
          id: _uuid.v4(),
          chatId: chat.id,
          content: aiResponse,
          isUser: false,
          timestamp: DateTime.now(),
          hasArtifact: _detectArtifact(aiResponse),
          artifact: _extractArtifact(aiResponse),
        );

        final aiMessageSaved =
            await _chatRepository.addMessage(chat.id, aiMessage);
        if (!aiMessageSaved) {
          log('Warning: AI response received but failed to save to database');
          return SendMessageResult.partial(
            userMessage: userMessage,
            aiMessage: aiMessage,
            error: 'Response received but not saved to database',
          );
        }

        // 7. Update chat title if it's a new chat with generic title
        if (isNewChat ||
            chat.title == 'Untitled' ||
            chat.title.startsWith('New Chat')) {
          final newTitle = _generateChatTitle(content);
          final updatedChat = chat.copyWith(title: newTitle);
          await _chatRepository.updateChat(updatedChat);
        }

        return SendMessageResult.success(
          userMessage: userMessage,
          aiMessage: aiMessage,
        );
      } catch (apiError) {
        log('Claude API error: $apiError');
        return SendMessageResult.apiError(
          userMessage: userMessage,
          error: 'Failed to get AI response: ${apiError.toString()}',
        );
      }
    } catch (e) {
      log('Unexpected error in sendMessage: $e');
      return SendMessageResult.error('Unexpected error: ${e.toString()}');
    }
  }

  /// Create a new chat
  Future<Chat?> createChat({
    String? title,
    String? userId,
    String? projectId,
  }) async {
    try {
      final now = DateTime.now();

      final chat = Chat(
        id: _uuid.v4(),
        userId: userId,
        title: title ?? 'New Chat',
        messages: [],
        createdAt: now,
        updatedAt: now,
        projectId: projectId,
      );

      final success = await _chatRepository.createChat(chat);
      return success ? chat : null;
    } catch (e) {
      log('Error creating chat: $e');
      return null;
    }
  }

  /// Get a chat by ID
  Future<Chat?> getChat(String chatId) async {
    try {
      final (success, chat) = await _chatRepository.readChat(chatId);
      return success ? chat : null;
    } catch (e) {
      log('Error getting chat: $e');
      return null;
    }
  }

  /// Delete a chat
  Future<bool> deleteChat(String chatId) async {
    try {
      return await _chatRepository.deleteChat(chatId);
    } catch (e) {
      log('Error deleting chat: $e');
      return false;
    }
  }

  /// Update chat title
  Future<bool> updateChatTitle(String chatId, String title) async {
    try {
      final chat = await getChat(chatId);
      if (chat == null) return false;

      final updatedChat = chat.copyWith(title: title);
      return await _chatRepository.updateChat(updatedChat);
    } catch (e) {
      log('Error updating chat title: $e');
      return false;
    }
  }

  /// Clear messages in a chat
  Future<bool> clearChatMessages(String chatId) async {
    try {
      final chat = await getChat(chatId);
      if (chat == null) return false;

      // Delete all messages for this chat
      final (success, messages) =
          await _chatRepository.readChatMessages(chatId);
      if (success && messages != null) {
        for (final message in messages) {
          await _chatRepository.deleteMessage(chatId, message.id);
        }
      }

      // Update chat
      final clearedChat = chat.clearMessages();
      return await _chatRepository.updateChat(clearedChat);
    } catch (e) {
      log('Error clearing chat messages: $e');
      return false;
    }
  }

  /// Generate a chat title from the first message
  String _generateChatTitle(String firstMessage) {
    final cleaned = firstMessage.trim();
    if (cleaned.length <= 50) {
      return cleaned;
    }

    // Find a good breaking point (end of sentence or word)
    final truncated = cleaned.substring(0, 50);
    final lastSpace = truncated.lastIndexOf(' ');
    final lastPeriod = truncated.lastIndexOf('.');
    final lastQuestion = truncated.lastIndexOf('?');

    final breakPoint = [lastPeriod, lastQuestion, lastSpace]
        .where((i) => i > 20) // Don't break too early
        .fold(-1, (max, current) => current > max ? current : max);

    if (breakPoint > 0) {
      return cleaned.substring(
          0, breakPoint + (breakPoint == lastSpace ? 0 : 1));
    }

    return '$truncated...';
  }

  /// Detect if response contains an artifact
  bool _detectArtifact(String response) {
    // Simple detection - you can make this more sophisticated
    return response.contains('```') ||
        response.toLowerCase().contains('here\'s the code') ||
        response.toLowerCase().contains('artifact');
  }

  /// Extract artifact information from response
  Map<String, dynamic>? _extractArtifact(String response) {
    if (!_detectArtifact(response)) return null;

    // Simple extraction - you should implement proper parsing
    final codeBlockRegex = RegExp(r'```(\w+)?\n(.*?)\n```', dotAll: true);
    final match = codeBlockRegex.firstMatch(response);

    if (match != null) {
      return {
        'type': 'code',
        'language': match.group(1) ?? 'text',
        'content': match.group(2) ?? '',
        'title': 'Code Snippet',
      };
    }

    return null;
  }
}

/// Result class for send message operation
class SendMessageResult {
  final bool success;
  final Message? userMessage;
  final Message? aiMessage;
  final String? error;
  final SendMessageStatus status;

  const SendMessageResult._({
    required this.success,
    required this.status,
    this.userMessage,
    this.aiMessage,
    this.error,
  });

  factory SendMessageResult.success({
    required Message userMessage,
    required Message aiMessage,
  }) {
    return SendMessageResult._(
      success: true,
      status: SendMessageStatus.success,
      userMessage: userMessage,
      aiMessage: aiMessage,
    );
  }

  factory SendMessageResult.error(String error) {
    return SendMessageResult._(
      success: false,
      status: SendMessageStatus.error,
      error: error,
    );
  }

  factory SendMessageResult.apiError({
    required Message userMessage,
    required String error,
  }) {
    return SendMessageResult._(
      success: false,
      status: SendMessageStatus.apiError,
      userMessage: userMessage,
      error: error,
    );
  }

  factory SendMessageResult.partial({
    required Message userMessage,
    required Message aiMessage,
    required String error,
  }) {
    return SendMessageResult._(
      success: false,
      status: SendMessageStatus.partial,
      userMessage: userMessage,
      aiMessage: aiMessage,
      error: error,
    );
  }
}

enum SendMessageStatus {
  success,
  error,
  apiError,
  partial,
}
