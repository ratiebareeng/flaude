import 'package:claude_chat_clone/data/models/data_models.dart';

/// Abstract interface for Claude API operations
abstract class ClaudeRemoteDatasource {
  /// Get available Claude models
  Future<List<String>> getAvailableModels({
    required String apiKey,
  });

  /// Send conversation with message history
  Future<ClaudeApiResponseDTO> sendConversation({
    required String message,
    required List<MessageDTO> conversationHistory,
    required String model,
    required String apiKey,
    int? maxTokens,
    double? temperature,
    int? topK,
    double? topP,
    List<String>? stopSequences,
  });

  /// Send a message to Claude and get response
  Future<ClaudeApiResponseDTO> sendMessage({
    required ClaudeApiRequestDTO request,
    required String apiKey,
  });

  /// Validate API key
  Future<bool> validateApiKey(String apiKey);
}
