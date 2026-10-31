import 'dart:developer' as developer;

typedef DeveloperLogSink = void Function(
  String message, {
  required int level,
  required String name,
  Object? error,
  StackTrace? stackTrace,
});

abstract interface class AppLogger {
  void debug(String message, {String scope = 'app'});

  void info(String message, {String scope = 'app'});

  void warning(String message, {String scope = 'app'});

  void error(
    String message, {
    String scope = 'app',
    Object? error,
    StackTrace? stackTrace,
  });
}

final class DeveloperAppLogger implements AppLogger {
  DeveloperAppLogger({DeveloperLogSink? sink}) : _sink = sink ?? _developerLog;

  final DeveloperLogSink _sink;

  @override
  void debug(String message, {String scope = 'app'}) {
    _sink(message, level: 500, name: scope);
  }

  @override
  void info(String message, {String scope = 'app'}) {
    _sink(message, level: 800, name: scope);
  }

  @override
  void warning(String message, {String scope = 'app'}) {
    _sink(message, level: 900, name: scope);
  }

  @override
  void error(
    String message, {
    String scope = 'app',
    Object? error,
    StackTrace? stackTrace,
  }) {
    _sink(
      message,
      level: 1000,
      name: scope,
      error: error,
      stackTrace: stackTrace,
    );
  }
}

void _developerLog(
  String message, {
  required int level,
  required String name,
  Object? error,
  StackTrace? stackTrace,
}) {
  developer.log(
    message,
    level: level,
    name: name,
    error: error,
    stackTrace: stackTrace,
  );
}
