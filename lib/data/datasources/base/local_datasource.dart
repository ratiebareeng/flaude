import 'package:claude_chat_clone/data/datasources/base/base_datasource.dart';

/// Base class for local datasources (SharedPreferences, SQLite, etc.)
abstract class LocalDatasource extends BaseDatasource {
  /// Perform local storage operation with error handling
  Future<T> performStorageOperation<T>(
    Future<T> Function() operation, {
    required String context,
    String? customMessage,
  }) async {
    return handleAsyncException(operation,
        context: context, customMessage: customMessage);
  }

  /// Perform synchronous local operation with error handling
  T performSyncStorageOperation<T>(
    T Function() operation, {
    required String context,
    String? customMessage,
  }) {
    return handleException(operation,
        context: context, customMessage: customMessage);
  }
}
