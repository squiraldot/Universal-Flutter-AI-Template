import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:universal_app/core/logging/app_error_reporting.dart';
import 'package:universal_app/core/logging/app_logger.dart';

void main() {
  test('framework and platform errors are forwarded to the local logger', () {
    final originalFlutterHandler = FlutterError.onError;
    final originalPlatformHandler = PlatformDispatcher.instance.onError;
    final records = <String>[];
    final logger = DeveloperAppLogger(
      sink: (message, {required level, required name, error, stackTrace}) {
        records.add('$name:$message');
      },
    );
    addTearDown(() {
      FlutterError.onError = originalFlutterHandler;
      PlatformDispatcher.instance.onError = originalPlatformHandler;
    });

    configureAppErrorReporting(logger: logger);

    FlutterError.onError!(
      FlutterErrorDetails(exception: StateError('framework detail')),
    );
    final shouldPropagate = PlatformDispatcher.instance.onError!(
      StateError('platform detail'),
      StackTrace.current,
    );

    expect(records, [
      'flutter:Flutter framework error',
      'platform:Uncaught platform error',
    ]);
    expect(shouldPropagate, isFalse);
  });
}
