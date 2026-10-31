import 'package:flutter_test/flutter_test.dart';
import 'package:universal_app/core/errors/app_error.dart';
import 'package:universal_app/core/errors/result.dart';

void main() {
  test('Success retains its typed value', () {
    const result = Success<int>(42);

    expect(result, isA<Result<int>>());
    expect(result.value, 42);
  });

  test('Failure retains its typed AppError', () {
    const error = AppError(
      code: 'network_unavailable',
      message: 'Please check your connection.',
    );
    const result = Failure<String>(error);

    expect(result, isA<Result<String>>());
    expect(result.error.code, 'network_unavailable');
    expect(result.error.message, 'Please check your connection.');
  });

  test('AppError retains optional diagnostic information separately', () {
    final cause = StateError('socket detail');
    final trace = StackTrace.current;
    final error = AppError(
      code: 'request_failed',
      message: 'The request could not be completed.',
      cause: cause,
      stackTrace: trace,
    );

    expect(error.cause, same(cause));
    expect(error.stackTrace, same(trace));
    expect(error.message, 'The request could not be completed.');
  });
}
