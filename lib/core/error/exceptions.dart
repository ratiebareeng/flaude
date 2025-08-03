/// Base exception class for all custom exceptions in the application
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalException;
  final StackTrace? stackTrace;

  const AppException({
    required this.message,
    this.code,
    this.originalException,
    this.stackTrace,
  });

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.write('$runtimeType: $message');
    if (code != null) buffer.write(' (Code: $code)');
    if (originalException != null) {
      buffer.write('\nCaused by: $originalException');
    }
    return buffer.toString();
  }
}

/// Cache exceptions
class CacheException extends AppException {
  const CacheException({
    required super.message,
    super.code,
    super.originalException,
    super.stackTrace,
  });

  factory CacheException.expired(String key) {
    return CacheException(
      message: 'Cache entry with key "$key" has expired',
      code: 'CACHE_EXPIRED',
    );
  }

  factory CacheException.notFound(String key) {
    return CacheException(
      message: 'Cache entry with key "$key" not found',
      code: 'CACHE_NOT_FOUND',
    );
  }

  factory CacheException.writeFailed({String? reason}) {
    return CacheException(
      message: reason ?? 'Failed to write to cache',
      code: 'CACHE_WRITE_FAILED',
    );
  }
}

/// Chat-related exceptions
class ChatException extends AppException {
  const ChatException({
    required super.message,
    super.code,
    super.originalException,
    super.stackTrace,
  });

  factory ChatException.loadFailed({String? reason}) {
    return ChatException(
      message: reason ?? 'Failed to load chat',
      code: 'LOAD_FAILED',
    );
  }

  factory ChatException.messageEmpty() {
    return const ChatException(
      message: 'Message cannot be empty',
      code: 'EMPTY_MESSAGE',
    );
  }

  factory ChatException.messageTooLong(int maxLength) {
    return ChatException(
      message: 'Message exceeds maximum length of $maxLength characters',
      code: 'MESSAGE_TOO_LONG',
    );
  }

  factory ChatException.notFound(String chatId) {
    return ChatException(
      message: 'Chat with ID "$chatId" not found',
      code: 'CHAT_NOT_FOUND',
    );
  }

  factory ChatException.sendFailed({String? reason}) {
    return ChatException(
      message: reason ?? 'Failed to send message',
      code: 'SEND_FAILED',
    );
  }

  factory ChatException.unknown({String? reason}) {
    if (reason != null) {
      return ChatException(
        message: reason,
        code: 'UNKNOWN_CHAT_ERROR',
      );
    }
    return const ChatException(
      message: 'An unknown chat error occurred',
      code: 'UNKNOWN_CHAT_ERROR',
    );
  }

  factory ChatException.updateFailed({String? reason}) {
    return ChatException(
      message: reason ?? 'Failed to update chat',
      code: 'UPDATE_FAILED',
    );
  }
}

/// Claude API specific exceptions
class ClaudeApiException extends AppException {
  final int? statusCode;
  final Map<String, dynamic>? errorDetails;

  const ClaudeApiException({
    required super.message,
    super.code,
    this.statusCode,
    this.errorDetails,
    super.originalException,
    super.stackTrace,
  });

  factory ClaudeApiException.fromResponse({
    required int statusCode,
    required Map<String, dynamic> response,
  }) {
    final error = response['error'] as Map<String, dynamic>?;
    final message = error?['message'] as String? ?? 'Unknown Claude API error';
    final type = error?['type'] as String?;

    return ClaudeApiException(
      message: message,
      code: type,
      statusCode: statusCode,
      errorDetails: error,
    );
  }

  factory ClaudeApiException.invalidApiKey() {
    return const ClaudeApiException(
      message: 'Invalid API key provided',
      code: 'INVALID_API_KEY',
      statusCode: 401,
    );
  }

  factory ClaudeApiException.invalidRequest({String? details}) {
    return ClaudeApiException(
      message: details ?? 'Invalid request to Claude API',
      code: 'INVALID_REQUEST',
      statusCode: 400,
    );
  }

  factory ClaudeApiException.modelUnavailable(String model) {
    return ClaudeApiException(
      message: 'Model "$model" is currently unavailable',
      code: 'MODEL_UNAVAILABLE',
      statusCode: 503,
    );
  }

  factory ClaudeApiException.overloaded() {
    return const ClaudeApiException(
      message: 'Claude API is currently overloaded',
      code: 'OVERLOADED',
      statusCode: 529,
    );
  }

  factory ClaudeApiException.quotaExceeded() {
    return const ClaudeApiException(
      message: 'API quota exceeded',
      code: 'QUOTA_EXCEEDED',
      statusCode: 429,
    );
  }

  factory ClaudeApiException.rateLimitExceeded() {
    return const ClaudeApiException(
      message: 'Rate limit exceeded. Please wait and try again',
      code: 'RATE_LIMIT_EXCEEDED',
      statusCode: 429,
    );
  }

  // Unknown error handler
  factory ClaudeApiException.unknown({String? reason}) {
    return ClaudeApiException(
      message: reason ?? 'An unknown Claude API error occurred',
      code: 'UNKNOWN_CLAUDE_API_ERROR',
      statusCode: null,
    );
  }
}

/// Configuration exceptions
class ConfigurationException extends AppException {
  const ConfigurationException({
    required super.message,
    super.code,
    super.originalException,
    super.stackTrace,
  });

  factory ConfigurationException.invalidApiKey() {
    return const ConfigurationException(
      message: 'Invalid API key format',
      code: 'INVALID_API_KEY_FORMAT',
    );
  }

  factory ConfigurationException.missingApiKey() {
    return const ConfigurationException(
      message: 'API key not configured. Please set your API key in settings',
      code: 'MISSING_API_KEY',
    );
  }

  factory ConfigurationException.missingConfig(String configName) {
    return ConfigurationException(
      message: 'Missing required configuration: $configName',
      code: 'MISSING_CONFIG',
    );
  }
}

/// Database-related exceptions
class DatabaseException extends AppException {
  const DatabaseException({
    required super.message,
    super.code,
    super.originalException,
    super.stackTrace,
  });

  factory DatabaseException.dataNotFound() {
    return const DatabaseException(
      message: 'Requested data not found',
      code: 'DATA_NOT_FOUND',
    );
  }

  factory DatabaseException.networkError() {
    return const DatabaseException(
      message: 'Firebase network error',
      code: 'NETWORK_ERROR',
    );
  }

  factory DatabaseException.permissionDenied() {
    return const DatabaseException(
      message: 'Permission denied',
      code: 'PERMISSION_DENIED',
    );
  }

  factory DatabaseException.writeError({String? details}) {
    return DatabaseException(
      message: details ?? 'Failed to write data',
      code: 'WRITE_ERROR',
    );
  }
}

/// Network-related exceptions
class NetworkException extends AppException {
  const NetworkException({
    required super.message,
    super.code,
    super.originalException,
    super.stackTrace,
  });

  factory NetworkException.badRequest({String? details}) {
    return NetworkException(
      message: details ?? 'Bad request',
      code: 'BAD_REQUEST',
    );
  }

  factory NetworkException.forbidden() {
    return const NetworkException(
      message: 'Access forbidden',
      code: 'FORBIDDEN',
    );
  }

  factory NetworkException.noInternetConnection() {
    return const NetworkException(
      message: 'No internet connection available',
      code: 'NO_INTERNET',
    );
  }

  factory NetworkException.notFound() {
    return const NetworkException(
      message: 'Resource not found',
      code: 'NOT_FOUND',
    );
  }

  factory NetworkException.serverError({String? details}) {
    return NetworkException(
      message: details ?? 'Server error occurred',
      code: 'SERVER_ERROR',
    );
  }

  factory NetworkException.timeout() {
    return const NetworkException(
      message: 'Request timed out',
      code: 'TIMEOUT',
    );
  }

  factory NetworkException.unauthorized() {
    return const NetworkException(
      message: 'Unauthorized access',
      code: 'UNAUTHORIZED',
    );
  }
}

/// Project-related exceptions
class ProjectException extends AppException {
  const ProjectException({
    required super.message,
    super.code,
    super.originalException,
    super.stackTrace,
  });

  factory ProjectException.createFailed({String? reason}) {
    return ProjectException(
      message: reason ?? 'Failed to create project',
      code: 'CREATE_FAILED',
    );
  }

  factory ProjectException.deleteFailed({String? reason}) {
    return ProjectException(
      message: reason ?? 'Failed to delete project',
      code: 'DELETE_FAILED',
    );
  }

  factory ProjectException.nameAlreadyExists(String name) {
    return ProjectException(
      message: 'Project name "$name" already exists',
      code: 'NAME_ALREADY_EXISTS',
    );
  }

  factory ProjectException.nameEmpty() {
    return const ProjectException(
      message: 'Project name cannot be empty',
      code: 'EMPTY_NAME',
    );
  }

  factory ProjectException.nameTooLong(int maxLength) {
    return ProjectException(
      message: 'Project name exceeds maximum length of $maxLength characters',
      code: 'NAME_TOO_LONG',
    );
  }

  factory ProjectException.notFound(String projectId) {
    return ProjectException(
      message: 'Project with ID "$projectId" not found',
      code: 'PROJECT_NOT_FOUND',
    );
  }

  factory ProjectException.updateFailed({String? reason}) {
    return ProjectException(
      message: reason ?? 'Failed to update project',
      code: 'UPDATE_FAILED',
    );
  }
}

/// File and storage exceptions
class StorageException extends AppException {
  const StorageException({
    required super.message,
    super.code,
    super.originalException,
    super.stackTrace,
  });

  factory StorageException.downloadFailed({String? reason}) {
    return StorageException(
      message: reason ?? 'Failed to download file',
      code: 'DOWNLOAD_FAILED',
    );
  }

  factory StorageException.fileNotFound(String fileName) {
    return StorageException(
      message: 'File "$fileName" not found',
      code: 'FILE_NOT_FOUND',
    );
  }

  factory StorageException.fileTooLarge(int maxSize) {
    return StorageException(
      message:
          'File exceeds maximum size of ${(maxSize / (1024 * 1024)).toStringAsFixed(1)}MB',
      code: 'FILE_TOO_LARGE',
    );
  }

  factory StorageException.unsupportedFormat(String format) {
    return StorageException(
      message: 'File format "$format" is not supported',
      code: 'UNSUPPORTED_FORMAT',
    );
  }

  factory StorageException.uploadFailed({String? reason}) {
    return StorageException(
      message: reason ?? 'Failed to upload file',
      code: 'UPLOAD_FAILED',
    );
  }
}

/// Validation exceptions
class ValidationException extends AppException {
  final Map<String, String>? fieldErrors;

  const ValidationException({
    required super.message,
    super.code,
    this.fieldErrors,
    super.originalException,
    super.stackTrace,
  });

  factory ValidationException.invalidInput({
    required String field,
    required String reason,
  }) {
    return ValidationException(
      message: 'Invalid $field: $reason',
      code: 'INVALID_INPUT',
      fieldErrors: {field: reason},
    );
  }

  factory ValidationException.multipleErrors(Map<String, String> errors) {
    final message = 'Validation failed for: ${errors.keys.join(', ')}';
    return ValidationException(
      message: message,
      code: 'MULTIPLE_VALIDATION_ERRORS',
      fieldErrors: errors,
    );
  }
}
