import 'dart:developer' as developer;

import 'package:flutter_bloc/flutter_bloc.dart';

/// Custom BLoC observer for debugging and logging
///
/// This observer helps with:
/// - Logging state changes and events
/// - Debugging BLoC behavior
/// - Monitoring app performance
/// - Error tracking
class AppBlocObserver extends BlocObserver {
  /// Whether to enable detailed logging (should be false in production)
  final bool enableDetailedLogging;

  /// Whether to log state changes
  final bool logStateChanges;

  /// Whether to log events
  final bool logEvents;

  /// Whether to log errors
  final bool logErrors;

  /// Whether to log transitions
  final bool logTransitions;

  const AppBlocObserver({
    this.enableDetailedLogging = true,
    this.logStateChanges = true,
    this.logEvents = true,
    this.logErrors = true,
    this.logTransitions = true,
  });

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    if (logStateChanges && enableDetailedLogging) {
      developer.log(
        '🔄 State Change: ${bloc.runtimeType}\n'
        'From: ${change.currentState.runtimeType}\n'
        'To: ${change.nextState.runtimeType}',
        name: 'BlocObserver',
      );
    }
  }

  @override
  void onClose(BlocBase bloc) {
    super.onClose(bloc);
    if (enableDetailedLogging) {
      developer.log(
        '�️ BLoC Closed: ${bloc.runtimeType}',
        name: 'BlocObserver',
      );
    }
  }

  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    if (enableDetailedLogging) {
      developer.log(
        '🏗️ BLoC Created: ${bloc.runtimeType}',
        name: 'BlocObserver',
      );
    }
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    if (logErrors) {
      developer.log(
        '❌ BLoC Error: ${bloc.runtimeType}\n'
        'Error: ${error.toString()}\n'
        'StackTrace: ${stackTrace.toString()}',
        name: 'BlocObserver',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  void onEvent(BlocBase bloc, Object? event) {
    if (bloc is Bloc) {
      super.onEvent(bloc, event);
    }
    if (logEvents && enableDetailedLogging) {
      developer.log(
        '📝 Event: ${bloc.runtimeType} -> ${event.runtimeType}\n'
        'Details: ${event.toString()}',
        name: 'BlocObserver',
      );
    }
  }

  @override
  void onTransition(BlocBase bloc, Transition transition) {
    if (bloc is Bloc) {
      super.onTransition(bloc, transition);
    }
    if (logTransitions && enableDetailedLogging) {
      developer.log(
        '� Transition: ${bloc.runtimeType}\n'
        'Event: ${transition.event.runtimeType}\n'
        'From: ${transition.currentState.runtimeType}\n'
        'To: ${transition.nextState.runtimeType}',
        name: 'BlocObserver',
      );
    }
  }
}

/// Factory for creating appropriate BLoC observers based on environment
class BlocObserverFactory {
  /// Create observer for development environment
  static BlocObserver createDevelopment() {
    return const DebugBlocObserver();
  }

  /// Create observer for specific BLoC types only
  static BlocObserver createForTypes(Set<Type> types) {
    return TypedBlocObserver(watchedTypes: types);
  }

  /// Create observer for production environment
  static BlocObserver createProduction() {
    return const ProductionBlocObserver();
  }

  /// Create observer for testing environment
  static BlocObserver createTesting() {
    return const AppBlocObserver(
      enableDetailedLogging: false,
      logStateChanges: false,
      logEvents: false,
      logErrors: true,
      logTransitions: false,
    );
  }
}

/// Debug BLoC observer with enhanced logging for development
class DebugBlocObserver extends AppBlocObserver {
  const DebugBlocObserver()
      : super(
          enableDetailedLogging: true,
          logStateChanges: true,
          logEvents: true,
          logErrors: true,
          logTransitions: true,
        );

  @override
  void onTransition(BlocBase bloc, Transition transition) {
    super.onTransition(bloc, transition);

    // Additional debug information
    _logPerformanceMetrics(bloc, transition);
    _logMemoryUsage(bloc);
  }

  /// Log memory usage information
  void _logMemoryUsage(BlocBase bloc) {
    // This is a simplified example - in real apps you might use
    // more sophisticated memory monitoring
    if (enableDetailedLogging) {
      developer.log(
        '💾 Memory: ${bloc.runtimeType} state size estimation',
        name: 'BlocMemory',
      );
    }
  }

  /// Log performance metrics for debugging
  void _logPerformanceMetrics(BlocBase bloc, Transition transition) {
    if (enableDetailedLogging) {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      developer.log(
        '⏱️ Performance: ${bloc.runtimeType} transition at $timestamp',
        name: 'BlocPerformance',
      );
    }
  }
}

/// Production-optimized BLoC observer with minimal logging
class ProductionBlocObserver extends BlocObserver {
  const ProductionBlocObserver();

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);

    // In production, you might want to send errors to a crash reporting service
    // like Firebase Crashlytics, Sentry, etc.
    developer.log(
      'BLoC Error in ${bloc.runtimeType}: ${error.toString()}',
      name: 'BlocError',
      error: error,
      stackTrace: stackTrace,
    );

    // Example: Send to crash reporting
    // FirebaseCrashlytics.instance.recordError(error, stackTrace);
  }
}

/// Custom observer for specific BLoC types
class TypedBlocObserver extends BlocObserver {
  final Set<Type> _watchedTypes;
  final bool _logOnlyWatchedTypes;

  const TypedBlocObserver({
    required Set<Type> watchedTypes,
    bool logOnlyWatchedTypes = true,
  })  : _watchedTypes = watchedTypes,
        _logOnlyWatchedTypes = logOnlyWatchedTypes;

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    if (_shouldLog(bloc)) {
      developer.log(
        'Change: ${bloc.runtimeType} -> ${change.nextState.runtimeType}',
        name: 'TypedObserver',
      );
    }
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    if (_shouldLog(bloc)) {
      developer.log(
        'Error in ${bloc.runtimeType}: ${error.toString()}',
        name: 'TypedObserver',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  void onEvent(BlocBase bloc, Object? event) {
    if (bloc is Bloc) {
      super.onEvent(bloc, event);
    }
    if (_shouldLog(bloc)) {
      developer.log(
        'Event: ${bloc.runtimeType} -> ${event.runtimeType}',
        name: 'TypedObserver',
      );
    }
  }

  bool _shouldLog(BlocBase bloc) {
    return !_logOnlyWatchedTypes || _watchedTypes.contains(bloc.runtimeType);
  }
}
