import 'package:claude_chat_clone/core/constants/constants.dart';
import 'package:claude_chat_clone/core/utils/string_utils.dart';

/// Validation result for input validation
class ValidationResult {
  final bool isValid;
  final String? errorMessage;

  /// Create an invalid result with error message
  const ValidationResult.invalid(String errorMessage)
      : this._(isValid: false, errorMessage: errorMessage);

  /// Create a valid result
  const ValidationResult.valid() : this._(isValid: true);

  const ValidationResult._({
    required this.isValid,
    this.errorMessage,
  });

  @override
  String toString() => isValid ? 'Valid' : 'Invalid: $errorMessage';
}

/// Comprehensive input validation utilities for the application
class ValidationUtils {
  // Regular expressions for advanced validation
  static final RegExp _apiKeyPattern =
      RegExp(r'^sk-ant-api03-[A-Za-z0-9_-]{95}$');

  static final RegExp _strongPasswordPattern = RegExp(
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]',
  );
  static final RegExp _hexColorPattern =
      RegExp(r'^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$');
  static final RegExp _ipv4Pattern = RegExp(
    r'^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$',
  );
  // Prevent instantiation
  ValidationUtils._();

  /// Check if all validation results are valid
  static bool areAllValid(Map<String, ValidationResult> results) {
    return results.values.every((result) => result.isValid);
  }

  /// Get all error messages from validation results
  static List<String> getAllErrors(Map<String, ValidationResult> results) {
    return results.values
        .where((result) => !result.isValid)
        .map((result) => result.errorMessage!)
        .toList();
  }

  /// Get first error message from validation results
  static String? getFirstError(Map<String, ValidationResult> results) {
    for (final result in results.values) {
      if (!result.isValid) {
        return result.errorMessage;
      }
    }
    return null;
  }

  /// Sanitize input to prevent XSS attacks
  static String sanitizeInput(String? input) {
    if (StringUtils.isNullOrEmpty(input)) return '';

    return StringUtils.escapeHtml(input!.trim());
  }

  /// Validate age (for user profiles)
  static ValidationResult validateAge(int? age,
      {int minAge = 13, int maxAge = 120}) {
    if (age == null) {
      return const ValidationResult.invalid('Age is required');
    }

    if (age < minAge) {
      return ValidationResult.invalid('Age must be at least $minAge');
    }

    if (age > maxAge) {
      return ValidationResult.invalid('Age must not exceed $maxAge');
    }

    return const ValidationResult.valid();
  }

  /// Validate and sanitize user input
  static ValidationResult validateAndSanitizeInput(
    String? input, {
    required int maxLength,
    bool allowHtml = false,
  }) {
    if (StringUtils.isNullOrEmpty(input)) {
      return const ValidationResult.invalid('Input is required');
    }

    String sanitized = input!.trim();

    if (!allowHtml) {
      sanitized = StringUtils.removeHtmlTags(sanitized);
      sanitized = StringUtils.escapeHtml(sanitized);
    }

    if (sanitized.length > maxLength) {
      return ValidationResult.invalid(
          'Input must not exceed $maxLength characters');
    }

    return const ValidationResult.valid();
  }

  /// Validate Claude API key format
  static ValidationResult validateApiKey(String? apiKey) {
    if (StringUtils.isNullOrEmpty(apiKey)) {
      return const ValidationResult.invalid('API key is required');
    }

    final trimmedKey = apiKey!.trim();

    if (!_apiKeyPattern.hasMatch(trimmedKey)) {
      return const ValidationResult.invalid(
          'Invalid API key format. Please check your Claude API key');
    }

    return const ValidationResult.valid();
  }

  /// Validate chat title
  static ValidationResult validateChatTitle(String? title) {
    if (StringUtils.isNullOrEmpty(title)) {
      return const ValidationResult.invalid('Chat title is required');
    }

    final trimmedTitle = title!.trim();

    if (trimmedTitle.length > AppConstants.maxChatTitleLength) {
      return ValidationResult.invalid(
          'Chat title must not exceed ${AppConstants.maxChatTitleLength} characters');
    }

    // Check for inappropriate characters
    if (RegExp(r'[<>:"/\\|?*]').hasMatch(trimmedTitle)) {
      return const ValidationResult.invalid(
          'Chat title contains invalid characters');
    }

    return const ValidationResult.valid();
  }

  /// Validate date range
  static ValidationResult validateDateRange(
      DateTime? startDate, DateTime? endDate) {
    if (startDate == null) {
      return const ValidationResult.invalid('Start date is required');
    }

    if (endDate == null) {
      return const ValidationResult.invalid('End date is required');
    }

    if (startDate.isAfter(endDate)) {
      return const ValidationResult.invalid(
          'Start date must be before end date');
    }

    return const ValidationResult.valid();
  }

  /// Validate date string in ISO format
  static ValidationResult validateDateString(String? dateString) {
    if (StringUtils.isNullOrEmpty(dateString)) {
      return const ValidationResult.invalid('Date is required');
    }

    try {
      DateTime.parse(dateString!);
      return const ValidationResult.valid();
    } catch (e) {
      return const ValidationResult.invalid(
          'Invalid date format. Please use ISO format (YYYY-MM-DD)');
    }
  }

  /// Validate email address
  static ValidationResult validateEmail(String? email) {
    if (StringUtils.isNullOrEmpty(email)) {
      return const ValidationResult.invalid('Email is required');
    }

    final trimmedEmail = email!.trim();

    if (!StringUtils.isValidEmail(trimmedEmail)) {
      return const ValidationResult.invalid(
          'Please enter a valid email address');
    }

    if (trimmedEmail.length > 254) {
      return const ValidationResult.invalid('Email address is too long');
    }

    return const ValidationResult.valid();
  }

  /// Validate file extension
  static ValidationResult validateFileExtension(
    String? fileName,
    List<String> allowedExtensions,
  ) {
    if (StringUtils.isNullOrEmpty(fileName)) {
      return const ValidationResult.invalid('File name is required');
    }

    final extension = fileName!.split('.').last.toLowerCase();

    if (!allowedExtensions.contains(extension)) {
      final allowedList = allowedExtensions.join(', ');
      return ValidationResult.invalid('Only $allowedList files are allowed');
    }

    return const ValidationResult.valid();
  }

  /// Validate file size
  static ValidationResult validateFileSize(int? fileSizeBytes,
      {int? maxSizeBytes}) {
    if (fileSizeBytes == null) {
      return const ValidationResult.invalid('File size is required');
    }

    if (fileSizeBytes <= 0) {
      return const ValidationResult.invalid('Invalid file size');
    }

    final maxSize = maxSizeBytes ?? AppConstants.maxFileSize;

    if (fileSizeBytes > maxSize) {
      final maxSizeMB = (maxSize / (1024 * 1024)).toStringAsFixed(1);
      return ValidationResult.invalid(
          'File size must not exceed ${maxSizeMB}MB');
    }

    return const ValidationResult.valid();
  }

  /// Validate hex color code
  static ValidationResult validateHexColor(String? color) {
    if (StringUtils.isNullOrEmpty(color)) {
      return const ValidationResult.invalid('Color is required');
    }

    final trimmedColor = color!.trim();

    if (!_hexColorPattern.hasMatch(trimmedColor)) {
      return const ValidationResult.invalid(
          'Please enter a valid hex color code (e.g., #FF0000)');
    }

    return const ValidationResult.valid();
  }

  /// Validate IPv4 address
  static ValidationResult validateIpAddress(String? ip) {
    if (StringUtils.isNullOrEmpty(ip)) {
      return const ValidationResult.invalid('IP address is required');
    }

    final trimmedIp = ip!.trim();

    if (!_ipv4Pattern.hasMatch(trimmedIp)) {
      return const ValidationResult.invalid(
          'Please enter a valid IPv4 address');
    }

    return const ValidationResult.valid();
  }

  /// Validate JSON string
  static ValidationResult validateJson(String? jsonString) {
    if (StringUtils.isNullOrEmpty(jsonString)) {
      return const ValidationResult.invalid('JSON string is required');
    }

    try {
      // Try to parse the JSON to validate it
      final decoded = Uri.decodeComponent(jsonString!);
      return const ValidationResult.valid();
    } catch (e) {
      return const ValidationResult.invalid('Invalid JSON format');
    }
  }

  /// Validate message content
  static ValidationResult validateMessage(String? message) {
    if (StringUtils.isNullOrEmpty(message)) {
      return const ValidationResult.invalid('Message cannot be empty');
    }

    final trimmedMessage = message!.trim();

    if (trimmedMessage.length > AppConstants.maxMessageLength) {
      return ValidationResult.invalid(
          'Message must not exceed ${AppConstants.maxMessageLength} characters');
    }

    return const ValidationResult.valid();
  }

  /// Validate multiple fields at once
  static Map<String, ValidationResult> validateMultiple(
      Map<String, ValidationResult Function()> validators) {
    final results = <String, ValidationResult>{};

    for (final entry in validators.entries) {
      results[entry.key] = entry.value();
    }

    return results;
  }

  /// Validate password with customizable requirements
  static ValidationResult validatePassword(
    String? password, {
    int minLength = 8,
    int maxLength = 128,
    bool requireUppercase = false,
    bool requireLowercase = false,
    bool requireNumbers = false,
    bool requireSpecialChars = false,
  }) {
    if (StringUtils.isNullOrEmpty(password)) {
      return const ValidationResult.invalid('Password is required');
    }

    final trimmedPassword = password!.trim();

    if (trimmedPassword.length < minLength) {
      return ValidationResult.invalid(
          'Password must be at least $minLength characters long');
    }

    if (trimmedPassword.length > maxLength) {
      return ValidationResult.invalid(
          'Password must not exceed $maxLength characters');
    }

    if (requireUppercase && !RegExp(r'[A-Z]').hasMatch(trimmedPassword)) {
      return const ValidationResult.invalid(
          'Password must contain at least one uppercase letter');
    }

    if (requireLowercase && !RegExp(r'[a-z]').hasMatch(trimmedPassword)) {
      return const ValidationResult.invalid(
          'Password must contain at least one lowercase letter');
    }

    if (requireNumbers && !RegExp(r'\d').hasMatch(trimmedPassword)) {
      return const ValidationResult.invalid(
          'Password must contain at least one number');
    }

    if (requireSpecialChars &&
        !RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(trimmedPassword)) {
      return const ValidationResult.invalid(
          'Password must contain at least one special character');
    }

    return const ValidationResult.valid();
  }

  /// Validate phone number
  static ValidationResult validatePhoneNumber(String? phone) {
    if (StringUtils.isNullOrEmpty(phone)) {
      return const ValidationResult.invalid('Phone number is required');
    }

    final trimmedPhone = phone!.trim();

    if (!StringUtils.isValidPhoneNumber(trimmedPhone)) {
      return const ValidationResult.invalid(
          'Please enter a valid phone number');
    }

    return const ValidationResult.valid();
  }

  /// Validate port number
  static ValidationResult validatePort(int? port) {
    if (port == null) {
      return const ValidationResult.invalid('Port number is required');
    }

    if (port < 1 || port > 65535) {
      return const ValidationResult.invalid(
          'Port number must be between 1 and 65535');
    }

    return const ValidationResult.valid();
  }

  /// Validate project description
  static ValidationResult validateProjectDescription(String? description) {
    if (StringUtils.isNullOrEmpty(description)) {
      return const ValidationResult.valid(); // Description is optional
    }

    final trimmedDescription = description!.trim();

    if (trimmedDescription.length > AppConstants.maxProjectDescriptionLength) {
      return ValidationResult.invalid(
          'Project description must not exceed ${AppConstants.maxProjectDescriptionLength} characters');
    }

    return const ValidationResult.valid();
  }

  /// Validate project name
  static ValidationResult validateProjectName(String? name) {
    if (StringUtils.isNullOrEmpty(name)) {
      return const ValidationResult.invalid('Project name is required');
    }

    final trimmedName = name!.trim();

    if (trimmedName.length > AppConstants.maxProjectNameLength) {
      return ValidationResult.invalid(
          'Project name must not exceed ${AppConstants.maxProjectNameLength} characters');
    }

    // Check for inappropriate characters
    if (RegExp(r'[<>:"/\\|?*]').hasMatch(trimmedName)) {
      return const ValidationResult.invalid(
          'Project name contains invalid characters');
    }

    return const ValidationResult.valid();
  }

  /// Validate search query
  static ValidationResult validateSearchQuery(
    String? query, {
    int minLength = 1,
    int maxLength = 100,
  }) {
    if (StringUtils.isNullOrEmpty(query)) {
      return const ValidationResult.valid(); // Search query can be empty
    }

    final trimmedQuery = query!.trim();

    if (trimmedQuery.length < minLength) {
      return ValidationResult.invalid(
          'Search query must be at least $minLength character long');
    }

    if (trimmedQuery.length > maxLength) {
      return ValidationResult.invalid(
          'Search query must not exceed $maxLength characters');
    }

    return const ValidationResult.valid();
  }

  /// Validate URL
  static ValidationResult validateUrl(String? url,
      {bool requireHttps = false}) {
    if (StringUtils.isNullOrEmpty(url)) {
      return const ValidationResult.invalid('URL is required');
    }

    final trimmedUrl = url!.trim();

    if (!StringUtils.isValidUrl(trimmedUrl)) {
      return const ValidationResult.invalid('Please enter a valid URL');
    }

    if (requireHttps && !trimmedUrl.startsWith('https://')) {
      return const ValidationResult.invalid('HTTPS URL is required');
    }

    return const ValidationResult.valid();
  }

  /// Validate username
  static ValidationResult validateUsername(
    String? username, {
    int minLength = 3,
    int maxLength = 30,
    bool allowSpecialChars = false,
  }) {
    if (StringUtils.isNullOrEmpty(username)) {
      return const ValidationResult.invalid('Username is required');
    }

    final trimmedUsername = username!.trim();

    if (trimmedUsername.length < minLength) {
      return ValidationResult.invalid(
          'Username must be at least $minLength characters long');
    }

    if (trimmedUsername.length > maxLength) {
      return ValidationResult.invalid(
          'Username must not exceed $maxLength characters');
    }

    if (!allowSpecialChars &&
        !StringUtils.isAlphanumeric(trimmedUsername.replaceAll('_', ''))) {
      return const ValidationResult.invalid(
          'Username can only contain letters, numbers, and underscores');
    }

    if (trimmedUsername.startsWith('_') || trimmedUsername.endsWith('_')) {
      return const ValidationResult.invalid(
          'Username cannot start or end with an underscore');
    }

    return const ValidationResult.valid();
  }
}
