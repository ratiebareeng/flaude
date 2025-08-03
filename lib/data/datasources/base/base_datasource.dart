import 'dart:developer';

import 'package:claude_chat_clone/core/error/exceptions.dart';

/// Base class for all datasources providing common error handling
abstract class BaseDatasource {
  /// Handle async exceptions and convert them to appropriate custom exceptions
  Future<T> handleAsyncException<T>(
    Future<T> Function() operation, {
    required String context,
    String? customMessage,
  }) async {
    try {
      return await operation();
    } catch (e, stackTrace) {
      log('Error in $context: $e', error: e, stackTrace: stackTrace);

      if (customMessage != null) {
        throw _mapException(e, customMessage, context);
      } else {
        throw _mapException(e, 'Operation failed in $context', context);
      }
    }
  }

  /// Handle exceptions and convert them to appropriate custom exceptions
  T handleException<T>(
    T Function() operation, {
    required String context,
    String? customMessage,
  }) {
    try {
      return operation();
    } catch (e, stackTrace) {
      log('Error in $context: $e', error: e, stackTrace: stackTrace);

      if (customMessage != null) {
        throw _mapException(e, customMessage, context);
      } else {
        throw _mapException(e, 'Operation failed in $context', context);
      }
    }
  }

  /// Map generic exceptions to specific custom exceptions
  AppException _mapException(dynamic error, String message, String context) {
    if (error is AppException) {
      return error;
    }

    // Network-related errors
    if (error.toString().contains('SocketException') ||
        error.toString().contains('NetworkException') ||
        error.toString().contains('Connection')) {
      return NetworkException.noInternetConnection();
    }

    // Timeout errors
    if (error.toString().contains('TimeoutException') ||
        error.toString().contains('timeout')) {
      return NetworkException.timeout();
    }

    // Generic exception
    return NetworkException.serverError(
        details: '$message: ${error.toString()}');
  }
}
