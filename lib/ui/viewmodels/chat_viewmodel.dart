import 'dart:async';
import 'dart:developer';

import 'package:claude_chat_clone/data/repositories/chat_repository.dart';
import 'package:claude_chat_clone/data/services/claude_api_service.dart';
import 'package:claude_chat_clone/data/services/global_keys.dart';
import 'package:claude_chat_clone/domain/models/models.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class ChatViewModel extends ChangeNotifier {
  final ChatRepository _chatRepository = ChatRepository.instance;
  final ClaudeApiService _claudeApiService = ClaudeApiService();
  final Uuid _uuid = Uuid();

  // State variables
  Chat? _chat;
  List<Message> _messages = [];
  bool _isLoading = false;
  bool _isInitialized = false;
  bool _isSending = false;
  String? _error;

  // Stream subscriptions
  StreamSubscription<(bool, List<Message>?)>? _messagesSubscription;

  // Getters
  Chat? get chat => _chat;
  String? get error => _error;
  bool get hasMessages => _messages.isNotEmpty;
  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;
  bool get isSending => _isSending;
  List<Message> get messages => _messages;

  /// Clear error state
  void clearError() {
    _clearError();
  }

  /// Delete a message
  Future<bool> deleteMessage(String messageId) async {
    if (_chat?.id == null) return false;

    try {
      final success = await _chatRepository.deleteMessage(_chat!.id, messageId);
      if (!success) {
        _showError('Failed to delete message. Please try again.');
      }
      return success;
    } catch (e) {
      _setError('Error deleting message: $e');
      log('Error deleting message: $e');
      return false;
    }
  }

  @override
  void dispose() {
    _messagesSubscription?.cancel();
    super.dispose();
  }

  /// Format timestamp for display
  String formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  /// Initialize the chat view model
  Future<void> initialize(String? chatId) async {
    try {
      _setLoading(true);
      _clearError();

      if (chatId == null || chatId.isEmpty) {
        // Create new chat
        _chat = _createNewChat();
        _isInitialized = true;
      } else {
        // Load existing chat
        final (success, existingChat) = await _chatRepository.readChat(chatId);

        if (!success) {
          _setError('Failed to load chat');
          return;
        }

        if (existingChat == null) {
          _showError('Chat not found. Please start a new chat.');
          return;
        }

        _chat = existingChat;
        _listenToMessages();
        _isInitialized = true;
      }
    } catch (e) {
      _setError('Error initializing chat: $e');
      log('Error initializing chat: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Send a message
  Future<void> sendMessage(String content,
      {String? apiKey, String? model}) async {
    if (content.trim().isEmpty || _isSending) return;

    try {
      _isSending = true;
      notifyListeners();

      // Ensure chat exists in database
      if (_chat?.id == null || _chat!.id.isEmpty) {
        final chatId = await _chatRepository.createChat(_chat!);
        if (chatId == null || chatId.isEmpty) {
          _setError('Failed to create chat');
          return;
        }
        _chat = _chat!.copyWith(id: chatId);
        _listenToMessages();
      }

      // Create user message
      final userMessage = Message(
        id: _uuid.v4(),
        content: content,
        isUser: true,
        timestamp: DateTime.now(),
        chatId: _chat!.id,
      );

      // Save user message
      final success = await _chatRepository.addMessage(_chat!.id, userMessage);
      if (!success) {
        _setError('Failed to send message');
        return;
      }

      // Get AI response if API key and model are provided
      if (apiKey != null && model != null) {
        await _getAIResponse(content, apiKey, model);
      }
    } catch (e) {
      _setError('Error sending message: $e');
      log('Error sending message: $e');
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }

  /// Send a suggestion message
  Future<void> sendSuggestion(String suggestion,
      {String? apiKey, String? model}) async {
    await sendMessage(suggestion, apiKey: apiKey, model: model);
  }

  /// Update chat title
  Future<bool> updateChatTitle(String newTitle) async {
    if (_chat == null || newTitle.trim().isEmpty) return false;

    try {
      final updatedChat = _chat!.copyWith(
        title: newTitle.trim(),
        updatedAt: DateTime.now(),
      );

      final success = await _chatRepository.updateChat(updatedChat);
      if (success) {
        _chat = updatedChat;
        _showSuccess('Chat title updated successfully!');
        notifyListeners();
      } else {
        _showError('Failed to update chat title. Please try again.');
      }
      return success;
    } catch (e) {
      _setError('Error updating chat title: $e');
      log('Error updating chat title: $e');
      return false;
    }
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  /// Create a new chat instance
  Chat _createNewChat({String? title, String? projectId}) {
    final now = DateTime.now();
    return Chat(
      id: '',
      title: title ?? 'Untitled',
      messages: [],
      createdAt: now,
      updatedAt: now,
      projectId: projectId,
    );
  }

  /// Get AI response from Claude API
  Future<void> _getAIResponse(
      String userMessage, String apiKey, String model) async {
    try {
      final response = await _claudeApiService.sendMessage(
        message: userMessage,
        model: model,
        apiKey: apiKey,
        conversationHistory: _messages,
      );

      // Create AI message
      final aiMessage = Message(
        id: _uuid.v4(),
        content: response,
        isUser: false,
        timestamp: DateTime.now(),
        chatId: _chat!.id,
      );

      // Save AI message
      await _chatRepository.addMessage(_chat!.id, aiMessage);
    } catch (e) {
      _setError('Error getting AI response: $e');
      log('Error getting AI response: $e');

      // Create error message
      final errorMessage = Message(
        id: _uuid.v4(),
        content: 'Sorry, I encountered an error: $e',
        isUser: false,
        timestamp: DateTime.now(),
        chatId: _chat!.id,
      );

      await _chatRepository.addMessage(_chat!.id, errorMessage);
    }
  }

  /// Listen to real-time message updates
  void _listenToMessages() {
    if (_chat?.id == null || _chat!.id.isEmpty) return;

    _messagesSubscription?.cancel();
    _messagesSubscription =
        _chatRepository.listenToChatMessages(_chat!.id).listen(
      (result) {
        final (success, messages) = result;

        if (success) {
          _messages = messages ?? [];
          notifyListeners();
        } else {
          _setError('Failed to load messages');
        }
      },
      onError: (error) {
        _setError('Lost connection to messages. Reconnecting...');
        log('Error listening to messages: $error');
      },
    );
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  /// Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _showError(String message) {
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade300,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 4),
      ),
    );
  }

  void _showSuccess(String message) {
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green.shade300,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }
}
