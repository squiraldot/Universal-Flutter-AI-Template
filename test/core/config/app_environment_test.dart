import 'package:flutter_test/flutter_test.dart';
import 'package:universal_app/core/config/app_environment.dart';

void main() {
  group('AppEnvironment.fromValues', () {
    test('defaults to development when using build defines', () {
      final environment = AppEnvironment.fromBuildDefines();

      expect(environment.name, AppEnvironmentName.development);
      expect(environment.apiBaseUrl, isNull);
    });

    test('accepts each supported environment name', () {
      for (final name in AppEnvironmentName.values) {
        final environment = AppEnvironment.fromValues(name: name.name);
        expect(environment.name, name);
      }
    });

    test('allows an absent API base URL', () {
      final environment = AppEnvironment.fromValues(name: 'staging');

      expect(environment.apiBaseUrl, isNull);
    });

    test('parses absolute HTTP and HTTPS API URLs', () {
      final httpEnvironment = AppEnvironment.fromValues(
        name: 'development',
        apiBaseUrl: 'http://localhost:8080/api',
      );
      final httpsEnvironment = AppEnvironment.fromValues(
        name: 'production',
        apiBaseUrl: 'https://api.example.com/v1',
      );

      expect(httpEnvironment.apiBaseUrl?.scheme, 'http');
      expect(httpsEnvironment.apiBaseUrl?.scheme, 'https');
      expect(httpsEnvironment.apiBaseUrl?.host, 'api.example.com');
    });

    test('rejects unsupported environment names', () {
      expect(
        () => AppEnvironment.fromValues(name: 'qa'),
        throwsFormatException,
      );
    });

    test('rejects malformed, relative and unsupported-scheme URLs', () {
      for (final value in [
        '://invalid',
        '/relative/path',
        'ftp://files.example.com',
        'https://',
      ]) {
        expect(
          () => AppEnvironment.fromValues(
            name: 'development',
            apiBaseUrl: value,
          ),
          throwsFormatException,
          reason: 'Expected $value to be rejected',
        );
      }
    });
  });
}
