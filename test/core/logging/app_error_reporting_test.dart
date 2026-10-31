import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:universal_app/core/logging/app_error_reporting.dart';
import 'package:universal_app/core/logging/app_logger.dart';

void main() {
  test('framework and platform errors are logged without raw exception data', () {
    final originalFlutterHandler = FlutterError.onError;
    final originalPlatformHandler = PlatformDispatcher.instance.onError;
    final records = <_LogRecord>[];
    final logger = DeveloperAppLogger(
      sink: (message, {required level, required name, error, stackTrace}) {
        records.add(
          _LogRecord(scope: name, message: message, error: error),
        );
      },
    );
    addTearDown(() {
      FlutterError.onError = originalFlutterHandler;
      PlatformDispatcher.instance.onError = originalPlatformHandler;
    });

    configureAppErrorReporting(logger: logger);

    FlutterError.onError!(
      FlutterErrorDetails(exception: StateError('sensitive diagnostic')),
    );
    final handled = PlatformDispatcher.instance.onError!(
      StateError('sensitive platform detail'),
      StackTrace.current,
    );

    expect(records.map((record) => record.scope), ['flutter', 'platform']);
    expect(records.map((record) => record.message), [
      'Flutter framework error',
      'Uncaught platform error',
    ]);
    expect(records.every((record) => record.error == null), isTrue);
    expect(handled, isTrue);
  });
}

class _LogRecord {
  const _LogRecord({
    required this.scope,
    required this.message,
    required this.error,
  });

  final String scope;
  final String message;
  final Object? error;
}
