import 'package:claude_chat_clone/core/error/failures.dart';
import 'package:claude_chat_clone/domain/entities/entities.dart';
import 'package:dartz/dartz.dart';

/// Abstract repository interface for chat-related operations
///
/// Defines the contract for chat data operations that will be implemented
/// by the data layer. Uses Either<Failure, T> for comprehensive error handling.
abstract class ChatRepository {
  // ============================================================================
  // MESSAGE OPERATIONS
  // ============================================================================

  /// Add a message to an existing chat
  ///
  /// Returns [Right] with void on success, [Left] with [ChatFailure] on error
  Future<Either<Failure, void>> addMessage(String chatId, Message message);

  /// Check if a chat exists
  ///
  /// Returns [Right] with boolean result, [Left] with [ChatFailure] on error
  Future<Either<Failure, bool>> chatExists(String chatId);

  /// Create a new chat
  ///
  /// Returns [Right] with the chat ID on success, [Left] with [ChatFailure] on error
  Future<Either<Failure, String>> createChat(Chat chat);

  /// Delete a chat and all its messages
  ///
  /// Returns [Right] with void on success, [Left] with [ChatFailure] on error
  Future<Either<Failure, void>> deleteChat(String chatId);

  /// Delete a specific message from a chat
  ///
  /// Returns [Right] with void on success, [Left] with [ChatFailure] on error
  Future<Either<Failure, void>> deleteMessage(String chatId, String messageId);

  // ============================================================================
  // CHAT CRUD OPERATIONS
  // ============================================================================

  /// Get all chats for the current user
  ///
  /// Returns [Right] with list of chats, [Left] with [ChatFailure] on error
  Future<Either<Failure, List<Chat>>> getAllChats();

  /// Get a specific chat by ID
  ///
  /// Returns [Right] with chat (nullable), [Left] with [ChatFailure] on error
  Future<Either<Failure, Chat?>> getChat(String chatId);

  /// Get number of chats for a specific project
  ///
  /// Returns [Right] with chat count, [Left] with [ChatFailure] on error
  Future<Either<Failure, int>> getChatCountForProject(String projectId);

  /// Get all messages for a specific chat
  ///
  /// Returns [Right] with list of messages, [Left] with [ChatFailure] on error
  Future<Either<Failure, List<Message>>> getChatMessages(String chatId);

  /// Get all chats belonging to a specific project
  ///
  /// Returns [Right] with project chats, [Left] with [ChatFailure] on error
  Future<Either<Failure, List<Chat>>> getProjectChats(String projectId);

  // ============================================================================
  // CHAT QUERY OPERATIONS
  // ============================================================================

  /// Get recent chats with optional limit
  ///
  /// Returns [Right] with list of recent chats, [Left] with [ChatFailure] on error
  Future<Either<Failure, List<Chat>>> getRecentChats({int limit = 10});

  /// Search chats by query string
  ///
  /// Searches through chat titles and descriptions
  /// Returns [Right] with matching chats, [Left] with [ChatFailure] on error
  Future<Either<Failure, List<Chat>>> searchChats(String query);

  /// Update an existing chat
  ///
  /// Returns [Right] with void on success, [Left] with [ChatFailure] on error
  Future<Either<Failure, void>> updateChat(Chat chat);

  // ============================================================================
  // PROJECT-RELATED OPERATIONS
  // ============================================================================

  /// Update an existing message in a chat
  ///
  /// Returns [Right] with void on success, [Left] with [ChatFailure] on error
  Future<Either<Failure, void>> updateMessage(String chatId, Message message);

  /// Watch all chats in real-time
  ///
  /// Returns a stream that emits [Right] with all chats or [Left] with [ChatFailure]
  Stream<Either<Failure, List<Chat>>> watchAllChats();

  /// Watch a specific chat in real-time
  ///
  /// Returns a stream that emits [Right] with chat (nullable) or [Left] with [ChatFailure]
  Stream<Either<Failure, Chat?>> watchChat(String chatId);

  // ============================================================================
  // REAL-TIME OPERATIONS
  // ============================================================================

  /// Watch messages for a specific chat in real-time
  ///
  /// Returns a stream that emits [Right] with messages or [Left] with [ChatFailure]
  Stream<Either<Failure, List<Message>>> watchChatMessages(String chatId);

  /// Watch chats for a specific project in real-time
  ///
  /// Returns a stream that emits [Right] with chats or [Left] with [ChatFailure]
  Stream<Either<Failure, List<Chat>>> watchProjectChats(String projectId);
}
