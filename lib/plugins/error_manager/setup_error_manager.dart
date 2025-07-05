import 'dart:ui';

import 'package:flutter/material.dart';

import 'error_manager.dart';

void setupErrorManager() {
  // Replace default error screen
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return SimpleErrorPage(
      errorMessage: details.exceptionAsString(),
      stackTrace: details.stack,
    );
  };

  // Log Flutter framework errors
  FlutterError.onError = (FlutterErrorDetails details) async {
    await ErrorManager.logToFile(
      fileName: details.stack?.toString() ?? 'Unknown',
      errorMessage: details.exceptionAsString(),
      stackTrace: details.stack,
    );
  };

  // Log uncaught platform errors
  PlatformDispatcher.instance.onError = (error, stack) {
    ErrorManager.logToFile(
      fileName: stack.toString(),
      errorMessage: error.toString(),
      stackTrace: stack,
    ).catchError((e) {});
    return true;
  } as ErrorCallback?;
}
