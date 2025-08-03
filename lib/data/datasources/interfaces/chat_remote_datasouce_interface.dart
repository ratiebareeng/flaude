import 'package:claude_chat_clone/data/models/data_models.dart';

/// Abstract interface for chat remote data operations
abstract class ChatRemoteDatasource {
  // Message operations
  Future<void> addMessage(String chatId, MessageDTO message);
  Future<bool> chatExists(String chatId);
  // Chat operations
  Future<String> createChat(ChatDTO chat);
  Future<void> deleteChat(String chatId);
  Future<void> deleteMessage(String chatId, String messageId);
  Future<List<ChatDTO>> getAllChats();
  Future<ChatDTO?> getChat(String chatId);
  // Utility operations
  Future<int> getChatCountForProject(String projectId);

  Future<List<MessageDTO>> getChatMessages(String chatId);
  Future<List<ChatDTO>> getProjectChats(String projectId);
  Future<List<ChatDTO>> getRecentChats({int limit = 10});
  Future<void> updateChat(ChatDTO chat);

  Future<void> updateMessage(String chatId, MessageDTO message);
  // Stream operations
  Stream<List<ChatDTO>> watchAllChats();
  Stream<ChatDTO?> watchChat(String chatId);
  Stream<List<MessageDTO>> watchChatMessages(String chatId);

  Stream<List<ChatDTO>> watchProjectChats(String projectId);
}
