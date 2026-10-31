import 'package:flutter_test/flutter_test.dart';
import 'package:universal_app/core/logging/app_logger.dart';

void main() {
  test('forwards debug, info, warning and error diagnostics to the sink', () {
    final records = <_LogRecord>[];
    final logger = DeveloperAppLogger(
      sink: (message, {required level, required name, error, stackTrace}) {
        records.add(
          _LogRecord(
            message: message,
            level: level,
            name: name,
            error: error,
            stackTrace: stackTrace,
          ),
        );
      },
    );
    final cause = StateError('diagnostic cause');
    final trace = StackTrace.current;

    logger.debug('cache lookup', scope: 'catalog');
    logger.info('request started', scope: 'network');
    logger.warning('retry scheduled', scope: 'network');
    logger.error(
      'request failed',
      scope: 'network',
      error: cause,
      stackTrace: trace,
    );

    expect(records, hasLength(4));
    expect(records.map((record) => record.level), [500, 800, 900, 1000]);
    expect(records.map((record) => record.name), [
      'catalog',
      'network',
      'network',
      'network',
    ]);
    expect(records.last.error, same(cause));
    expect(records.last.stackTrace, same(trace));
    expect(records.map((record) => record.message), [
      'cache lookup',
      'request started',
      'retry scheduled',
      'request failed',
    ]);
  });
}

class _LogRecord {
  const _LogRecord({
    required this.message,
    required this.level,
    required this.name,
    this.error,
    this.stackTrace,
  });

  final String message;
  final int level;
  final String name;
  final Object? error;
  final StackTrace? stackTrace;
}
