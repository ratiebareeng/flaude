/// UI BLoCs barrel file
///
/// This file exports all BLoC modules for easy importing throughout the app.
/// The BLoC pattern is used for state management in the presentation layer.
library;

// App BLoC - Global app state management
export 'app/app.dart';

// Chat BLoC - Individual chat state management
export 'chat/chat.dart';

// Chats BLoC - Chats list state management
export 'chats/chats.dart';

// Projects BLoC - Projects state management
export 'projects/projects.dart';

// BLoC Infrastructure
export 'bloc_observer.dart';
export 'bloc_providers.dart';