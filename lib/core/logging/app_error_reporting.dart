import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/foundation.dart';

import 'app_logger.dart';

void configureAppErrorReporting({required AppLogger logger}) {
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    logger.error(
      'Flutter framework error',
      scope: 'flutter',
      error: details.exception,
      stackTrace: details.stack,
    );
  };

  PlatformDispatcher.instance.onError = (error, stackTrace) {
    logger.error(
      'Uncaught platform error',
      scope: 'platform',
      error: error,
      stackTrace: stackTrace,
    );
    return false;
  };
}
