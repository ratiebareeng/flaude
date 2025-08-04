import 'package:equatable/equatable.dart';

/// User authentication and authorization failures
class AuthFailure extends Failure {
  const AuthFailure({
    required super.message,
    super.code,
    super.details,
  });

  factory AuthFailure.invalidCredentials() {
    return const AuthFailure(
      message: 'Invalid credentials provided',
      code: 'INVALID_CREDENTIALS',
    );
  }

  factory AuthFailure.notAuthenticated() {
    return const AuthFailure(
      message: 'User is not authenticated',
      code: 'NOT_AUTHENTICATED',
    );
  }

  factory AuthFailure.notAuthorized([String? resource]) {
    return AuthFailure(
      message: resource != null
          ? 'Not authorized to access $resource'
          : 'Not authorized to perform this action',
      code: 'NOT_AUTHORIZED',
      details: resource != null ? {'resource': resource} : null,
    );
  }

  factory AuthFailure.sessionExpired() {
    return const AuthFailure(
      message: 'Session has expired. Please log in again',
      code: 'SESSION_EXPIRED',
    );
  }
}

/// Cache-related failures
class CacheFailure extends Failure {
  const CacheFailure({
    required super.message,
    super.code,
    super.details,
  });

  factory CacheFailure.expired(String key) {
    return CacheFailure(
      message: 'Cache entry has expired',
      code: 'EXPIRED',
      details: {'key': key},
    );
  }

  factory CacheFailure.notFound(String key) {
    return CacheFailure(
      message: 'Cache entry not found',
      code: 'NOT_FOUND',
      details: {'key': key},
    );
  }

  factory CacheFailure.readFailed([String? reason]) {
    return CacheFailure(
      message: reason ?? 'Failed to read from cache',
      code: 'READ_FAILED',
    );
  }

  factory CacheFailure.writeFailed([String? reason]) {
    return CacheFailure(
      message: reason ?? 'Failed to write to cache',
      code: 'WRITE_FAILED',
    );
  }
}

/// Chat-related failures
class ChatFailure extends Failure {
  const ChatFailure({
    required super.message,
    super.code,
    super.details,
  });

  factory ChatFailure.deleteFailed([String? reason]) {
    return ChatFailure(
      message: reason ?? 'Failed to delete chat',
      code: 'DELETE_FAILED',
    );
  }

  factory ChatFailure.emptyMessage() {
    return const ChatFailure(
      message: 'Message cannot be empty',
      code: 'EMPTY_MESSAGE',
    );
  }

  factory ChatFailure.loadFailed([String? reason]) {
    return ChatFailure(
      message: reason ?? 'Failed to load chat',
      code: 'LOAD_FAILED',
    );
  }

  factory ChatFailure.messageTooLong(int maxLength) {
    return ChatFailure(
      message: 'Message is too long. Maximum length is $maxLength characters',
      code: 'MESSAGE_TOO_LONG',
      details: {'maxLength': maxLength},
    );
  }

  factory ChatFailure.notFound(String chatId) {
    return ChatFailure(
      message: 'Chat not found',
      code: 'CHAT_NOT_FOUND',
      details: {'chatId': chatId},
    );
  }

  factory ChatFailure.sendFailed([String? reason]) {
    return ChatFailure(
      message: reason ?? 'Failed to send message',
      code: 'SEND_FAILED',
    );
  }

  factory ChatFailure.updateFailed([String? reason]) {
    return ChatFailure(
      message: reason ?? 'Failed to update chat',
      code: 'UPDATE_FAILED',
    );
  }
}

/// Claude API specific failures
class ClaudeFailure extends Failure {
  const ClaudeFailure({
    required super.message,
    super.code,
    super.details,
  });

  factory ClaudeFailure.invalidApiKey() {
    return const ClaudeFailure(
      message:
          'Invalid or missing API key. Please check your API key in settings',
      code: 'INVALID_API_KEY',
    );
  }

  factory ClaudeFailure.modelUnavailable(String modelName) {
    return ClaudeFailure(
      message:
          'Model "$modelName" is currently unavailable. Please try another model',
      code: 'MODEL_UNAVAILABLE',
      details: {'model': modelName},
    );
  }

  factory ClaudeFailure.overloaded() {
    return const ClaudeFailure(
      message: 'Claude API is currently overloaded. Please try again later',
      code: 'OVERLOADED',
    );
  }

  factory ClaudeFailure.quotaExceeded() {
    return const ClaudeFailure(
      message: 'API quota exceeded. Please check your billing information',
      code: 'QUOTA_EXCEEDED',
    );
  }

  factory ClaudeFailure.rateLimitExceeded() {
    return const ClaudeFailure(
      message:
          'Rate limit exceeded. Please wait before sending another message',
      code: 'RATE_LIMIT_EXCEEDED',
    );
  }

  factory ClaudeFailure.requestTooLarge() {
    return const ClaudeFailure(
      message: 'Request is too large. Please reduce the message length',
      code: 'REQUEST_TOO_LARGE',
    );
  }

  factory ClaudeFailure.unknown([String? details]) {
    return ClaudeFailure(
      message: details ??
          'An unknown error occurred while communicating with Claude',
      code: 'UNKNOWN_ERROR',
    );
  }
}

/// Configuration-related failures
class ConfigurationFailure extends Failure {
  const ConfigurationFailure({
    required super.message,
    super.code,
    super.details,
  });

  factory ConfigurationFailure.invalidApiKey() {
    return const ConfigurationFailure(
      message: 'API key format is invalid',
      code: 'INVALID_API_KEY',
    );
  }

  factory ConfigurationFailure.invalidConfig({
    required String configName,
    required String reason,
  }) {
    return ConfigurationFailure(
      message: 'Invalid configuration for "$configName": $reason',
      code: 'INVALID_CONFIG',
      details: {'configName': configName, 'reason': reason},
    );
  }

  factory ConfigurationFailure.missingApiKey() {
    return const ConfigurationFailure(
      message: 'API key is not configured. Please set your API key in settings',
      code: 'MISSING_API_KEY',
    );
  }

  factory ConfigurationFailure.missingConfig(String configName) {
    return ConfigurationFailure(
      message: 'Required configuration "$configName" is missing',
      code: 'MISSING_CONFIG',
      details: {'configName': configName},
    );
  }
}

/// Database and storage failures
class DatabaseFailure extends Failure {
  const DatabaseFailure({
    required super.message,
    super.code,
    super.details,
  });

  factory DatabaseFailure.connectionError() {
    return const DatabaseFailure(
      message: 'Failed to connect to database',
      code: 'CONNECTION_ERROR',
    );
  }

  factory DatabaseFailure.deleteError([String? details]) {
    return DatabaseFailure(
      message: details ?? 'Failed to delete data from database',
      code: 'DELETE_ERROR',
    );
  }

  factory DatabaseFailure.notFound(String resourceType, String id) {
    return DatabaseFailure(
      message: '$resourceType with ID "$id" not found',
      code: 'NOT_FOUND',
      details: {'resourceType': resourceType, 'id': id},
    );
  }

  factory DatabaseFailure.permissionDenied() {
    return const DatabaseFailure(
      message: 'Permission denied. Please check your access rights',
      code: 'PERMISSION_DENIED',
    );
  }

  factory DatabaseFailure.readError([String? details]) {
    return DatabaseFailure(
      message: details ?? 'Failed to read data from database',
      code: 'READ_ERROR',
    );
  }

  factory DatabaseFailure.unknown([String? details]) {
    return DatabaseFailure(
      message: details ?? 'An unknown database error occurred',
      code: 'UNKNOWN_ERROR',
    );
  }

  factory DatabaseFailure.writeError([String? details]) {
    return DatabaseFailure(
      message: details ?? 'Failed to write data to database',
      code: 'WRITE_ERROR',
    );
  }
}

/// Abstract base class for all failures in the application
///
/// Failures represent errors that can occur in the domain layer
/// and are used to communicate errors between layers in clean architecture
abstract class Failure extends Equatable {
  final String message;
  final String? code;
  final Map<String, dynamic>? details;

  const Failure({
    required this.message,
    this.code,
    this.details,
  });

  @override
  List<Object?> get props => [message, code, details];

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.write('$runtimeType: $message');
    if (code != null) buffer.write(' (Code: $code)');
    return buffer.toString();
  }
}

/// Network-related failures
class NetworkFailure extends Failure {
  const NetworkFailure({
    required super.message,
    super.code,
    super.details,
  });

  factory NetworkFailure.badRequest([String? details]) {
    return NetworkFailure(
      message: details ?? 'Invalid request',
      code: 'BAD_REQUEST',
    );
  }

  factory NetworkFailure.noConnection() {
    return const NetworkFailure(
      message: 'No internet connection available',
      code: 'NO_CONNECTION',
    );
  }

  factory NetworkFailure.notFound([String? resource]) {
    return NetworkFailure(
      message: resource != null ? '$resource not found' : 'Resource not found',
      code: 'NOT_FOUND',
    );
  }

  factory NetworkFailure.serverError([String? details]) {
    return NetworkFailure(
      message: details ?? 'Server error occurred',
      code: 'SERVER_ERROR',
    );
  }

  factory NetworkFailure.timeout() {
    return const NetworkFailure(
      message: 'Network request timed out',
      code: 'TIMEOUT',
    );
  }

  factory NetworkFailure.unauthorized() {
    return const NetworkFailure(
      message: 'Unauthorized access',
      code: 'UNAUTHORIZED',
    );
  }
}

/// Project-related failures
class ProjectFailure extends Failure {
  const ProjectFailure({
    required super.message,
    super.code,
    super.details,
  });

  factory ProjectFailure.createFailed([String? reason]) {
    return ProjectFailure(
      message: reason ?? 'Failed to create project',
      code: 'CREATE_FAILED',
    );
  }

  factory ProjectFailure.deleteFailed([String? reason]) {
    return ProjectFailure(
      message: reason ?? 'Failed to delete project',
      code: 'DELETE_FAILED',
    );
  }

  factory ProjectFailure.hasChats() {
    return const ProjectFailure(
      message: 'Cannot delete project that contains chats',
      code: 'HAS_CHATS',
    );
  }

  factory ProjectFailure.invalidName([String? reason]) {
    return ProjectFailure(
      message: reason ?? 'Invalid project name',
      code: 'INVALID_NAME',
    );
  }

  factory ProjectFailure.nameAlreadyExists(String name) {
    return ProjectFailure(
      message: 'A project with this name already exists',
      code: 'NAME_EXISTS',
      details: {'name': name},
    );
  }

  factory ProjectFailure.notFound(String projectId) {
    return ProjectFailure(
      message: 'Project not found',
      code: 'PROJECT_NOT_FOUND',
      details: {'projectId': projectId},
    );
  }

  factory ProjectFailure.updateFailed([String? reason]) {
    return ProjectFailure(
      message: reason ?? 'Failed to update project',
      code: 'UPDATE_FAILED',
    );
  }
}

/// File and storage failures
class StorageFailure extends Failure {
  const StorageFailure({
    required super.message,
    super.code,
    super.details,
  });

  factory StorageFailure.deleteFailed([String? reason]) {
    return StorageFailure(
      message: reason ?? 'Failed to delete file',
      code: 'DELETE_FAILED',
    );
  }

  factory StorageFailure.downloadFailed([String? reason]) {
    return StorageFailure(
      message: reason ?? 'Failed to download file',
      code: 'DOWNLOAD_FAILED',
    );
  }

  factory StorageFailure.fileNotFound(String fileName) {
    return StorageFailure(
      message: 'File not found',
      code: 'FILE_NOT_FOUND',
      details: {'fileName': fileName},
    );
  }

  factory StorageFailure.fileTooLarge(int maxSizeBytes) {
    final maxSizeMB = (maxSizeBytes / (1024 * 1024)).toStringAsFixed(1);
    return StorageFailure(
      message: 'File is too large. Maximum size is ${maxSizeMB}MB',
      code: 'FILE_TOO_LARGE',
      details: {'maxSizeBytes': maxSizeBytes},
    );
  }

  factory StorageFailure.insufficientStorage() {
    return const StorageFailure(
      message: 'Insufficient storage space available',
      code: 'INSUFFICIENT_STORAGE',
    );
  }

  factory StorageFailure.unsupportedFormat(String format) {
    return StorageFailure(
      message: 'File format "$format" is not supported',
      code: 'UNSUPPORTED_FORMAT',
      details: {'format': format},
    );
  }

  factory StorageFailure.uploadFailed([String? reason]) {
    return StorageFailure(
      message: reason ?? 'Failed to upload file',
      code: 'UPLOAD_FAILED',
    );
  }
}

/// Unknown or generic failures
class UnknownFailure extends Failure {
  const UnknownFailure({
    required super.message,
    super.code,
    super.details,
  });

  factory UnknownFailure.withDetails([String? details]) {
    return UnknownFailure(
      message: details ?? 'An unknown error occurred',
      code: 'UNKNOWN_ERROR',
    );
  }
}

/// Validation failures
class ValidationFailure extends Failure {
  final Map<String, String>? fieldErrors;

  const ValidationFailure({
    required super.message,
    super.code,
    super.details,
    this.fieldErrors,
  });

  factory ValidationFailure.invalidInput({
    required String field,
    required String reason,
  }) {
    return ValidationFailure(
      message: 'Invalid $field: $reason',
      code: 'INVALID_INPUT',
      details: {'field': field, 'reason': reason},
      fieldErrors: {field: reason},
    );
  }

  factory ValidationFailure.multipleErrors(Map<String, String> errors) {
    final fields = errors.keys.join(', ');
    return ValidationFailure(
      message: 'Validation failed for: $fields',
      code: 'MULTIPLE_ERRORS',
      details: {'errors': errors},
      fieldErrors: errors,
    );
  }

  factory ValidationFailure.required(String field) {
    return ValidationFailure(
      message: '$field is required',
      code: 'REQUIRED_FIELD',
      details: {'field': field},
      fieldErrors: {field: 'This field is required'},
    );
  }

  factory ValidationFailure.tooLong({
    required String field,
    required int maxLength,
  }) {
    return ValidationFailure(
      message: '$field must not exceed $maxLength characters',
      code: 'TOO_LONG',
      details: {'field': field, 'maxLength': maxLength},
      fieldErrors: {field: 'Must not exceed $maxLength characters'},
    );
  }

  factory ValidationFailure.tooShort({
    required String field,
    required int minLength,
  }) {
    return ValidationFailure(
      message: '$field must be at least $minLength characters',
      code: 'TOO_SHORT',
      details: {'field': field, 'minLength': minLength},
      fieldErrors: {field: 'Must be at least $minLength characters'},
    );
  }

  @override
  List<Object?> get props => [...super.props, fieldErrors];
}
