import 'package:flutter_test/flutter_test.dart';
import 'package:universal_app/core/ai/ai_config.dart';

void main() {
  group('AiConfig', () {
    test('builds chat endpoint while preserving API path prefix', () {
      final config = AiConfig(
        baseUrl: Uri.parse('https://example.com/v1/'),
        model: 'demo-model',
      );

      expect(
        config.chatCompletionsUri,
        Uri.parse('https://example.com/v1/chat/completions'),
      );
    });

    test('rejects non-HTTP schemes', () {
      expect(
        () => AiConfig(
          baseUrl: Uri.parse('file:///tmp/api'),
          model: 'demo-model',
        ),
        throwsArgumentError,
      );
    });

    test('rejects credentials embedded in the URL', () {
      expect(
        () => AiConfig(
          baseUrl: Uri.parse('https://user:secret@example.com/v1'),
          model: 'demo-model',
        ),
        throwsArgumentError,
      );
    });

    test('rejects blank model names', () {
      expect(
        () =>
            AiConfig(baseUrl: Uri.parse('https://example.com/v1'), model: '  '),
        throwsArgumentError,
      );
    });

    test('accepts bounded retry configuration', () {
      final config = AiConfig(
        baseUrl: Uri.parse('https://example.com/v1'),
        model: 'demo-model',
        maxRetries: 3,
        retryBaseDelay: const Duration(milliseconds: 100),
        maxRetryDelay: const Duration(seconds: 1),
      );

      expect(config.maxRetries, 3);
    });

    test('rejects retry counts above the hard limit', () {
      expect(
        () => AiConfig(
          baseUrl: Uri.parse('https://example.com/v1'),
          model: 'demo-model',
          maxRetries: 6,
        ),
        throwsArgumentError,
      );
    });

    test('rejects an invalid retry delay range', () {
      expect(
        () => AiConfig(
          baseUrl: Uri.parse('https://example.com/v1'),
          model: 'demo-model',
          retryBaseDelay: const Duration(seconds: 2),
          maxRetryDelay: const Duration(seconds: 1),
        ),
        throwsArgumentError,
      );
    });
  });
}
