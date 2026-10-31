import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/foundation.dart';

import 'app_logger.dart';

void configureAppErrorReporting({required AppLogger logger}) {
  FlutterError.onError = (details) {
    logger.error(
      'Flutter framework error',
      scope: 'flutter',
      stackTrace: details.stack,
    );
  };

  PlatformDispatcher.instance.onError = (error, stackTrace) {
    logger.error(
      'Uncaught platform error',
      scope: 'platform',
      stackTrace: stackTrace,
    );
    return true;
  };
}
