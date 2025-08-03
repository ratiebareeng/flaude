import 'package:claude_chat_clone/core/constants/constants.dart';
import 'package:claude_chat_clone/core/error/exceptions.dart';
import 'package:claude_chat_clone/core/network/api_client.dart';
import 'package:claude_chat_clone/data/datasources/base/remote_datasource.dart';
import 'package:claude_chat_clone/data/datasources/interfaces/claude_remote_datasource_interface.dart';
import 'package:claude_chat_clone/data/models/data_models.dart';

/// Implementation of Claude API datasource
class ClaudeRemoteDatasourceImpl extends RemoteDatasource
    implements ClaudeRemoteDatasource {
  final ApiClient _apiClient;

  ClaudeRemoteDatasourceImpl({
    required ApiClient apiClient,
    required super.networkInfo,
  }) : _apiClient = apiClient;

  @override
  Future<List<String>> getAvailableModels({required String apiKey}) async {
    return performNetworkOperation(
      () async {
        _validateApiKey(apiKey);

        // Configure headers for this request
        _apiClient.configureClaudeHeaders(apiKey);

        try {
          final response = await _apiClient.get<Map<String, dynamic>>(
            '${ApiConstants.claudeBaseUrl}${ApiConstants.claudeModelsEndpoint}',
            timeout: Duration(seconds: ApiConstants.requestTimeoutSeconds),
            fromJson: (json) => json,
          );

          if (!response.isSuccess || response.data == null) {
            throw ClaudeApiException.unknown(reason: 'Failed to fetch models');
          }

          // Extract model IDs from response
          final data = response.data!;
          final models = (data['data'] as List?)
                  ?.map((model) => model['id'] as String)
                  .toList() ??
              [];

          return models;
        } finally {
          _apiClient.clearClaudeHeaders();
        }
      },
      context: 'ClaudeRemoteDatasource.getAvailableModels',
      customMessage: 'Failed to fetch available models',
    );
  }

  @override
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
  }) async {
    return performNetworkOperation(
      () async {
        _validateApiKey(apiKey);
        _validateModel(model);
        _validateMessage(message);

        // Convert conversation history to Claude API format
        final messages =
            conversationHistory.map((msg) => msg.toClaudeApiJson()).toList();

        // Add the new message
        messages.add({
          'role': 'user',
          'content': message,
        });

        final request = ClaudeApiRequestDTO(
          model: model,
          messages: messages,
          maxTokens: maxTokens ?? ApiConstants.defaultMaxTokens,
          temperature: temperature,
          topK: topK,
          topP: topP,
          stopSequences: stopSequences,
        );

        return await sendMessage(request: request, apiKey: apiKey);
      },
      context: 'ClaudeRemoteDatasource.sendConversation',
      customMessage: 'Failed to send conversation to Claude',
    );
  }

  @override
  Future<ClaudeApiResponseDTO> sendMessage({
    required ClaudeApiRequestDTO request,
    required String apiKey,
  }) async {
    return performNetworkOperation(
      () async {
        _validateApiKey(apiKey);
        _validateRequest(request);

        // Configure headers for this request
        _apiClient.configureClaudeHeaders(apiKey);

        try {
          final response = await _apiClient.post<Map<String, dynamic>>(
            '${ApiConstants.claudeBaseUrl}${ApiConstants.claudeMessagesEndpoint}',
            body: request.toJson(),
            timeout: Duration(seconds: ApiConstants.requestTimeoutSeconds),
            fromJson: (json) => json,
          );

          if (!response.isSuccess) {
            _handleApiError(response.statusCode, response.rawData);
          }

          if (response.data == null) {
            throw ClaudeApiException.unknown(
                reason: 'Empty response from Claude API');
          }

          return ClaudeApiResponseDTO.fromJson(response.data!);
        } finally {
          _apiClient.clearClaudeHeaders();
        }
      },
      context: 'ClaudeRemoteDatasource.sendMessage',
      customMessage: 'Failed to send message to Claude',
    );
  }

  @override
  Future<bool> validateApiKey(String apiKey) async {
    return performNetworkOperation(
      () async {
        try {
          _validateApiKey(apiKey);

          // Test the API key by making a simple request
          await getAvailableModels(apiKey: apiKey);
          return true;
        } on ClaudeApiException catch (e) {
          if (e.statusCode == 401) {
            return false;
          }
          rethrow;
        }
      },
      context: 'ClaudeRemoteDatasource.validateApiKey',
      customMessage: 'Failed to validate API key',
    );
  }

  /// Handle Claude API error responses
  void _handleApiError(int statusCode, Map<String, dynamic> response) {
    final error = response['error'] as Map<String, dynamic>?;
    final message = error?['message'] as String? ?? 'Unknown API error';
    final type = error?['type'] as String?;

    switch (statusCode) {
      case 400:
        throw ClaudeApiException.invalidRequest(details: message);
      case 401:
        throw ClaudeApiException.invalidApiKey();
      case 429:
        if (type == 'rate_limit_error') {
          throw ClaudeApiException.rateLimitExceeded();
        } else {
          throw ClaudeApiException.quotaExceeded();
        }
      case 500:
      case 502:
      case 503:
        throw ClaudeApiException.overloaded();
      case 529:
        throw ClaudeApiException.overloaded();
      default:
        throw ClaudeApiException.fromResponse(
          statusCode: statusCode,
          response: response,
        );
    }
  }

  /// Validate API key format
  void _validateApiKey(String apiKey) {
    if (apiKey.isEmpty) {
      throw ConfigurationException.missingApiKey();
    }

    // Basic format validation for Claude API keys
    if (!apiKey.startsWith('sk-ant-api03-')) {
      throw ConfigurationException.invalidApiKey();
    }

    if (apiKey.length < 50) {
      throw ConfigurationException.invalidApiKey();
    }
  }

  /// Validate message content
  void _validateMessage(String message) {
    if (message.trim().isEmpty) {
      throw ValidationException.invalidInput(
        field: 'message',
        reason: 'Message cannot be empty',
      );
    }

    if (message.length > AppConstants.maxMessageLength) {
      throw ValidationException.invalidInput(
        field: 'message',
        reason:
            'Message exceeds maximum length of ${AppConstants.maxMessageLength} characters',
      );
    }
  }

  /// Validate model ID
  void _validateModel(String model) {
    if (model.trim().isEmpty) {
      throw ValidationException.invalidInput(
        field: 'model',
        reason: 'Model cannot be empty',
      );
    }

    // Check if it's a known Claude model
    const validModels = [
      ApiConstants.claudeOpus4ModelId,
      ApiConstants.claudeSonnet4ModelId,
      ApiConstants.claudeSonnet37ModelId,
      ApiConstants.claudeSonnet35ModelId,
      ApiConstants.claudeHaiku35ModelId,
      ApiConstants.claudeOpus3ModelId,
      // Also accept aliases
      ApiConstants.claudeOpus4Alias,
      ApiConstants.claudeSonnet4Alias,
      ApiConstants.claudeSonnet37Alias,
      ApiConstants.claudeSonnet35Alias,
      ApiConstants.claudeHaiku35Alias,
      ApiConstants.claudeOpus3Alias,
    ];

    if (!validModels.contains(model)) {
      throw ValidationException.invalidInput(
        field: 'model',
        reason: 'Unknown or unsupported model: $model',
      );
    }
  }

  /// Validate API request
  void _validateRequest(ClaudeApiRequestDTO request) {
    _validateModel(request.model);

    if (request.messages.isEmpty) {
      throw ValidationException.invalidInput(
        field: 'messages',
        reason: 'Messages cannot be empty',
      );
    }

    if (request.maxTokens <= 0 || request.maxTokens > 200000) {
      throw ValidationException.invalidInput(
        field: 'maxTokens',
        reason: 'Max tokens must be between 1 and 200000',
      );
    }

    if (request.temperature != null &&
        (request.temperature! < 0 || request.temperature! > 1)) {
      throw ValidationException.invalidInput(
        field: 'temperature',
        reason: 'Temperature must be between 0 and 1',
      );
    }

    if (request.topP != null && (request.topP! < 0 || request.topP! > 1)) {
      throw ValidationException.invalidInput(
        field: 'topP',
        reason: 'Top P must be between 0 and 1',
      );
    }

    if (request.topK != null && request.topK! <= 0) {
      throw ValidationException.invalidInput(
        field: 'topK',
        reason: 'Top K must be positive',
      );
    }

    // Validate message structure
    for (final message in request.messages) {
      final role = message['role'] as String?;
      final content = message['content'] as String?;

      if (role == null || !['user', 'assistant'].contains(role)) {
        throw ValidationException.invalidInput(
          field: 'message.role',
          reason: 'Message role must be "user" or "assistant"',
        );
      }

      if (content == null || content.trim().isEmpty) {
        throw ValidationException.invalidInput(
          field: 'message.content',
          reason: 'Message content cannot be empty',
        );
      }
    }
  }
}
