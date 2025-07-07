import 'dart:async';
import 'dart:developer';

import 'package:claude_chat_clone/models/models.dart';
import 'package:claude_chat_clone/repositories/chat_repository.dart';
import 'package:claude_chat_clone/screens/services/chat_service.dart';
import 'package:flutter/material.dart';

class ChatViewModel extends ChangeNotifier {
  final ChatRepository _chatRepository = ChatRepository.instance;
  final ChatService _chatService = ChatService.instance;

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

      final result = await _chatService.initialize(chatId);

      if (result != null) {
        _chat = result;
        _listenToMessages();
        _isInitialized = true;
      } else {
        _setError('Failed to initialize chat');
      }
    } catch (e) {
      _setError('Error initializing chat: $e');
      log('Error initializing chat: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Send a message
  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty || _isSending) return;

    try {
      _isSending = true;
      notifyListeners();

      // Ensure chat exists
      if (_chat?.id == null || _chat!.id.isEmpty) {
        final newChat = await _chatService.saveChat(_chat!);
        if (newChat == null || newChat.id.isEmpty) {
          _setError('Failed to create chat');
          return;
        }
        _chat = newChat;
        _listenToMessages();
      }

      final success = await _chatService.sendMessage(
        chatId: _chat!.id,
        content: content,
      );

      if (!success) {
        _setError('Failed to send message');
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
  Future<void> sendSuggestion(String suggestion) async {
    await sendMessage(suggestion);
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  /// Listen to real-time message updates
  void _listenToMessages() {
    if (_chat?.id == null || _chat!.id.isEmpty) return;

    _messagesSubscription?.cancel();
    _messagesSubscription =
        _chatRepository.listenToChatMessages(_chat!.id).listen((result) {
      final (success, messages) = result;

      if (success) {
        _messages = messages ?? [];
        notifyListeners();
      } else {
        _setError('Failed to load messages');
      }
    });
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
}
