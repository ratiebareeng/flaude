import 'package:claude_chat_clone/models/models.dart';
import 'package:claude_chat_clone/repositories/repositories.dart';
import 'package:claude_chat_clone/services/global_keys.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class ChatService {
  static final ChatService _instance = ChatService._internal();

  static ChatService get instance => _instance;

  factory ChatService() => _instance;

  ChatService._internal();

  final Uuid _uuid = Uuid();

  Future<Chat?> initialize(String? chatId) async {
    try {
      // Chat not found, create new one
      if (chatId == null || chatId.isEmpty) {
        final newChat = await ChatService.instance.createChat();

        return newChat;
      }

      // Load existing chat
      final existingChat = await ChatService.instance.getChat(chatId);

      if (existingChat == null) {
        _showError('Chat not found. Please start a new chat.');
        return null;
      }

      return existingChat;
    } catch (e) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text('Failed to initialize chat: $e')),
      );
      return null;
    }
  }

  /// Add a message to a chat
  Future<bool> addMessage(String chatId, Message message) async {
    final success = await ChatRepository.instance.addMessage(chatId, message);

    if (!success) {
      _showError('Failed to send message. Please try again.');
      return false;
    }

    return success;
  }

  /// Clear all messages from a chat (keeping the chat itself)
  Future<bool> clearChatMessages(String chatId) async {
    try {
      final (success, messages) =
          await ChatRepository.instance.readChatMessages(chatId);

      if (!success) {
        _showError('Failed to load messages for clearing.');
        return false;
      }

      // Delete all messages
      for (final message in messages ?? <Message>[]) {
        await ChatRepository.instance.deleteMessage(chatId, message.id);
      }

      // Update chat to clear last message
      final (chatSuccess, chat) =
          await ChatRepository.instance.readChat(chatId);
      if (chatSuccess && chat != null) {
        final updatedChat = chat.clearMessages();
        await updateChat(updatedChat);
      }

      _showSuccess('Chat cleared successfully!');
      return true;
    } catch (e) {
      _showError('Failed to clear chat. Please try again.');
      return false;
    }
  }

  /// Create a new chat
  Future<Chat?> createChat({
    String? title,
    String? userId,
    String? projectId,
  }) async {
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

    final success = await ChatRepository.instance.createChat(chat);

    if (!success) {
      _showError('Failed to create chat. Please try again.');
      return null;
    }

    return chat;
  }

  /// Delete a chat and all its messages
  Future<bool> deleteChat(String chatId) async {
    final success = await ChatRepository.instance.deleteChat(chatId);

    if (!success) {
      _showError('Failed to delete chat. Please try again.');
      return false;
    }

    _showSuccess('Chat deleted successfully!');
    return success;
  }

  /// Delete a message from a chat
  Future<bool> deleteMessage(String chatId, String messageId) async {
    final success =
        await ChatRepository.instance.deleteMessage(chatId, messageId);

    if (!success) {
      _showError('Failed to delete message. Please try again.');
      return false;
    }

    return success;
  }

  /// Get all chats
  Future<List<Chat>> getAllChats() async {
    final (success, chats) = await ChatRepository.instance.readAllChats();

    if (!success) {
      _showError('Failed to load chats. Please check your connection.');
      return [];
    }

    return chats ?? [];
  }

  /// Get a specific chat
  Future<Chat?> getChat(String chatId) async {
    final (success, chat) = await ChatRepository.instance.readChat(chatId);

    if (!success) {
      _showError('Failed to load chat. Please check your connection.');
      return null;
    }

    return chat;
  }

  /// Get chat count for a project
  Future<int> getChatCountForProject(String projectId) async {
    final (success, count) =
        await ChatRepository.instance.getChatCountForProject(projectId);

    if (!success) {
      _showError('Failed to get chat count. Please check your connection.');
      return 0;
    }

    return count;
  }

  /// Get messages for a chat
  Future<List<Message>> getChatMessages(String chatId) async {
    final (success, messages) =
        await ChatRepository.instance.readChatMessages(chatId);

    if (!success) {
      _showError('Failed to load messages. Please check your connection.');
      return [];
    }

    return messages ?? [];
  }

  /// Get recent chats (last 10 by default)
  Future<List<Chat>> getRecentChats({int limit = 10}) async {
    final allChats = await getAllChats();

    // Chats are already sorted by updatedAt in repository
    return allChats.take(limit).toList();
  }

  /// Rename a chat
  Future<bool> renameChat(String chatId, String newTitle) async {
    try {
      final (success, chat) = await ChatRepository.instance.readChat(chatId);

      if (!success || chat == null) {
        _showError('Failed to load chat for renaming.');
        return false;
      }

      final updatedChat = chat.copyWith(
        title: newTitle,
        updatedAt: DateTime.now(),
      );

      final updateSuccess = await updateChat(updatedChat);
      if (updateSuccess) {
        _showSuccess('Chat renamed successfully!');
      }

      return updateSuccess;
    } catch (e) {
      _showError('Failed to rename chat. Please try again.');
      return false;
    }
  }

  /// Search chats by title or content
  Stream<List<Chat>> searchChats(String query) {
    return watchAllChats().map((chats) {
      if (query.isEmpty) return chats;

      return chats.where((chat) {
        final titleMatch =
            chat.title.toLowerCase().contains(query.toLowerCase());
        final lastMessageMatch =
            //chat.lastMessage?
            chat.lastMessage?.content
                    .toLowerCase()
                    .contains(query.toLowerCase()) ??
                false;
        return titleMatch || lastMessageMatch;
      }).toList();
    });
  }

  /// Send a message and optionally get AI response
  Future<bool> sendMessage({
    required String chatId,
    required String content,
    bool getAIResponse = false,
  }) async {
    try {
      // Create user message
      final userMessage = Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: content,
        isUser: true,
        timestamp: DateTime.now(),
        chatId: chatId,
      );

      // Add user message
      final success = await addMessage(chatId, userMessage);
      if (!success) return false;

      // TODO: Integrate with Claude API service for AI response
      if (getAIResponse) {
        // This is where you would integrate with ClaudeApiService
        // For now, just return success
      }

      return true;
    } catch (e) {
      _showError('Failed to send message. Please try again.');
      return false;
    }
  }

  /// Create a new chat with an initial message
  Future<Chat?> startNewChat({
    required String projectId,
    required String title,
    required String initialMessage,
    String? userId,
  }) async {
    try {
      String chatId = DateTime.now().millisecondsSinceEpoch.toString();
      // Create the chat
      final chat = Chat(
        id: chatId,
        title: title,
        projectId: projectId,
        userId: userId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        messages: [],
      );

      // lastMessage: initialMessage.length > 100
      //     ? '${initialMessage.substring(0, 100)}...'
      //     : initialMessage,

      final createdChat = await createChat(
        title: chat.title,
        userId: chat.userId,
        projectId: chat.projectId,
      );

      if (createdChat == null) {
        return null;
      }

      // Add the initial message
      final message = Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: initialMessage,
        isUser: true,
        timestamp: DateTime.now(),
        chatId: chat.id,
      );

      final messageSuccess = await addMessage(chat.id, message);
      if (!messageSuccess) {
        // Clean up the chat if message fails
        await deleteChat(chat.id);
        return null;
      }

      return chat;
    } catch (e) {
      _showError('Failed to start new chat. Please try again.');
      return null;
    }
  }

  /// Update a chat
  Future<bool> updateChat(Chat chat) async {
    final success = await ChatRepository.instance.updateChat(chat);

    if (!success) {
      _showError('Failed to update chat. Please try again.');
      return false;
    }

    return success;
  }

  /// Update a message
  Future<bool> updateMessage(String chatId, Message message) async {
    final success =
        await ChatRepository.instance.updateMessage(chatId, message);

    if (!success) {
      _showError('Failed to update message. Please try again.');
      return false;
    }

    return success;
  }

  /// Watch all chats with real-time updates
  Stream<List<Chat>> watchAllChats() {
    return ChatRepository.instance.listenToAllChats().map((result) {
      final (success, chats) = result;

      if (!success) {
        _showError('Lost connection to chats. Reconnecting...');
        return <Chat>[];
      }

      return chats ?? [];
    });
  }

  /// Watch a specific chat with real-time updates
  Stream<Chat?> watchChat(String chatId) {
    return ChatRepository.instance.listenToChat(chatId).map((result) {
      final (success, chat) = result;

      if (!success) {
        _showError('Lost connection to chat. Reconnecting...');
        return null;
      }

      return chat;
    });
  }

  /// Watch messages for a chat with real-time updates
  Stream<List<Message>> watchChatMessages(String chatId) {
    return ChatRepository.instance.listenToChatMessages(chatId).map((result) {
      final (success, messages) = result;

      if (!success) {
        _showError('Lost connection to messages. Reconnecting...');
        return <Message>[];
      }

      return messages ?? [];
    });
  }

  /// Watch chats for a specific project
  Stream<List<Chat>> watchProjectChats(String projectId) {
    return ChatRepository.instance
        .listenToProjectChats(projectId)
        .map((result) {
      final (success, chats) = result;

      if (!success) {
        _showError('Lost connection to project chats. Reconnecting...');
        return <Chat>[];
      }

      return chats ?? [];
    });
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
