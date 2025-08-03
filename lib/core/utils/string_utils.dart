import 'dart:convert';
import 'dart:math';

/// Comprehensive string manipulation and formatting utilities
class StringUtils {
  // Regular expressions for validation
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  static final RegExp _urlRegex = RegExp(
    r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
  );

  static final RegExp _phoneRegex = RegExp(
    r'^\+?[\d\s\-\(\)]{10,}$',
  );

  static final RegExp _whitespaceRegex = RegExp(r'\s+');

  // Character sets
  static const String _alphanumeric =
      'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';

  static const String _alphabetic =
      'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
  static const String _numeric = '0123456789';
  // Prevent instantiation
  StringUtils._();

  /// Calculate string similarity based on Levenshtein distance
  static double calculateSimilarity(String str1, String str2) {
    if (str1 == str2) return 1.0;

    final maxLength = max(str1.length, str2.length);
    if (maxLength == 0) return 1.0;

    final distance = levenshteinDistance(str1, str2);
    return 1.0 - (distance / maxLength);
  }

  /// Capitalize the first letter of a string
  static String capitalize(String str) {
    if (isNullOrEmpty(str)) return str;
    return str[0].toUpperCase() + str.substring(1).toLowerCase();
  }

  /// Capitalize the first letter of each word
  static String capitalizeWords(String str) {
    if (isNullOrEmpty(str)) return str;
    return str
        .split(' ')
        .map((word) => word.isNotEmpty ? capitalize(word) : word)
        .join(' ');
  }

  /// Compare version strings (e.g., "1.2.3" vs "1.2.10")
  static int compareVersions(String version1, String version2) {
    final v1Parts = version1.split('.').map(int.parse).toList();
    final v2Parts = version2.split('.').map(int.parse).toList();

    final maxLength = [v1Parts.length, v2Parts.length].reduce(max);

    // Pad with zeros if needed
    while (v1Parts.length < maxLength) v1Parts.add(0);
    while (v2Parts.length < maxLength) v2Parts.add(0);

    for (int i = 0; i < maxLength; i++) {
      final comparison = v1Parts[i].compareTo(v2Parts[i]);
      if (comparison != 0) return comparison;
    }

    return 0;
  }

  /// Count characters excluding whitespace
  static int countCharacters(String str, {bool includeSpaces = true}) {
    if (isNullOrEmpty(str)) return 0;
    return includeSpaces ? str.length : removeWhitespace(str).length;
  }

  /// Count words in a string
  static int countWords(String str) {
    if (isNullOrEmpty(str)) return 0;
    return str
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .length;
  }

  /// Decode Base64 string
  static String? decodeBase64(String base64Str) {
    try {
      final bytes = base64.decode(base64Str);
      return utf8.decode(bytes);
    } catch (e) {
      return null;
    }
  }

  /// Encode string to Base64
  static String encodeBase64(String str) {
    final bytes = utf8.encode(str);
    return base64.encode(bytes);
  }

  /// Escape HTML special characters
  static String escapeHtml(String str) {
    return str
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#x27;');
  }

  /// Extract initials from a name
  static String extractInitials(String name, {int maxInitials = 2}) {
    if (isNullOrEmpty(name)) return '';

    final words = name.trim().split(RegExp(r'\s+'));
    final initials = words
        .take(maxInitials)
        .where((word) => word.isNotEmpty)
        .map((word) => word[0].toUpperCase());

    return initials.join('');
  }

  /// Extract numbers from string
  static List<int> extractNumbers(String str) {
    final matches = RegExp(r'\d+').allMatches(str);
    return matches.map((match) => int.parse(match.group(0)!)).toList();
  }

  /// Extract words from string
  static List<String> extractWords(String str) {
    if (isNullOrEmpty(str)) return [];
    return str.split(RegExp(r'\W+')).where((word) => word.isNotEmpty).toList();
  }

  /// Format file size from bytes
  static String formatFileSize(int bytes, {int decimals = 1}) {
    if (bytes <= 0) return '0 B';

    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB', 'PB'];
    final i = (log(bytes) / log(1024)).floor();

    if (i >= suffixes.length) {
      return '${(bytes / pow(1024, suffixes.length - 1)).toStringAsFixed(decimals)} ${suffixes.last}';
    }

    return '${(bytes / pow(1024, i)).toStringAsFixed(decimals)} ${suffixes[i]}';
  }

  /// Generate a random ID (alphanumeric)
  static String generateId({int length = 8}) {
    return generateRandomString(length, alphanumeric: true);
  }

  /// Generate a random string of specified length
  static String generateRandomString(int length,
      {bool alphanumeric = true, bool includeSymbols = false}) {
    final random = Random();
    String chars = alphanumeric ? _alphanumeric : _alphabetic;

    if (includeSymbols) {
      chars += '!@#\$%^&*()_+-=[]{}|;:,.<>?';
    }

    return List.generate(length, (index) => chars[random.nextInt(chars.length)])
        .join();
  }

  /// Check if a string contains only alphabetic characters
  static bool isAlphabetic(String str) {
    if (isNullOrEmpty(str)) return false;
    return RegExp(r'^[a-zA-Z]+$').hasMatch(str);
  }

  /// Check if a string contains only alphanumeric characters
  static bool isAlphanumeric(String str) {
    if (isNullOrEmpty(str)) return false;
    return RegExp(r'^[a-zA-Z0-9]+$').hasMatch(str);
  }

  /// Check if a string is not null and not empty
  static bool isNotNullOrEmpty(String? str) {
    return !isNullOrEmpty(str);
  }

  /// Check if a string is null, empty, or contains only whitespace
  static bool isNullOrEmpty(String? str) {
    return str == null || str.trim().isEmpty;
  }

  /// Check if a string contains only numeric characters
  static bool isNumeric(String str) {
    if (isNullOrEmpty(str)) return false;
    return RegExp(r'^[0-9]+$').hasMatch(str);
  }

  /// Check if string is a palindrome
  static bool isPalindrome(String str) {
    final cleaned = str.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    return cleaned == reverse(cleaned);
  }

  /// Check if a string is a valid email address
  static bool isValidEmail(String email) {
    if (isNullOrEmpty(email)) return false;
    return _emailRegex.hasMatch(email.trim());
  }

  /// Check if a string is a valid phone number
  static bool isValidPhoneNumber(String phone) {
    if (isNullOrEmpty(phone)) return false;
    return _phoneRegex.hasMatch(phone.trim());
  }

  /// Check if a string is a valid URL
  static bool isValidUrl(String url) {
    if (isNullOrEmpty(url)) return false;
    return _urlRegex.hasMatch(url.trim());
  }

  /// Check if a string contains only whitespace characters
  static bool isWhitespace(String str) {
    return str.trim().isEmpty;
  }

  /// Get the Levenshtein distance between two strings
  static int levenshteinDistance(String str1, String str2) {
    final matrix = List.generate(
      str1.length + 1,
      (i) => List.generate(str2.length + 1, (j) => 0),
    );

    for (int i = 0; i <= str1.length; i++) {
      matrix[i][0] = i;
    }

    for (int j = 0; j <= str2.length; j++) {
      matrix[0][j] = j;
    }

    for (int i = 1; i <= str1.length; i++) {
      for (int j = 1; j <= str2.length; j++) {
        final cost = str1[i - 1] == str2[j - 1] ? 0 : 1;
        matrix[i][j] = [
          matrix[i - 1][j] + 1, // deletion
          matrix[i][j - 1] + 1, // insertion
          matrix[i - 1][j - 1] + cost // substitution
        ].reduce(min);
      }
    }

    return matrix[str1.length][str2.length];
  }

  /// Mask email address (e.g., "j***@example.com")
  static String maskEmail(String email) {
    if (!isValidEmail(email)) return email;

    final parts = email.split('@');
    final localPart = parts[0];
    final domain = parts[1];

    if (localPart.length <= 2) {
      return '${localPart[0]}***@$domain';
    }

    final masked = localPart[0] +
        '*' * (localPart.length - 2) +
        localPart[localPart.length - 1];
    return '$masked@$domain';
  }

  /// Mask phone number (e.g., "+1 (***) ***-1234")
  static String maskPhoneNumber(String phone) {
    if (isNullOrEmpty(phone)) return phone;

    final cleaned = phone.replaceAll(RegExp(r'[^\d+]'), '');

    if (cleaned.length < 4) return phone;

    final lastFour = cleaned.substring(cleaned.length - 4);
    final masked = '*' * (cleaned.length - 4) + lastFour;

    return masked;
  }

  /// Normalize whitespace (replace multiple whitespace with single space)
  static String normalizeWhitespace(String str) {
    return str.replaceAll(_whitespaceRegex, ' ').trim();
  }

  /// Remove HTML tags from string
  static String removeHtmlTags(String html) {
    return html.replaceAll(RegExp(r'<[^>]*>'), '');
  }

  /// Remove all whitespace from a string
  static String removeWhitespace(String str) {
    return str.replaceAll(RegExp(r'\s'), '');
  }

  /// Reverse a string
  static String reverse(String str) {
    return str.split('').reversed.join();
  }

  /// Sanitize string for file names
  static String sanitizeFileName(String fileName) {
    return fileName
        .replaceAll(RegExp(r'[<>:"/\\|?*]'), '_')
        .replaceAll(RegExp(r'\s+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
  }

  /// Convert string to camelCase
  static String toCamelCase(String str) {
    if (isNullOrEmpty(str)) return str;

    final words = str.split(RegExp(r'[\s_-]+'));
    if (words.isEmpty) return str;

    final firstWord = words[0].toLowerCase();
    final otherWords = words.skip(1).map((word) => capitalize(word));

    return [firstWord, ...otherWords].join('');
  }

  /// Convert string to kebab-case
  static String toKebabCase(String str) {
    if (isNullOrEmpty(str)) return str;

    return str
        .replaceAllMapped(
            RegExp(r'[A-Z]'), (match) => '-${match.group(0)!.toLowerCase()}')
        .replaceAll(RegExp(r'[\s_]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '')
        .toLowerCase();
  }

  /// Convert string to PascalCase
  static String toPascalCase(String str) {
    if (isNullOrEmpty(str)) return str;

    return str
        .split(RegExp(r'[\s_-]+'))
        .map((word) => capitalize(word))
        .join('');
  }

  /// Convert string to slug (URL-friendly)
  static String toSlug(String str) {
    if (isNullOrEmpty(str)) return '';

    return str
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
        .replaceAll(RegExp(r'[\s_]+'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
  }

  /// Convert string to snake_case
  static String toSnakeCase(String str) {
    if (isNullOrEmpty(str)) return str;

    return str
        .replaceAllMapped(
            RegExp(r'[A-Z]'), (match) => '_${match.group(0)!.toLowerCase()}')
        .replaceAll(RegExp(r'[\s-]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '')
        .toLowerCase();
  }

  /// Truncate string to specified length with optional ellipsis
  static String truncate(String str, int maxLength, {String ellipsis = '...'}) {
    if (str.length <= maxLength) return str;

    final truncateLength = maxLength - ellipsis.length;
    if (truncateLength <= 0) return ellipsis;

    return str.substring(0, truncateLength) + ellipsis;
  }

  /// Truncate string at word boundary
  static String truncateAtWord(String str, int maxLength,
      {String ellipsis = '...'}) {
    if (str.length <= maxLength) return str;

    final truncateLength = maxLength - ellipsis.length;
    if (truncateLength <= 0) return ellipsis;

    final truncated = str.substring(0, truncateLength);
    final lastSpace = truncated.lastIndexOf(' ');

    if (lastSpace == -1) {
      return truncated + ellipsis;
    }

    return truncated.substring(0, lastSpace) + ellipsis;
  }

  /// Unescape HTML special characters
  static String unescapeHtml(String str) {
    return str
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#x27;', "'");
  }

  /// Wrap text to specified line length
  static String wrapText(String text, int lineLength) {
    if (text.length <= lineLength) return text;

    final words = text.split(' ');
    final lines = <String>[];
    String currentLine = '';

    for (final word in words) {
      if ((currentLine + word).length <= lineLength) {
        currentLine += currentLine.isEmpty ? word : ' $word';
      } else {
        if (currentLine.isNotEmpty) {
          lines.add(currentLine);
          currentLine = word;
        } else {
          // Word is longer than line length, force break
          lines.add(word);
        }
      }
    }

    if (currentLine.isNotEmpty) {
      lines.add(currentLine);
    }

    return lines.join('\n');
  }
}
