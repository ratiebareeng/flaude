import 'package:claude_chat_clone/domain/entities/entities.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import 'app/app.dart';
import 'chat/chat.dart';
import 'chats/chats.dart';
import 'projects/projects.dart';

/// Creates a new ChatBloc instance for a specific chat
/// This should be used when navigating to a chat screen
BlocProvider<ChatBloc> createChatBlocProvider({
  required Widget child,
  String? chatId,
  String? projectId,
}) {
  return BlocProvider<ChatBloc>(
    create: (context) => GetIt.instance<ChatBloc>()
      ..add(ChatInitialized(
        chatId: chatId,
        projectId: projectId,
      )),
    child: child,
  );
}

/// Provides all BLoCs to the widget tree using MultiBlocProvider
class BlocProviders extends StatelessWidget {
  final Widget child;

  const BlocProviders({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // App BLoC - Singleton for global app state
        BlocProvider<AppBloc>(
          create: (context) =>
              GetIt.instance<AppBloc>()..add(const AppInitialized()),
        ),

        // Chats BLoC - Singleton for chats list
        BlocProvider<ChatsBloc>(
          create: (context) =>
              GetIt.instance<ChatsBloc>()..add(const ChatsInitialized()),
        ),

        // Projects BLoC - Singleton for projects list
        BlocProvider<ProjectsBloc>(
          create: (context) =>
              GetIt.instance<ProjectsBloc>()..add(const ProjectsInitialized()),
        ),

        // Chat BLoC - Individual chat instances
        // Note: Individual chat BLoCs should be created when needed
        // using BlocProvider.value or by navigation
      ],
      child: child,
    );
  }
}

/// Utility class for BLoC-related operations
class BlocUtils {
  /// Check if real-time updates are active
  static bool areUpdatesActive(BuildContext context) {
    final chatsState = context.read<ChatsBloc>().state;
    final projectsState = context.read<ProjectsBloc>().state;

    return (chatsState is ChatsLoaded) || (projectsState is ProjectsLoaded);
  }

  /// Dispose all BLoCs (useful for testing)
  static void disposeAll(BuildContext context) {
    context.read<AppBloc>().close();
    context.read<ChatsBloc>().close();
    context.read<ProjectsBloc>().close();

    final chatBloc = context.chatBlocOrNull;
    chatBloc?.close();
  }

  /// Get current API key from app state
  static String? getApiKey(BuildContext context) {
    final appState = context.read<AppBloc>().state;
    return appState is AppReady ? appState.apiKey : null;
  }

  /// Get current user from app state
  static User? getCurrentUser(BuildContext context) {
    final appState = context.read<AppBloc>().state;
    return appState is AppReady ? appState.user : null;
  }

  /// Get selected model from app state
  static AIModel? getSelectedModel(BuildContext context) {
    final appState = context.read<AppBloc>().state;
    return appState is AppReady ? appState.selectedModel : null;
  }

  /// Check if app is properly configured
  static bool isAppConfigured(BuildContext context) {
    final appState = context.read<AppBloc>().state;
    return appState is AppReady && appState.isConfigured;
  }
}

/// Creates multiple BLoC listeners for global state changes
class GlobalBlocListeners extends StatelessWidget {
  final Widget child;

  const GlobalBlocListeners({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        // App BLoC Listener - Handle global app state changes
        BlocListener<AppBloc, AppState>(
          listener: (context, state) {
            if (state is AppError) {
              // Show global error messages
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                  action: SnackBarAction(
                    label: 'Dismiss',
                    onPressed: () {
                      context.read<AppBloc>().add(const AppErrorCleared());
                    },
                  ),
                ),
              );
            } else if (state is AppNeedsConfiguration) {
              // Navigate to configuration screen if needed
              // This would be handled by the main app router
            }
          },
        ),

        // Chats BLoC Listener - Handle chats list changes
        BlocListener<ChatsBloc, ChatsState>(
          listener: (context, state) {
            if (state is ChatsError && state.isNetworkError) {
              // Show network error with retry option
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.orange,
                  action: SnackBarAction(
                    label: 'Retry',
                    onPressed: () {
                      context.read<ChatsBloc>().add(const ChatsRefreshed());
                    },
                  ),
                ),
              );
            }
          },
        ),

        // Projects BLoC Listener - Handle projects changes
        BlocListener<ProjectsBloc, ProjectsState>(
          listener: (context, state) {
            if (state is ProjectsError && state.isValidationError) {
              // Show validation errors
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.orange,
                ),
              );
            } else if (state is ProjectsNameValidated && !state.isValid) {
              // Handle name validation feedback
              // This could be used to show real-time validation in forms
            }
          },
        ),
      ],
      child: child,
    );
  }
}

/// Extension to easily access BLoCs from context
extension BlocExtensions on BuildContext {
  AppBloc get appBloc => read<AppBloc>();
  // Chat BLoC might not always be available
  ChatBloc? get chatBlocOrNull {
    try {
      return read<ChatBloc>();
    } catch (e) {
      return null;
    }
  }

  ChatsBloc get chatsBloc => read<ChatsBloc>();

  ProjectsBloc get projectsBloc => read<ProjectsBloc>();
}
