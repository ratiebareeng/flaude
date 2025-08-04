import 'package:claude_chat_clone/core/error/failures.dart';
import 'package:claude_chat_clone/domain/entities/entities.dart';
import 'package:dartz/dartz.dart';

/// Abstract repository interface for Claude API operations
///
/// Defines the contract for Claude AI model interactions that will be implemented
/// by the data layer. Uses Either<Failure, T> for comprehensive error handling.
abstract class ClaudeRepository {
  // ============================================================================
  // MODEL OPERATIONS
  // ============================================================================

  /// Get list of available Claude models
  ///
  /// Returns [Right] with list of available AI models, [Left] with [ClaudeFailure] on error
  Future<Either<Failure, List<AIModel>>> getAvailableModels({
    required String apiKey,
  });

  // ============================================================================
  // MESSAGE OPERATIONS
  // ============================================================================

  /// Send a conversation with message history to Claude
  ///
  /// For multi-turn conversations that require context
  /// Returns [Right] with AI response, [Left] with [ClaudeFailure] on error
  Future<Either<Failure, AIResponse>> sendConversation({
    required String message,
    required List<Message> conversationHistory,
    required String model,
    required String apiKey,
    int? maxTokens,
    double? temperature,
    int? topK,
    double? topP,
    List<String>? stopSequences,
  });

  /// Send a single message to Claude and get response
  ///
  /// For simple one-off requests without conversation context
  /// Returns [Right] with AI response, [Left] with [ClaudeFailure] on error
  Future<Either<Failure, AIResponse>> sendMessage({
    required String message,
    required String model,
    required String apiKey,
    int? maxTokens,
    double? temperature,
    int? topK,
    double? topP,
    List<String>? stopSequences,
    Map<String, dynamic>? metadata,
  });

  // ============================================================================
  // API KEY OPERATIONS
  // ============================================================================

  /// Validate if the provided API key is valid and active
  ///
  /// Tests the API key by making a simple request to Claude
  /// Returns [Right] with boolean result, [Left] with [ClaudeFailure] on error
  Future<Either<Failure, bool>> validateApiKey(String apiKey);
}
