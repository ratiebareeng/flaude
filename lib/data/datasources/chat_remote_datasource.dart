import 'dart:async';
import 'dart:convert';

import 'package:claude_chat_clone/core/constants/constants.dart';
import 'package:claude_chat_clone/core/error/exceptions.dart';
import 'package:claude_chat_clone/data/datasources/base/remote_datasource.dart';
import 'package:claude_chat_clone/data/datasources/interfaces/chat_remote_datasouce_interface.dart';
import 'package:claude_chat_clone/data/models/data_models.dart';
import 'package:claude_chat_clone/data/services/firebase_rtdb_service.dart';
import 'package:firebase_database/firebase_database.dart';

/// Firebase implementation of chat remote datasource
class ChatRemoteDatasourceImpl extends RemoteDatasource
    implements ChatRemoteDatasource {
  final FirebaseRTDBService _rtdbService;
  final String _chatsPath = ApiConstants.chatsPath;
  final String _messagesPath = ApiConstants.messagesPath;

  ChatRemoteDatasourceImpl({
    required FirebaseRTDBService rtdbService,
    required super.networkInfo,
  }) : _rtdbService = rtdbService;

  @override
  Future<void> addMessage(String chatId, MessageDTO message) async {
    return performNetworkOperation(
      () async {
        if (chatId.isEmpty) {
          throw ChatException.notFound(chatId);
        }

        if (!message.isValid()) {
          throw ChatException.sendFailed(
            reason: 'Invalid message data: ${message.getValidationErrors()}',
          );
        }

        final messagePath = '$_messagesPath/$chatId/${message.id}';
        await _rtdbService.writeData(messagePath, message.toFirebaseJson());

        // Update chat's last message timestamp
        await _updateChatTimestamp(chatId);
      },
      context: 'ChatRemoteDatasource.addMessage',
      customMessage: 'Failed to add message to chat',
    );
  }

  @override
  Future<bool> chatExists(String chatId) async {
    return performNetworkOperation(
      () async {
        if (chatId.isEmpty) return false;

        final path = '$_chatsPath/$chatId';
        final snapshot = await _rtdbService.readPath(path);
        return snapshot.exists && snapshot.value != null;
      },
      context: 'ChatRemoteDatasource.chatExists',
    );
  }

  @override
  Future<String> createChat(ChatDTO chat) async {
    return performNetworkOperation(
      () async {
        if (!chat.isValid()) {
          throw ChatException.loadFailed(
            reason: 'Invalid chat data: ${chat.getValidationErrors()}',
          );
        }

        final chatData = chat.toFirebaseJson();

        if (chat.id.isEmpty) {
          // Generate new ID
          final chatId = await _rtdbService.writeDataWithId(
            _chatsPath,
            'id',
            chatData,
          );
          return chatId;
        } else {
          // Use provided ID
          final path = '$_chatsPath/${chat.id}';
          await _rtdbService.writeData(path, chatData);
          return chat.id;
        }
      },
      context: 'ChatRemoteDatasource.createChat',
      customMessage: 'Failed to create chat',
    );
  }

  @override
  Future<void> deleteChat(String chatId) async {
    return performNetworkOperation(
      () async {
        if (chatId.isEmpty) {
          throw ChatException.notFound(chatId);
        }

        // Delete chat metadata
        final chatPath = '$_chatsPath/$chatId';
        await _rtdbService.deleteData(chatPath);

        // Delete all messages for this chat
        final messagesPath = '$_messagesPath/$chatId';
        await _rtdbService.deleteData(messagesPath);
      },
      context: 'ChatRemoteDatasource.deleteChat',
      customMessage: 'Failed to delete chat',
    );
  }

  @override
  Future<void> deleteMessage(String chatId, String messageId) async {
    return performNetworkOperation(
      () async {
        if (chatId.isEmpty || messageId.isEmpty) {
          throw ChatException.notFound(chatId);
        }

        final messagePath = '$_messagesPath/$chatId/$messageId';
        await _rtdbService.deleteData(messagePath);

        // Update chat timestamp
        await _updateChatTimestamp(chatId);
      },
      context: 'ChatRemoteDatasource.deleteMessage',
      customMessage: 'Failed to delete message',
    );
  }

  @override
  Future<List<ChatDTO>> getAllChats() async {
    return performNetworkOperation(
      () async {
        final snapshot = await _rtdbService.readPath(_chatsPath);

        if (!snapshot.exists || snapshot.value == null) {
          return <ChatDTO>[];
        }

        final data = _parseSnapshotData(snapshot);
        final chats = data.entries
            .map((entry) => ChatDTO.fromFirebaseJson(
                Map<String, dynamic>.from(entry.value)))
            .where((chat) => chat.isValid())
            .toList();

        // Sort by most recent activity
        chats.sort((a, b) {
          final aTime = a.updatedAt ?? a.createdAt;
          final bTime = b.updatedAt ?? b.createdAt;
          return bTime.compareTo(aTime);
        });

        return chats;
      },
      context: 'ChatRemoteDatasource.getAllChats',
      customMessage: 'Failed to load chats',
    );
  }

  @override
  Future<ChatDTO?> getChat(String chatId) async {
    return performNetworkOperation(
      () async {
        if (chatId.isEmpty) {
          throw ChatException.notFound(chatId);
        }

        final path = '$_chatsPath/$chatId';
        final snapshot = await _rtdbService.readPath(path);

        if (!snapshot.exists || snapshot.value == null) {
          return null;
        }

        final data = Map<String, dynamic>.from(snapshot.value as Map);
        final chat = ChatDTO.fromFirebaseJson(data);

        if (!chat.isValid()) {
          throw ChatException.loadFailed(
            reason: 'Invalid chat data: ${chat.getValidationErrors()}',
          );
        }

        return chat;
      },
      context: 'ChatRemoteDatasource.getChat',
      customMessage: 'Failed to load chat',
    );
  }

  @override
  Future<int> getChatCountForProject(String projectId) async {
    return performNetworkOperation(
      () async {
        final snapshot = await _rtdbService.readPath(_chatsPath);

        if (!snapshot.exists || snapshot.value == null) {
          return 0;
        }

        final data = _parseSnapshotData(snapshot);
        return data.entries.where((entry) {
          final chatData = Map<String, dynamic>.from(entry.value);
          return chatData['projectId'] == projectId;
        }).length;
      },
      context: 'ChatRemoteDatasource.getChatCountForProject',
      customMessage: 'Failed to get chat count for project',
    );
  }

  @override
  Future<List<MessageDTO>> getChatMessages(String chatId) async {
    return performNetworkOperation(
      () async {
        if (chatId.isEmpty) {
          throw ChatException.notFound(chatId);
        }

        final path = '$_messagesPath/$chatId';
        final snapshot = await _rtdbService.readPath(path);

        if (!snapshot.exists || snapshot.value == null) {
          return <MessageDTO>[];
        }

        final data = _parseSnapshotData(snapshot);
        final messages = data.entries
            .map((entry) => MessageDTO.fromFirebaseJson(
                Map<String, dynamic>.from(entry.value)))
            .where((message) => message.isValid())
            .toList();

        // Sort by timestamp (oldest first)
        messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));

        return messages;
      },
      context: 'ChatRemoteDatasource.getChatMessages',
      customMessage: 'Failed to load chat messages',
    );
  }

  @override
  Future<List<ChatDTO>> getProjectChats(String projectId) async {
    return performNetworkOperation(
      () async {
        final allChats = await getAllChats();
        return allChats.where((chat) => chat.projectId == projectId).toList();
      },
      context: 'ChatRemoteDatasource.getProjectChats',
      customMessage: 'Failed to load project chats',
    );
  }

  @override
  Future<List<ChatDTO>> getRecentChats({int limit = 10}) async {
    return performNetworkOperation(
      () async {
        final snapshot = await _rtdbService.readPathWithFilter(
          path: _chatsPath,
          filterKey: 'updatedAt',
          desc: true,
          limit: limit,
        );

        if (!snapshot.exists || snapshot.value == null) {
          return <ChatDTO>[];
        }

        final data = _parseSnapshotData(snapshot);
        final chats = data.entries
            .map((entry) => ChatDTO.fromFirebaseJson(
                Map<String, dynamic>.from(entry.value)))
            .where((chat) => chat.isValid())
            .toList();

        // Sort by most recent activity
        chats.sort((a, b) {
          final aTime = a.updatedAt ?? a.createdAt;
          final bTime = b.updatedAt ?? b.createdAt;
          return bTime.compareTo(aTime);
        });

        return chats.take(limit).toList();
      },
      context: 'ChatRemoteDatasource.getRecentChats',
      customMessage: 'Failed to load recent chats',
    );
  }

  @override
  Future<void> updateChat(ChatDTO chat) async {
    return performNetworkOperation(
      () async {
        if (chat.id.isEmpty) {
          throw ChatException.notFound(chat.id);
        }

        if (!chat.isValid()) {
          throw ChatException.updateFailed(
            reason: 'Invalid chat data: ${chat.getValidationErrors()}',
          );
        }

        // Update timestamp
        final updatedChat = chat.copyWith(
          updatedAt: DateTime.now().millisecondsSinceEpoch,
        );

        final path = '$_chatsPath/${chat.id}';
        await _rtdbService.updateData(path, updatedChat.toFirebaseJson());
      },
      context: 'ChatRemoteDatasource.updateChat',
      customMessage: 'Failed to update chat',
    );
  }

  @override
  Future<void> updateMessage(String chatId, MessageDTO message) async {
    return performNetworkOperation(
      () async {
        if (chatId.isEmpty || message.id.isEmpty) {
          throw ChatException.notFound(chatId);
        }

        if (!message.isValid()) {
          throw ChatException.sendFailed(
            reason: 'Invalid message data: ${message.getValidationErrors()}',
          );
        }

        final messagePath = '$_messagesPath/$chatId/${message.id}';
        await _rtdbService.updateData(messagePath, message.toFirebaseJson());

        // Update chat timestamp
        await _updateChatTimestamp(chatId);
      },
      context: 'ChatRemoteDatasource.updateMessage',
      customMessage: 'Failed to update message',
    );
  }

  @override
  Stream<List<ChatDTO>> watchAllChats() {
    return _rtdbService.listenToPath(_chatsPath).map((event) {
      return handleException(
        () {
          if (!event.snapshot.exists || event.snapshot.value == null) {
            return <ChatDTO>[];
          }

          final data = _parseSnapshotData(event.snapshot);
          final chats = data.entries
              .map((entry) => ChatDTO.fromFirebaseJson(
                  Map<String, dynamic>.from(entry.value)))
              .where((chat) => chat.isValid())
              .toList();

          // Sort by most recent activity
          chats.sort((a, b) {
            final aTime = a.updatedAt ?? a.createdAt;
            final bTime = b.updatedAt ?? b.createdAt;
            return bTime.compareTo(aTime);
          });

          return chats;
        },
        context: 'ChatRemoteDatasource.watchAllChats',
      );
    });
  }

  @override
  Stream<ChatDTO?> watchChat(String chatId) {
    if (chatId.isEmpty) {
      return Stream.value(null);
    }

    final path = '$_chatsPath/$chatId';
    return _rtdbService.listenToPath(path).map((event) {
      return handleException(
        () {
          if (!event.snapshot.exists || event.snapshot.value == null) {
            return null;
          }

          final data = Map<String, dynamic>.from(
              jsonDecode(jsonEncode(event.snapshot.value)) as Map);
          final chat = ChatDTO.fromFirebaseJson(data);

          return chat.isValid() ? chat : null;
        },
        context: 'ChatRemoteDatasource.watchChat',
      );
    });
  }

  @override
  Stream<List<MessageDTO>> watchChatMessages(String chatId) {
    if (chatId.isEmpty) {
      return Stream.value(<MessageDTO>[]);
    }

    final path = '$_messagesPath/$chatId';
    return _rtdbService.listenToPath(path).map((event) {
      return handleException(
        () {
          if (!event.snapshot.exists || event.snapshot.value == null) {
            return <MessageDTO>[];
          }

          final data = _parseSnapshotData(event.snapshot);
          final messages = data.entries
              .map((entry) => MessageDTO.fromFirebaseJson(
                  Map<String, dynamic>.from(entry.value)))
              .where((message) => message.isValid())
              .toList();

          // Sort by timestamp (oldest first)
          messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));

          return messages;
        },
        context: 'ChatRemoteDatasource.watchChatMessages',
      );
    });
  }

  @override
  Stream<List<ChatDTO>> watchProjectChats(String projectId) {
    return watchAllChats().map((chats) {
      return chats.where((chat) => chat.projectId == projectId).toList();
    });
  }

  /// Helper method to parse Firebase snapshot data
  Map<String, dynamic> _parseSnapshotData(DataSnapshot snapshot) {
    try {
      return Map<String, dynamic>.from(
          jsonDecode(jsonEncode(snapshot.value)) as Map);
    } catch (e) {
      throw DatabaseException.dataNotFound();
    }
  }

  /// Helper method to update chat timestamp
  Future<void> _updateChatTimestamp(String chatId) async {
    try {
      final chatPath = '$_chatsPath/$chatId';
      final snapshot = await _rtdbService.readPath(chatPath);

      if (snapshot.exists && snapshot.value != null) {
        await _rtdbService.updateData(chatPath, {
          'updatedAt': DateTime.now().millisecondsSinceEpoch,
        });
      }
    } catch (e) {
      // Don't throw error for timestamp update failures
      // as they're not critical to core functionality
    }
  }
}
