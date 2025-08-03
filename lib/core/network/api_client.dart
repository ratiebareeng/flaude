// lib/core/network/api_client.dart

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:claude_chat_clone/core/constants/constants.dart';
import 'package:claude_chat_clone/core/error/error.dart';
import 'package:http/http.dart' as http;

/// HTTP client wrapper that provides common functionality for API requests
class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  late http.Client _client;
  Map<String, String> _defaultHeaders = {};

  /// Initialize the API client with default configuration
  void initialize() {
    _client = http.Client();
    _setDefaultHeaders();
  }

  /// Set default headers for all requests
  void _setDefaultHeaders() {
    _defaultHeaders = {
      ApiConstants.contentTypeHeader: ApiConstants.applicationJsonContentType,
      'User-Agent': 'Flaude/1.0.0 (Flutter)',
    };
  }

  /// Add or update a default header
  void setDefaultHeader(String key, String value) {
    _defaultHeaders[key] = value;
  }

  /// Remove a default header
  void removeDefaultHeader(String key) {
    _defaultHeaders.remove(key);
  }

  /// Configure Claude API headers
  void configureClaudeHeaders(String apiKey) {
    setDefaultHeader(ApiConstants.apiKeyHeader, apiKey);
    setDefaultHeader(ApiConstants.anthropicVersionHeader, ApiConstants.claudeAnthropicVersion);
  }

  /// Clear Claude API headers
  void clearClaudeHeaders() {
    removeDefaultHeader(ApiConstants.apiKeyHeader);
    removeDefaultHeader(ApiConstants.anthropicVersionHeader);
  }

  /// Make a GET request
  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    Duration? timeout,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    final uri = _buildUri(endpoint, queryParameters);
    
    return _makeRequest<T>(
      () => _client.get(uri, headers: _mergeHeaders(headers)),
      timeout: timeout,
      fromJson: fromJson,
    );
  }

  /// Make a POST request
  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
    Duration? timeout,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    final uri = _buildUri(endpoint, queryParameters);
    final jsonBody = body != null ? jsonEncode(body) : null;
    
    return _makeRequest<T>(
      () => _client.post(
        uri,
        headers: _mergeHeaders(headers),
        body: jsonBody,
      ),
      timeout: timeout,
      fromJson: fromJson,
    );
  }

  /// Make a PUT request
  Future<ApiResponse<T>> put<T>(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
    Duration? timeout,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    final uri = _buildUri(endpoint, queryParameters);
    final jsonBody = body != null ? jsonEncode(body) : null;
    
    return _makeRequest<T>(
      () => _client.put(
        uri,
        headers: _mergeHeaders(headers),
        body: jsonBody,
      ),
      timeout: timeout,
      fromJson: fromJson,
    );
  }

  /// Make a DELETE request
  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    Duration? timeout,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    final uri = _buildUri(endpoint, queryParameters);
    
    return _makeRequest<T>(
      () => _client.delete(uri, headers: _mergeHeaders(headers)),
      timeout: timeout,
      fromJson: fromJson,
    );
  }

  /// Make a PATCH request
  Future<ApiResponse<T>> patch<T>(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
    Duration? timeout,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    final uri = _buildUri(endpoint, queryParameters);
    final jsonBody = body != null ? jsonEncode(body) : null;
    
    return _makeRequest<T>(
      () => _client.patch(
        uri,
        headers: _mergeHeaders(headers),
        body: jsonBody,
      ),
      timeout: timeout,
      fromJson: fromJson,
    );
  }

  /// Make a request with retry logic
  Future<ApiResponse<T>> _makeRequest<T>(
    Future<http.Response> Function() requestFunction, {
    Duration? timeout,
    T Function(Map<String, dynamic>)? fromJson,
    int retryCount = 0,
  }) async {
    try {
      final response = await requestFunction().timeout(
        timeout ?? Duration(seconds: ApiConstants.requestTimeoutSeconds),
      );

      final apiResponse = _handleResponse<T>(response, fromJson);
      
      // Log successful requests in debug mode
      _logRequest(response.request, response);
      
      return apiResponse;
    } on SocketException {
      throw NetworkException.noInternetConnection();
    } on TimeoutException {
      throw NetworkException.timeout();
    } on FormatException catch (e) {
      throw NetworkException.badRequest(details: 'Invalid response format: ${e.message}');
    } on http.ClientException catch (e) {
      // Retry logic for certain client exceptions
      if (retryCount < ApiConstants.maxRetryAttempts && _shouldRetry(e)) {
        await Future.delayed(Duration(seconds: ApiConstants.retryDelaySeconds));
        return _makeRequest<T>(
          requestFunction,
          timeout: timeout,
          fromJson: fromJson,
          retryCount: retryCount + 1,
        );
      }
      throw NetworkException.serverError(details: e.message);
    } catch (e) {
      throw NetworkException.serverError(details: e.toString());
    }
  }

  /// Handle HTTP response and convert to ApiResponse
  ApiResponse<T> _handleResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>)? fromJson,
  ) {
    final statusCode = response.statusCode;
    
    // Parse response body
    Map<String, dynamic> data = {};
    try {
      if (response.body.isNotEmpty) {
        data = jsonDecode(response.body) as Map<String, dynamic>;
      }
    } catch (e) {
      if (statusCode >= 200 && statusCode < 300) {
        // Success but invalid JSON - treat as empty response
        data = {};
      } else {
        throw NetworkException.badRequest(
          details: 'Invalid JSON response: ${e.toString()}',
        );
      }
    }

    // Handle different status codes
    if (statusCode >= 200 && statusCode < 300) {
      // Success
      T? parsedData;
      if (fromJson != null && data.isNotEmpty) {
        try {
          parsedData = fromJson(data);
        } catch (e) {
          throw NetworkException.badRequest(
            details: 'Failed to parse response: ${e.toString()}',
          );
        }
      }
      
      return ApiResponse<T>.success(
        data: parsedData,
        rawData: data,
        statusCode: statusCode,
        headers: response.headers,
      );
    } else {
      // Error response
      _handleErrorResponse(statusCode, data);
      // This line should never be reached due to exceptions thrown above
      throw NetworkException.serverError(details: 'Unexpected error');
    }
  }

  /// Handle error responses based on status codes
  void _handleErrorResponse(int statusCode, Map<String, dynamic> data) {
    switch (statusCode) {
      case 400:
        throw NetworkException.badRequest(
          details: data['error']?['message'] ?? 'Bad request',
        );
      case 401:
        throw NetworkException.unauthorized();
      case 403:
        throw NetworkException.forbidden();
      case 404:
        throw NetworkException.notFound();
      case 429:
        // Check if it's Claude API rate limiting
        if (data['error']?['type'] == 'rate_limit_error') {
          throw ClaudeApiException.rateLimitExceeded();
        }
        throw NetworkException.serverError(details: 'Rate limit exceeded');
      case 500:
      case 502:
      case 503:
      case 504:
        throw NetworkException.serverError(
          details: data['error']?['message'] ?? 'Server error',
        );
      default:
        throw NetworkException.serverError(
          details: 'HTTP $statusCode: ${data['error']?['message'] ?? 'Unknown error'}',
        );
    }
  }

  /// Build URI with query parameters
  Uri _buildUri(String endpoint, Map<String, dynamic>? queryParameters) {
    if (endpoint.startsWith('http')) {
      // Full URL provided
      final uri = Uri.parse(endpoint);
      if (queryParameters != null && queryParameters.isNotEmpty) {
        return uri.replace(queryParameters: {
          ...uri.queryParameters,
          ...queryParameters.map((key, value) => MapEntry(key, value.toString())),
        });
      }
      return uri;
    } else {
      // Relative endpoint - you might want to add a base URL configuration
      throw ArgumentError('Base URL not configured. Please provide full URL or configure base URL.');
    }
  }

  /// Merge default headers with request-specific headers
  Map<String, String> _mergeHeaders(Map<String, String>? headers) {
    return {
      ..._defaultHeaders,
      if (headers != null) ...headers,
    };
  }

  /// Log request details for debugging
  void _logRequest(http.BaseRequest? request, http.Response response) {
    if (request != null) {
      log(
        'API Request: ${request.method} ${request.url}\n'
        'Status: ${response.statusCode}\n'
        'Response: ${response.body.length > 500 ? '${response.body.substring(0, 500)}...' : response.body}',
        name: 'ApiClient',
      );
    }
  }

  /// Determine if a request should be retried
  bool _shouldRetry(http.ClientException exception) {
    // Retry on network errors but not on client errors
    return exception.message.contains('Connection') ||
           exception.message.contains('timeout') ||
           exception.message.contains('SocketException');
  }

  /// Close the HTTP client
  void dispose() {
    _client.close();
  }
}

/// Response wrapper for API calls
class ApiResponse<T> {
  final T? data;
  final Map<String, dynamic> rawData;
  final int statusCode;
  final Map<String, String> headers;
  final bool isSuccess;
  final String? errorMessage;

  const ApiResponse._({
    this.data,
    required this.rawData,
    required this.statusCode,
    required this.headers,
    required this.isSuccess,
    this.errorMessage,
  });

  /// Create a successful response
  factory ApiResponse.success({
    T? data,
    required Map<String, dynamic> rawData,
    required int statusCode,
    required Map<String, String> headers,
  }) {
    return ApiResponse._(
      data: data,
      rawData: rawData,
      statusCode: statusCode,
      headers: headers,
      isSuccess: true,
    );
  }

  /// Create an error response
  factory ApiResponse.error({
    required Map<String, dynamic> rawData,
    required int statusCode,
    required Map<String, String> headers,
    String? errorMessage,
  }) {
    return ApiResponse._(
      rawData: rawData,
      statusCode: statusCode,
      headers: headers,
      isSuccess: false,
      errorMessage: errorMessage,
    );
  }

  @override
  String toString() {
    return 'ApiResponse{statusCode: $statusCode, isSuccess: $isSuccess, data: $data}';
  }
}