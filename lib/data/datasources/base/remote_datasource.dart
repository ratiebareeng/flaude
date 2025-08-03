import 'package:claude_chat_clone/core/error/exceptions.dart';
import 'package:claude_chat_clone/core/network/network_info.dart';
import 'package:claude_chat_clone/data/datasources/base/base_datasource.dart';

/// Base class for remote datasources (API, Firebase, etc.)
abstract class RemoteDatasource extends BaseDatasource {
  final NetworkInfo networkInfo;

  RemoteDatasource({required this.networkInfo});

  /// Check network connectivity before performing operations
  Future<void> ensureConnected() async {
    final isConnected = await networkInfo.checkConnectivity();
    if (!isConnected) {
      throw NetworkException.noInternetConnection();
    }
  }

  /// Perform network operation with connectivity check
  Future<T> performNetworkOperation<T>(
    Future<T> Function() operation, {
    required String context,
    String? customMessage,
  }) async {
    await ensureConnected();
    return handleAsyncException(operation,
        context: context, customMessage: customMessage);
  }
}
