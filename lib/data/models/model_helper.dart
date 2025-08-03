import 'dart:convert';
import 'dart:developer';

/// Comprehensive model parsing utilities for safe data conversion
///
/// This helper provides robust parsing methods with fallbacks and validation
/// to handle various data sources (Firebase, APIs, local storage) safely.
class ModelHelper {
  ModelHelper._(); // Prevent instantiation

  // ============================================================================
  // TIMESTAMP PARSING
  // ============================================================================

  /// Clean map by removing null/empty values
  static Map<String, dynamic> cleanMap(Map<String, dynamic> map,
      {bool removeEmptyStrings = true}) {
    final cleaned = <String, dynamic>{};

    for (final entry in map.entries) {
      final value = entry.value;

      // Skip null values
      if (value == null) continue;

      // Skip empty strings if requested
      if (removeEmptyStrings && value is String && value.trim().isEmpty)
        continue;

      // Skip empty collections
      if (isNullOrEmptyCollection(value)) continue;

      // Recursively clean nested maps
      if (value is Map<String, dynamic>) {
        final cleanedNested =
            cleanMap(value, removeEmptyStrings: removeEmptyStrings);
        if (cleanedNested.isNotEmpty) {
          cleaned[entry.key] = cleanedNested;
        }
      } else {
        cleaned[entry.key] = value;
      }
    }

    return cleaned;
  }

  /// Create error map for consistent error reporting
  static Map<String, dynamic> createErrorMap(
    String message, {
    String? code,
    Map<String, dynamic>? details,
  }) {
    return {
      'error': true,
      'message': message,
      if (code != null) 'code': code,
      if (details != null) 'details': details,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
  }

  /// Deep copy a Map<String, dynamic>
  static Map<String, dynamic> deepCopyMap(Map<String, dynamic> original) {
    try {
      return parseMap(jsonDecode(jsonEncode(original)));
    } catch (e) {
      log('Error deep copying map: $original - $e', name: 'ModelHelper');
      return Map<String, dynamic>.from(original);
    }
  }

  /// Extract error message from error map
  static String getErrorMessage(Map<String, dynamic> errorMap,
      {String fallback = 'Unknown error'}) {
    return parseString(errorMap['message'], fallback: fallback);
  }

  // ============================================================================
  // SAFE TYPE CONVERSION
  // ============================================================================

  /// Check if map represents an error
  static bool isErrorMap(Map<String, dynamic> map) {
    return map['error'] == true;
  }

  /// Check if string is null or empty
  static bool isNullOrEmpty(String? value) {
    return value == null || value.trim().isEmpty;
  }

  /// Check if collection is null or empty
  static bool isNullOrEmptyCollection(dynamic collection) {
    if (collection == null) return true;
    if (collection is List) return collection.isEmpty;
    if (collection is Map) return collection.isEmpty;
    if (collection is String) return collection.trim().isEmpty;
    return false;
  }

  /// Validate chat title
  static bool isValidChatTitle(String? title, {int maxLength = 100}) {
    if (isNullOrEmpty(title)) return false;
    return title!.length <= maxLength &&
        !title.contains(RegExp(r'[<>:"/\\|?*]'));
  }

  // ============================================================================
  // COLLECTION PARSING
  // ============================================================================

  /// Validate email format
  static bool isValidEmail(String? email) {
    if (email == null || email.isEmpty) return false;

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  /// Validate message content
  static bool isValidMessageContent(String? content, {int maxLength = 10000}) {
    if (isNullOrEmpty(content)) return false;
    return content!.length <= maxLength;
  }

  /// Validate project name
  static bool isValidProjectName(String? name, {int maxLength = 50}) {
    if (isNullOrEmpty(name)) return false;
    return name!.length <= maxLength && !name.contains(RegExp(r'[<>:"/\\|?*]'));
  }

  /// Validate URL format
  static bool isValidUrl(String? url) {
    if (url == null || url.isEmpty) return false;

    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  // ============================================================================
  // JSON UTILITIES
  // ============================================================================

  /// Validate UUID format
  static bool isValidUuid(String? uuid) {
    if (uuid == null || uuid.isEmpty) return false;

    final uuidRegex = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
    );
    return uuidRegex.hasMatch(uuid);
  }

  /// Safely parse boolean with fallback
  static bool parseBool(dynamic value, {bool fallback = false}) {
    if (value == null) return fallback;

    try {
      if (value is bool) return value;
      if (value is String) {
        final lower = value.toLowerCase();
        if (lower == 'true' || lower == '1' || lower == 'yes') return true;
        if (lower == 'false' || lower == '0' || lower == 'no') return false;
      }
      if (value is int) return value != 0;
    } catch (e) {
      log('Error parsing bool: $value - $e', name: 'ModelHelper');
    }

    return fallback;
  }

  /// Parse Claude model ID and extract version info
  static Map<String, String> parseClaudeModelId(String modelId) {
    final parts = modelId.split('-');

    if (parts.length >= 3) {
      return {
        'family': parts[0], // claude
        'model': parts[1], // sonnet, opus, haiku
        'version': parts.length > 2 ? parts[2] : 'unknown',
        'date': parts.length > 3 ? parts[3] : 'unknown',
      };
    }

    return {
      'family': 'claude',
      'model': 'unknown',
      'version': 'unknown',
      'date': 'unknown',
    };
  }

  // ============================================================================
  // VALIDATION UTILITIES
  // ============================================================================

  /// Parse timestamp to DateTime object
  static DateTime parseDateTime(dynamic value, {DateTime? fallback}) {
    final timestamp =
        parseTimestamp(value, fallback: fallback?.millisecondsSinceEpoch);
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  /// Safely parse double with fallback
  static double parseDouble(dynamic value, {double fallback = 0.0}) {
    if (value == null) return fallback;

    try {
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) {
        return double.tryParse(value) ?? fallback;
      }
    } catch (e) {
      log('Error parsing double: $value - $e', name: 'ModelHelper');
    }

    return fallback;
  }

  /// Safely parse int with fallback
  static int parseInt(dynamic value, {int fallback = 0}) {
    if (value == null) return fallback;

    try {
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) {
        return int.tryParse(value) ?? fallback;
      }
    } catch (e) {
      log('Error parsing int: $value - $e', name: 'ModelHelper');
    }

    return fallback;
  }

  /// Safely parse Map<String, dynamic> with validation
  static Map<String, dynamic> parseMap(dynamic value,
      {Map<String, dynamic>? fallback}) {
    fallback ??= <String, dynamic>{};

    if (value == null) return fallback;

    try {
      if (value is Map<String, dynamic>) {
        return Map<String, dynamic>.from(value);
      }
      if (value is Map) {
        return value.map((k, v) => MapEntry(k.toString(), v));
      }
      if (value is String && value.isNotEmpty) {
        // Try to parse as JSON object
        final decoded = jsonDecode(value);
        if (decoded is Map) {
          return parseMap(decoded, fallback: fallback);
        }
      }
    } catch (e) {
      log('Error parsing map: $value - $e', name: 'ModelHelper');
    }

    return fallback;
  }

  /// Parse nullable Map<String, dynamic>
  static Map<String, dynamic>? parseNullableMap(dynamic value) {
    if (value == null) return null;
    final result = parseMap(value);
    return result.isEmpty ? null : result;
  }

  // ============================================================================
  // SANITIZATION UTILITIES
  // ============================================================================

  /// Parse nullable List<String>
  static List<String>? parseNullableStringList(dynamic value) {
    if (value == null) return null;
    final result = parseStringList(value);
    return result.isEmpty ? null : result;
  }

  /// Safely parse string with fallback
  static String parseString(dynamic value, {String fallback = ''}) {
    if (value == null) return fallback;

    try {
      if (value is String) return value;
      return value.toString();
    } catch (e) {
      log('Error parsing string: $value - $e', name: 'ModelHelper');
      return fallback;
    }
  }

  /// Safely parse List<String> with validation
  static List<String> parseStringList(dynamic value, {List<String>? fallback}) {
    fallback ??= <String>[];

    if (value == null) return fallback;

    try {
      if (value is List) {
        return value
            .map((e) => parseString(e))
            .where((s) => s.isNotEmpty)
            .toList();
      }
      if (value is String && value.isNotEmpty) {
        // Try to parse as JSON array
        try {
          final decoded = jsonDecode(value);
          if (decoded is List) {
            return parseStringList(decoded, fallback: fallback);
          }
        } catch (_) {
          // If not JSON, treat as comma-separated values
          return value
              .split(',')
              .map((s) => s.trim())
              .where((s) => s.isNotEmpty)
              .toList();
        }
      }
    } catch (e) {
      log('Error parsing string list: $value - $e', name: 'ModelHelper');
    }

    return fallback;
  }

  // ============================================================================
  // MODEL-SPECIFIC HELPERS
  // ============================================================================

  /// Parse timestamp from various formats to milliseconds since epoch
  ///
  /// Handles:
  /// - int (milliseconds)
  /// - String (ISO 8601 format)
  /// - DateTime object
  /// - null values with current time fallback
  static int parseTimestamp(dynamic value, {int? fallback}) {
    if (value == null) {
      return fallback ?? DateTime.now().millisecondsSinceEpoch;
    }

    try {
      if (value is int) {
        // Handle both milliseconds and seconds
        return value > 1000000000000 ? value : value * 1000;
      }

      if (value is String) {
        final parsed = DateTime.tryParse(value);
        return parsed?.millisecondsSinceEpoch ??
            (fallback ?? DateTime.now().millisecondsSinceEpoch);
      }

      if (value is DateTime) {
        return value.millisecondsSinceEpoch;
      }

      // Try to parse as double and convert to int
      if (value is double) {
        return value.toInt();
      }
    } catch (e) {
      log('Error parsing timestamp: $value - $e', name: 'ModelHelper');
    }

    return fallback ?? DateTime.now().millisecondsSinceEpoch;
  }

  /// Pretty print a map for debugging
  static String prettyPrintMap(Map<String, dynamic> map, {int indent = 0}) {
    final buffer = StringBuffer();
    final spaces = ' ' * indent;

    map.forEach((key, value) {
      buffer.write('$spaces$key: ');

      if (value is Map<String, dynamic>) {
        buffer.writeln('{');
        buffer.write(prettyPrintMap(value, indent: indent + 2));
        buffer.writeln('$spaces}');
      } else if (value is List) {
        buffer.writeln('[');
        for (int i = 0; i < value.length; i++) {
          buffer.write('$spaces  $i: ${value[i]}');
          if (i < value.length - 1) buffer.write(',');
          buffer.writeln();
        }
        buffer.writeln('$spaces]');
      } else {
        buffer.writeln(value);
      }
    });

    return buffer.toString();
  }

  /// Safely decode JSON string
  static Map<String, dynamic> safeJsonDecode(String jsonString,
      {Map<String, dynamic>? fallback}) {
    fallback ??= <String, dynamic>{};

    if (jsonString.isEmpty) return fallback;

    try {
      final decoded = jsonDecode(jsonString);
      return parseMap(decoded, fallback: fallback);
    } catch (e) {
      log('Error decoding JSON: $jsonString - $e', name: 'ModelHelper');
      return fallback;
    }
  }

  /// Safely encode object to JSON string
  static String safeJsonEncode(dynamic object, {String fallback = '{}'}) {
    try {
      return jsonEncode(object);
    } catch (e) {
      log('Error encoding JSON: $object - $e', name: 'ModelHelper');
      return fallback;
    }
  }

  /// Safely execute a parsing function with error handling
  static T safeParse<T>(
    T Function() parseFunction,
    T fallback, {
    String? context,
  }) {
    try {
      return parseFunction();
    } catch (e, stackTrace) {
      log(
        'Error in ${context ?? 'parsing'}: $e',
        name: 'ModelHelper',
        error: e,
        stackTrace: stackTrace,
      );
      return fallback;
    }
  }

  // ============================================================================
  // ERROR HANDLING UTILITIES
  // ============================================================================

  /// Get safe string representation for logging
  static String safeToString(dynamic value, {int maxLength = 100}) {
    try {
      final str = value.toString();
      return str.length > maxLength ? '${str.substring(0, maxLength)}...' : str;
    } catch (e) {
      return 'Unable to stringify: ${e.toString()}';
    }
  }

  /// Sanitize HTML content (basic)
  static String sanitizeHtml(String? input) {
    if (input == null) return '';

    return input
        .replaceAll(
            RegExp(r'<script[^>]*>.*?</script>', caseSensitive: false), '')
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .trim();
  }

  /// Sanitize string for safe storage/display
  static String sanitizeString(String? input, {int? maxLength}) {
    if (input == null) return '';

    String sanitized = input.trim();

    // Remove control characters except newlines and tabs
    sanitized =
        sanitized.replaceAll(RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]'), '');

    // Limit length if specified
    if (maxLength != null && sanitized.length > maxLength) {
      sanitized = sanitized.substring(0, maxLength);
    }

    return sanitized;
  }

  /// Generate a Firebase-safe key from a string
  static String toFirebaseKey(String input) {
    return input
        .replaceAll(RegExp(r'[.#$\/\[\]]'), '_')
        .replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '')
        .toLowerCase();
  }

  // ============================================================================
  // DEBUGGING UTILITIES
  // ============================================================================

  /// Convert DateTime to Firebase timestamp format
  static int toFirebaseTimestamp(DateTime dateTime) {
    return dateTime.millisecondsSinceEpoch;
  }

  /// Convert timestamp to ISO 8601 string
  static String toIsoString(dynamic timestamp) {
    final dateTime = parseDateTime(timestamp);
    return dateTime.toIso8601String();
  }
}
