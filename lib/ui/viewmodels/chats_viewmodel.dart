import 'dart:async';
import 'dart:developer';

import 'package:claude_chat_clone/data/repositories/chat_repository.dart';
import 'package:claude_chat_clone/data/services/global_keys.dart';
import 'package:claude_chat_clone/domain/models/models.dart';
import 'package:flutter/material.dart';

class ChatsViewModel extends ChangeNotifier {
  final ChatRepository _chatRepository = ChatRepository.instance;

  // State variables
  List<Chat> _allChats = [];
  List<Chat> _filteredChats = [];
  bool _isLoading = true;
  String? _error;
  String _searchQuery = '';

  // Stream subscription for real-time updates
  StreamSubscription<(bool, List<Chat>?)>? _chatsSubscription;

  // Getters
  List<Chat> get allChats => List.unmodifiable(_allChats);
  String? get error => _error;
  List<Chat> get filteredChats => List.unmodifiable(_filteredChats);
  bool get hasChats => _allChats.isNotEmpty;
  bool get hasFilteredChats => _filteredChats.isNotEmpty;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;

  /// Clear error state
  void clearError() {
    _clearError();
  }

  /// Clear search and show all chats
  void clearSearch() {
    _searchQuery = '';
    _filteredChats = List.from(_allChats);
    notifyListeners();
  }

  /// Delete a chat
  Future<bool> deleteChat(String chatId) async {
    try {
      final success = await _chatRepository.deleteChat(chatId);

      if (success) {
        _showSuccess('Chat deleted successfully!');
        return true;
      } else {
        _showError('Failed to delete chat. Please try again.');
        return false;
      }
    } catch (e) {
      _setError('Failed to delete chat: $e');
      _showError('Failed to delete chat. Please try again.');
      log('Error deleting chat: $e');
      return false;
    }
  }

  @override
  void dispose() {
    _chatsSubscription?.cancel();
    super.dispose();
  }

  /// Get chat count for a specific project
  Future<int> getChatCountForProject(String projectId) async {
    try {
      final (success, count) =
          await _chatRepository.getChatCountForProject(projectId);

      if (success) {
        return count;
      } else {
        _showError('Failed to get chat count. Please check your connection.');
        return 0;
      }
    } catch (e) {
      _setError('Failed to get chat count: $e');
      log('Error getting chat count for project: $e');
      return 0;
    }
  }

  /// Get chats for a specific project
  Stream<List<Chat>> getProjectChats(String projectId) {
    return _chatRepository.listenToProjectChats(projectId).map((result) {
      final (success, chats) = result;

      if (!success) {
        _showError('Lost connection to project chats. Reconnecting...');
        return <Chat>[];
      }

      return chats ?? [];
    });
  }

  /// Initialize the viewmodel and load chats
  Future<void> initialize() async {
    try {
      _setLoading(true);
      _clearError();

      // Start listening to real-time chat updates
      _listenToChats();
    } catch (e) {
      _setError('Failed to initialize chats: $e');
      log('Error initializing chats: $e');
    }
  }

  /// Refresh chats manually
  Future<void> refreshChats() async {
    try {
      _setLoading(true);
      _clearError();

      final (success, chats) = await _chatRepository.readAllChats();

      if (success) {
        _updateChats(chats ?? []);
      } else {
        _setError('Failed to refresh chats. Please check your connection.');
      }
    } catch (e) {
      _setError('Failed to refresh chats: $e');
      log('Error refreshing chats: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Rename a chat
  Future<bool> renameChat(String chatId, String newTitle) async {
    if (newTitle.trim().isEmpty) return false;

    try {
      // Get the current chat
      final (success, chat) = await _chatRepository.readChat(chatId);

      if (!success || chat == null) {
        _showError('Failed to load chat for renaming.');
        return false;
      }

      // Update the chat with new title
      final updatedChat = chat.copyWith(
        title: newTitle.trim(),
        updatedAt: DateTime.now(),
      );

      final updateSuccess = await _chatRepository.updateChat(updatedChat);

      if (updateSuccess) {
        _showSuccess('Chat renamed successfully!');
        return true;
      } else {
        _showError('Failed to rename chat. Please try again.');
        return false;
      }
    } catch (e) {
      _setError('Failed to rename chat: $e');
      _showError('Failed to rename chat. Please try again.');
      log('Error renaming chat: $e');
      return false;
    }
  }

  /// Search chats based on query
  void searchChats(String query) {
    _searchQuery = query.toLowerCase();

    if (_searchQuery.isEmpty) {
      _filteredChats = List.from(_allChats);
    } else {
      _filteredChats = _allChats.where((chat) {
        final titleMatch = chat.title.toLowerCase().contains(_searchQuery);
        final lastMessageMatch =
            chat.lastMessage?.content.toLowerCase().contains(_searchQuery) ??
                false;
        return titleMatch || lastMessageMatch;
      }).toList();
    }

    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  /// Listen to real-time chat updates
  void _listenToChats() {
    _chatsSubscription?.cancel();
    _chatsSubscription = _chatRepository.listenToAllChats().listen(
      (result) {
        final (success, chats) = result;

        if (success) {
          _updateChats(chats ?? []);
          _setLoading(false);
        } else {
          _setError('Lost connection to chats. Reconnecting...');
          log('Error listening to chats');
        }
      },
      onError: (error) {
        _setError('Lost connection to chats. Reconnecting...');
        log('Error listening to chats: $error');
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

  /// Update chats and apply current search filter
  void _updateChats(List<Chat> chats) {
    _allChats = chats;

    // Apply current search filter
    if (_searchQuery.isEmpty) {
      _filteredChats = List.from(_allChats);
    } else {
      searchChats(_searchQuery);
      return; // searchChats will call notifyListeners
    }

    notifyListeners();
  }
}
