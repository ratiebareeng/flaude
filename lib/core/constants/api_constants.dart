/// API-related constants for external service integrations
class ApiConstants {
  // Claude API Configuration
  static const String claudeBaseUrl = 'https://api.anthropic.com';

  static const String claudeMessagesEndpoint = '/v1/messages';
  static const String claudeModelsEndpoint = '/v1/models';
  static const String claudeAnthropicVersion = '2023-06-01';
  // API Headers
  static const String contentTypeHeader = 'Content-Type';

  static const String apiKeyHeader = 'x-api-key';
  static const String anthropicVersionHeader = 'anthropic-version';
  static const String applicationJsonContentType = 'application/json';
  // Request Configuration
  static const int defaultMaxTokens = 4096;

  static const int requestTimeoutSeconds = 30;
  static const int connectionTimeoutSeconds = 10;
  static const int receiveTimeoutSeconds = 30;
  // Rate Limiting
  static const int maxRequestsPerMinute = 60;

  static const int maxConcurrentRequests = 5;
  // Retry Configuration
  static const int maxRetryAttempts = 3;

  static const int retryDelaySeconds = 2;
  // Claude Model IDs (Latest versions as of implementation)
  static const String claudeOpus4ModelId = 'claude-opus-4-20250514';

  static const String claudeSonnet4ModelId = 'claude-sonnet-4-20250514';
  static const String claudeSonnet37ModelId = 'claude-3-7-sonnet-20250219';
  static const String claudeSonnet35ModelId = 'claude-3-5-sonnet-20241022';
  static const String claudeHaiku35ModelId = 'claude-3-5-haiku-20241022';
  static const String claudeOpus3ModelId = 'claude-3-opus-20240229';
  // Model Aliases
  static const String claudeOpus4Alias = 'claude-opus-4-0';

  static const String claudeSonnet4Alias = 'claude-sonnet-4-0';
  static const String claudeSonnet37Alias = 'claude-3-7-sonnet-latest';
  static const String claudeSonnet35Alias = 'claude-3-5-sonnet-latest';
  static const String claudeHaiku35Alias = 'claude-3-5-haiku-latest';
  static const String claudeOpus3Alias = 'claude-3-opus-latest';
  // Default Model
  static const String defaultModelId = claudeSonnet4ModelId;

  // Error Messages
  static const String apiKeyNotSetError =
      'API key not set. Please configure your API key in settings.';

  static const String networkErrorMessage =
      'Network error occurred. Please check your connection.';
  static const String timeoutErrorMessage =
      'Request timed out. Please try again.';
  static const String serverErrorMessage =
      'Server error occurred. Please try again later.';
  static const String rateLimitErrorMessage =
      'Rate limit exceeded. Please wait and try again.';
  // Firebase Database Paths
  static const String chatsPath = 'chats';

  static const String messagesPath = 'messages';
  static const String projectsPath = 'projects';
  static const String usersPath = 'users';
  // Storage Paths
  static const String attachmentsPath = 'attachments';

  static const String artifactsPath = 'artifacts';
  static const String userDataPath = 'user_data';
  // Prevent instantiation
  ApiConstants._();
}
