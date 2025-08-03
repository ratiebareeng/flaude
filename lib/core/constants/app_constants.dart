import 'package:flutter/material.dart';

/// Application-wide UI and configuration constants
class AppConstants {
  // App Information
  static const String appName = 'Flaude';

  static const String appDisplayName = 'Flaude - Claude UI Clone';
  static const String appDescription =
      'A lightweight Flutter app to interact with Claude via the Anthropic API.';
  static const String appVersion = '1.0.0';
  // Theme Colors
  static const Color primaryColor = Color(0xFFCD7F32);

  static const Color onDarkPrimaryColor = Color(0xFFFAF9F5);
  // Background Colors
  static const Color darkBackgroundColor = Color(0xFF262624);

  static const Color lightBackgroundColor = Color(0xFFFAF9F5);
  static const Color chatBackgroundColor = Color(0xFF1A1917);
  static const Color drawerBackgroundColor = Color(0xFF1F1E1D);
  static const Color artifactBackgroundColor = Color(0xFF30302E);
  // Surface Colors
  static const Color darkSurfaceColor = Color(0xFF262624);

  static const Color lightSurfaceColor = Color(0xFFFAF9F5);
  static const Color userChatCardColor = Color(0xFF141413);
  static const Color messageBubbleColor = Color(0xFF2F2F2F);
  static const Color userMessageBubbleColor = Color(0xFF3A3A3A);
  // Border and Outline Colors
  static const Color borderColor = Color(0xFF3A3A3A);

  static const Color focusBorderColor = Color(0xFFBD5D3A);
  // Text Colors
  static const Color primaryTextColor = Colors.white;

  static const Color secondaryTextColor = Color(0xFF9E9E9E);
  static const Color hintTextColor = Color(0xFF757575);
  static const Color errorTextColor = Colors.red;
  static const Color successTextColor = Colors.green;
  // Layout Dimensions
  static const double navigationDrawerWidth = 300.0;

  static const double navigationDrawerMinWidth = 60.0;
  static const double artifactPanelWidth = 400.0;
  static const double maxContentWidth = 800.0;
  static const double maxInputWidth = 600.0;
  // Spacing and Padding
  static const double spacingXS = 4.0;

  static const double spacingS = 8.0;
  static const double spacingM = 12.0;
  static const double spacingL = 16.0;
  static const double spacingXL = 24.0;
  static const double spacingXXL = 32.0;
  static const double spacingXXXL = 48.0;
  // Border Radius
  static const double borderRadiusS = 6.0;

  static const double borderRadiusM = 8.0;
  static const double borderRadiusL = 12.0;
  static const double borderRadiusXL = 16.0;
  // Icon Sizes
  static const double iconSizeS = 16.0;

  static const double iconSizeM = 20.0;
  static const double iconSizeL = 24.0;
  static const double iconSizeXL = 32.0;
  static const double iconSizeXXL = 48.0;
  // Avatar Sizes
  static const double avatarSizeS = 24.0;

  static const double avatarSizeM = 32.0;
  static const double avatarSizeL = 40.0;
  static const double avatarSizeXL = 48.0;
  // Font Sizes
  static const double fontSizeXS = 11.0;

  static const double fontSizeS = 12.0;
  static const double fontSizeM = 14.0;
  static const double fontSizeL = 16.0;
  static const double fontSizeXL = 18.0;
  static const double fontSizeXXL = 20.0;
  static const double fontSizeXXXL = 24.0;
  static const double fontSizeDisplay = 48.0;
  // Animation Durations
  static const Duration animationDurationShort = Duration(milliseconds: 150);

  static const Duration animationDurationMedium = Duration(milliseconds: 300);
  static const Duration animationDurationLong = Duration(milliseconds: 500);
  // Transition Durations
  static const Duration transitionDuration = Duration(milliseconds: 200);

  static const Duration loadingIndicatorDuration = Duration(milliseconds: 1000);
  // Input Configuration
  static const int maxMessageLength = 10000;

  static const int maxChatTitleLength = 100;
  static const int maxProjectNameLength = 50;
  static const int maxProjectDescriptionLength = 500;
  static const int minInputLines = 1;
  static const int maxInputLines = 10;
  // UI Behavior
  static const int searchDebounceMs = 300;

  static const int autoSaveDelayMs = 2000;
  static const int notificationDurationMs = 4000;
  static const int successNotificationDurationMs = 2000;
  // Pagination
  static const int defaultPageSize = 20;

  static const int maxRecentChats = 10;
  static const int maxStarredChats = 5;
  // Breakpoints for Responsive Design
  static const double mobileBreakpoint = 600.0;

  static const double tabletBreakpoint = 1000.0;
  static const double desktopBreakpoint = 1200.0;
  // Default Messages
  static const String defaultChatTitle = 'Untitled';

  static const String defaultInputHint = 'How can I help you today?';
  static const String defaultGreeting = 'Evening, naledi';
  static const String defaultLoadingMessage = 'Claude is thinking...';
  // Error Messages
  static const String genericErrorMessage =
      'Something went wrong. Please try again.';

  static const String networkErrorMessage =
      'No internet connection. Please check your network.';
  static const String chatNotFoundMessage =
      'Chat not found. Please start a new chat.';
  static const String emptyChatsMessage = 'No chats yet';
  static const String emptyProjectsMessage = 'No projects yet';
  static const String searchNoResultsMessage = 'No results found';
  // Success Messages
  static const String chatDeletedMessage = 'Chat deleted successfully!';

  static const String chatRenamedMessage = 'Chat renamed successfully!';
  static const String chatTitleUpdatedMessage =
      'Chat title updated successfully!';
  static const String projectCreatedMessage = 'Project created successfully!';
  static const String artifactAddedMessage =
      'Artifact added to project knowledge';
  static const String settingsSavedMessage = 'Settings saved successfully!';
  // File and Storage
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB

  static const List<String> supportedImageFormats = [
    'jpg',
    'jpeg',
    'png',
    'gif',
    'webp'
  ];
  static const List<String> supportedDocumentFormats = [
    'pdf',
    'txt',
    'md',
    'docx'
  ];
  // Suggestion Chips
  static const List<Map<String, String>> defaultSuggestions = [
    {'title': '✏️ Write', 'subtitle': 'Draft an email to my team'},
    {'title': '📚 Learn', 'subtitle': 'Explain quantum computing'},
    {'title': '💻 Code', 'subtitle': 'Build a Flutter app'},
    {'title': '☕ Life stuff', 'subtitle': 'Plan my weekend'},
    {'title': '🎲 Claude\'s choice', 'subtitle': 'Surprise me'},
  ];

  // External Links
  static const String anthropicConsoleUrl = 'https://console.anthropic.com';

  static const String claudeApiDocsUrl = 'https://docs.anthropic.com';
  static const String supportUrl = 'https://support.anthropic.com';
  // Prevent instantiation
  AppConstants._();
}
