import 'dart:convert';
import 'dart:developer';

import 'package:claude_chat_clone/models/models.dart';
import 'package:claude_chat_clone/services/services.dart';
import 'package:firebase_core/firebase_core.dart';

class ChatRepository {
  static final ChatRepository _instance = ChatRepository._internal();

  static ChatRepository get instance => _instance;

  final String _chatsPath = 'chats';
  final String _messagesPath = 'messages';

  factory ChatRepository() => _instance;

  ChatRepository._internal();

  /// Add a message to a chat
  Future<bool> addMessage(String chatId, Message message) async {
    try {
      final messagePath = '$_messagesPath/$chatId/${message.id}';
      await FirebaseRTDBService.instance
          .writeData(messagePath, message.toJson());

      // Update chat's last message and timestamp
      final chatPath = '$_chatsPath/$chatId';
      final chatSnapshot =
          await FirebaseRTDBService.instance.readPath(chatPath);

      if (chatSnapshot.exists && chatSnapshot.value != null) {
        final chatData = Map<String, dynamic>.from(chatSnapshot.value as Map);
        final chat = Chat.fromJson(chatData);

        final updatedChat = chat.addMessage(message);

        await FirebaseRTDBService.instance
            .updateData(chatPath, updatedChat.toJson());
      }

      return true;
    } on FirebaseException catch (e) {
      log('Firebase error adding message to chat $chatId: ${e.message}');
      return false;
    } catch (e) {
      log('Unexpected error adding message to chat $chatId: $e');
      return false;
    }
  }

  /// Create a new chat
  Future<bool> createChat(Chat chat) async {
    try {
      final path = '$_chatsPath/${chat.id}';
      await FirebaseRTDBService.instance.writeData(path, chat.toJson());
      return true;
    } on FirebaseException catch (e) {
      log('Firebase error creating chat ${chat.id}: ${e.message}');
      return false;
    } catch (e) {
      log('Unexpected error creating chat ${chat.id}: $e');
      return false;
    }
  }

  /// Delete a chat and all its messages
  Future<bool> deleteChat(String chatId) async {
    try {
      // Delete chat metadata
      final chatPath = '$_chatsPath/$chatId';
      await FirebaseRTDBService.instance.deleteData(chatPath);

      // Delete all messages for this chat
      final messagesPath = '$_messagesPath/$chatId';
      await FirebaseRTDBService.instance.deleteData(messagesPath);

      return true;
    } on FirebaseException catch (e) {
      log('Firebase error deleting chat $chatId: ${e.message}');
      return false;
    } catch (e) {
      log('Unexpected error deleting chat $chatId: $e');
      return false;
    }
  }

  /// Delete a message from a chat
  Future<bool> deleteMessage(String chatId, String messageId) async {
    try {
      final messagePath = '$_messagesPath/$chatId/$messageId';
      await FirebaseRTDBService.instance.deleteData(messagePath);
      return true;
    } on FirebaseException catch (e) {
      log('Firebase error deleting message $messageId from chat $chatId: ${e.message}');
      return false;
    } catch (e) {
      log('Unexpected error deleting message $messageId from chat $chatId: $e');
      return false;
    }
  }

  /// Get chat count for a project
  Future<(bool, int)> getChatCountForProject(String projectId) async {
    try {
      final snapshot = await FirebaseRTDBService.instance.readPath(_chatsPath);

      if (!snapshot.exists || snapshot.value == null) {
        return (true, 0);
      }

      final data = Map<String, dynamic>.from(
          jsonDecode(jsonEncode(snapshot.value)) as Map);

      final chatsForProject = data.entries.where((entry) {
        final chatData = Map<String, dynamic>.from(entry.value);
        return chatData['projectId'] == projectId;
      }).length;

      return (true, chatsForProject);
    } on FirebaseException catch (e) {
      log('Firebase error getting chat count for project $projectId: ${e.message}');
      return (false, 0);
    } catch (e) {
      log('Unexpected error getting chat count for project $projectId: $e');
      return (false, 0);
    }
  }

  /// Listen to all chats changes
  Stream<(bool, List<Chat>?)> listenToAllChats() {
    return FirebaseRTDBService.instance.listenToPath(_chatsPath).map((event) {
      try {
        if (!event.snapshot.exists || event.snapshot.value == null) {
          return (true, <Chat>[]);
        }
        final data = Map<String, dynamic>.from(
            jsonDecode(jsonEncode(event.snapshot.value)) as Map);
        final chats = data.entries
            .map((entry) =>
                Chat.fromJson(Map<String, dynamic>.from(entry.value)))
            .toList();

        // Sort chats by last activity (most recent first)
        chats.sort((a, b) {
          final aDate = a.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          final bDate = b.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          return bDate.compareTo(aDate);
        });

        return (true, chats);
      } on FirebaseException catch (e) {
        log('Firebase error listening to all chats: ${e.message}');
        return (false, null);
      } catch (e) {
        log('Unexpected error listening to all chats: $e');
        return (false, null);
      }
    });
  }

  /// Listen to a single chat changes
  Stream<(bool, Chat?)> listenToChat(String chatId) {
    final path = '$_chatsPath/$chatId';
    return FirebaseRTDBService.instance.listenToPath(path).map((event) {
      try {
        if (!event.snapshot.exists || event.snapshot.value == null) {
          return (true, null);
        }
        final data = Map<String, dynamic>.from(
            jsonDecode(jsonEncode(event.snapshot.value)) as Map);
        final chat = Chat.fromJson(data);
        return (true, chat);
      } on FirebaseException catch (e) {
        log('Firebase error listening to chat $chatId: ${e.message}');
        return (false, null);
      } catch (e) {
        log('Unexpected error listening to chat $chatId: $e');
        return (false, null);
      }
    });
  }

  /// Listen to messages for a specific chat
  Stream<(bool, List<Message>?)> listenToChatMessages(String chatId) {
    final path = '$_messagesPath/$chatId';
    return FirebaseRTDBService.instance.listenToPath(path).map((event) {
      try {
        if (!event.snapshot.exists || event.snapshot.value == null) {
          return (true, <Message>[]);
        }
        final data = Map<String, dynamic>.from(
            jsonDecode(jsonEncode(event.snapshot.value)) as Map);
        final messages = data.entries
            .map((entry) =>
                Message.fromJson(Map<String, dynamic>.from(entry.value)))
            .toList();

        // Sort messages by timestamp (oldest first)
        messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));

        return (true, messages);
      } on FirebaseException catch (e) {
        log('Firebase error listening to messages for chat $chatId: ${e.message}');
        return (false, null);
      } catch (e) {
        log('Unexpected error listening to messages for chat $chatId: $e');
        return (false, null);
      }
    });
  }

  /// Get chats for a specific project
  Stream<(bool, List<Chat>?)> listenToProjectChats(String projectId) {
    return FirebaseRTDBService.instance.listenToPath(_chatsPath).map((event) {
      try {
        if (!event.snapshot.exists || event.snapshot.value == null) {
          return (true, <Chat>[]);
        }
        final data = Map<String, dynamic>.from(
            jsonDecode(jsonEncode(event.snapshot.value)) as Map);
        final chats = data.entries
            .where((entry) {
              final chatData = Map<String, dynamic>.from(entry.value);
              return chatData['projectId'] == projectId;
            })
            .map((entry) =>
                Chat.fromJson(Map<String, dynamic>.from(entry.value)))
            .toList();

        // Sort chats by last activity (most recent first)
        chats.sort((a, b) {
          final aDate = a.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          final bDate = b.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          return bDate.compareTo(aDate);
        });

        return (true, chats);
      } on FirebaseException catch (e) {
        log('Firebase error listening to chats for project $projectId: ${e.message}');
        return (false, null);
      } catch (e) {
        log('Unexpected error listening to chats for project $projectId: $e');
        return (false, null);
      }
    });
  }

  /// Read all chats
  Future<(bool, List<Chat>?)> readAllChats() async {
    try {
      final snapshot = await FirebaseRTDBService.instance.readPath(_chatsPath);

      if (!snapshot.exists || snapshot.value == null) {
        return (true, <Chat>[]);
      }
      final data = Map<String, dynamic>.from(
          jsonDecode(jsonEncode(snapshot.value)) as Map);
      final chats = data.entries
          .map((entry) => Chat.fromJson(Map<String, dynamic>.from(entry.value)))
          .toList();

      // Sort chats by last activity (most recent first)
      chats.sort((a, b) {
        final aDate = a.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bDate = b.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bDate.compareTo(aDate);
      });

      return (true, chats);
    } on FirebaseException catch (e) {
      log('Firebase error reading all chats: ${e.message}');
      return (false, null);
    } catch (e) {
      log('Unexpected error reading all chats: $e');
      return (false, null);
    }
  }

  /// Read a single chat
  Future<(bool, Chat?)> readChat(String chatId) async {
    try {
      final path = '$_chatsPath/$chatId';
      final snapshot = await FirebaseRTDBService.instance.readPath(path);

      if (!snapshot.exists || snapshot.value == null) {
        return (true, null);
      }
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      final chat = Chat.fromJson(data);
      return (true, chat);
    } on FirebaseException catch (e) {
      log('Firebase error reading chat $chatId: ${e.message}');
      return (false, null);
    } catch (e) {
      log('Unexpected error reading chat $chatId: $e');
      return (false, null);
    }
  }

  /// Read messages for a specific chat
  Future<(bool, List<Message>?)> readChatMessages(String chatId) async {
    try {
      final path = '$_messagesPath/$chatId';
      final snapshot = await FirebaseRTDBService.instance.readPath(path);

      if (!snapshot.exists || snapshot.value == null) {
        return (true, <Message>[]);
      }
      final data = Map<String, dynamic>.from(
          jsonDecode(jsonEncode(snapshot.value)) as Map);
      final messages = data.entries
          .map((entry) =>
              Message.fromJson(Map<String, dynamic>.from(entry.value)))
          .toList();

      // Sort messages by timestamp (oldest first)
      messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));

      return (true, messages);
    } on FirebaseException catch (e) {
      log('Firebase error reading messages for chat $chatId: ${e.message}');
      return (false, null);
    } catch (e) {
      log('Unexpected error reading messages for chat $chatId: $e');
      return (false, null);
    }
  }

  /// Update an existing chat
  Future<bool> updateChat(Chat chat) async {
    try {
      final updatedChat = chat.copyWith(updatedAt: DateTime.now());
      final path = '$_chatsPath/${chat.id}';
      await FirebaseRTDBService.instance.updateData(path, updatedChat.toJson());
      return true;
    } on FirebaseException catch (e) {
      log('Firebase error updating chat ${chat.id}: ${e.message}');
      return false;
    } catch (e) {
      log('Unexpected error updating chat ${chat.id}: $e');
      return false;
    }
  }

  /// Update a message
  Future<bool> updateMessage(String chatId, Message message) async {
    try {
      final messagePath = '$_messagesPath/$chatId/${message.id}';
      await FirebaseRTDBService.instance
          .updateData(messagePath, message.toJson());
      return true;
    } on FirebaseException catch (e) {
      log('Firebase error updating message ${message.id}: ${e.message}');
      return false;
    } catch (e) {
      log('Unexpected error updating message ${message.id}: $e');
      return false;
    }
  }
}
