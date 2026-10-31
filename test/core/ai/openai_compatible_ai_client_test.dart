import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:universal_app/core/ai/ai_cancellation_token.dart';
import 'package:universal_app/core/ai/ai_client.dart';
import 'package:universal_app/core/ai/ai_config.dart';
import 'package:universal_app/core/ai/ai_exception.dart';
import 'package:universal_app/core/ai/openai_compatible_ai_client.dart';

void main() {
  AiConfig config({
    Duration timeout = const Duration(seconds: 1),
    int maxRetries = 0,
  }) => AiConfig(
    baseUrl: Uri.parse('https://example.com/v1'),
    model: 'demo-model',
    timeout: timeout,
    maxRetries: maxRetries,
    retryBaseDelay: const Duration(milliseconds: 1),
    maxRetryDelay: const Duration(milliseconds: 5),
  );

  http.Response success(String content) => http.Response(
    jsonEncode({
      'choices': [
        {
          'message': {'content': content},
        },
      ],
    }),
    200,
  );

  OpenAiCompatibleAiClient create(
    Future<http.Response> Function(http.Request) handler, {
    AiConfig? aiConfig,
    Future<String?> Function()? tokenProvider,
  }) => OpenAiCompatibleAiClient(
    config: aiConfig ?? config(),
    tokenProvider: tokenProvider ?? () async => 'session-token',
    httpClient: MockClient(handler),
  );

  test('implements provider-independent AiClient contract', () {
    expect(
      OpenAiCompatibleAiClient(
        config: config(),
        tokenProvider: () async => 'token',
        httpClient: MockClient((_) async => success('ok')),
      ),
      isA<AiClient>(),
    );
  });

  test('sends a chat request and returns assistant text', () async {
    final client = create((request) async {
      expect(request.url, config().chatCompletionsUri);
      expect(request.headers['authorization'], 'Bearer session-token');
      final body = jsonDecode(request.body) as Map<String, dynamic>;
      expect(body['model'], 'demo-model');
      expect(body['messages'][0]['content'], 'Hello');
      expect(body['stream'], isFalse);
      return success('  Hi there!  ');
    });

    expect(await client.complete(' Hello '), 'Hi there!');
    client.close();
  });

  test('rejects empty prompts before making a request', () async {
    final client = create((_) async => success('unused'));
    await expectLater(client.complete('  '), throwsArgumentError);
    client.close();
  });

  test('maps missing credentials to authentication error', () async {
    final client = create(
      (_) async => success('unused'),
      tokenProvider: () async => null,
    );

    await expectLater(
      client.complete('Hello'),
      throwsA(
        isA<AiException>().having(
          (error) => error.type,
          'type',
          AiErrorType.authentication,
        ),
      ),
    );
    client.close();
  });

  test('maps 401 and 403 to authentication errors', () async {
    for (final status in [401, 403]) {
      final client = create(
        (_) async => http.Response('private provider detail', status),
      );
      await expectLater(
        client.complete('Hello'),
        throwsA(
          isA<AiException>()
              .having((error) => error.type, 'type', AiErrorType.authentication)
              .having((error) => error.statusCode, 'statusCode', status)
              .having(
                (error) => error.message,
                'safe message',
                isNot(contains('private provider detail')),
              ),
        ),
      );
      client.close();
    }
  });

  test('maps exhausted 429 responses to rate-limit errors', () async {
    var calls = 0;
    final client = create(
      (_) async {
        calls++;
        return http.Response('provider detail', 429);
      },
      aiConfig: config(maxRetries: 1),
    );

    await expectLater(
      client.complete('Hello'),
      throwsA(
        isA<AiException>().having(
          (error) => error.type,
          'type',
          AiErrorType.rateLimit,
        ),
      ),
    );
    expect(calls, 2);
    client.close();
  });

  test('retries transient server errors with a bounded attempt count', () async {
    var calls = 0;
    final client = create(
      (_) async {
        calls++;
        return calls < 3 ? http.Response('unavailable', 503) : success('done');
      },
      aiConfig: config(maxRetries: 2),
    );

    expect(await client.complete('Hello'), 'done');
    expect(calls, 3);
    client.close();
  });

  test('does not exceed configured retry limit', () async {
    var calls = 0;
    final client = create(
      (_) async {
        calls++;
        return http.Response('unavailable', 503);
      },
      aiConfig: config(maxRetries: 2),
    );

    await expectLater(client.complete('Hello'), throwsA(isA<AiException>()));
    expect(calls, 3);
    client.close();
  });

  test('maps client transport failures to network errors', () async {
    final client = create((_) async {
      throw http.ClientException('offline');
    });

    await expectLater(
      client.complete('Hello'),
      throwsA(
        isA<AiException>().having(
          (error) => error.type,
          'type',
          AiErrorType.network,
        ),
      ),
    );
    client.close();
  });

  test('maps request timeout to timeout error', () async {
    final client = create(
      (_) async {
        await Future<void>.delayed(const Duration(milliseconds: 40));
        return success('late');
      },
      aiConfig: config(timeout: const Duration(milliseconds: 5)),
    );

    await expectLater(
      client.complete('Hello'),
      throwsA(
        isA<AiException>().having(
          (error) => error.type,
          'type',
          AiErrorType.timeout,
        ),
      ),
    );
    client.close();
  });

  test('cancels an in-flight request', () async {
    final pending = Completer<http.Response>();
    final cancellation = AiCancellationToken();
    final client = create((_) => pending.future);
    final operation = client.complete(
      'Hello',
      cancellationToken: cancellation,
    );
    await Future<void>.delayed(const Duration(milliseconds: 1));
    cancellation.cancel();

    await expectLater(
      operation,
      throwsA(
        isA<AiException>().having(
          (error) => error.type,
          'type',
          AiErrorType.cancelled,
        ),
      ),
    );
    client.close();
  });

  test('rejects malformed JSON and structurally invalid responses', () async {
    for (final body in [
      'not-json',
      '{}',
      '{"choices":[]}',
      '{"choices":[{"message":{"content":42}}]}',
    ]) {
      final client = create((_) async => http.Response(body, 200));
      await expectLater(
        client.complete('Hello'),
        throwsA(
          isA<AiException>().having(
            (error) => error.type,
            'type',
            AiErrorType.invalidResponse,
          ),
        ),
      );
      client.close();
    }
  });

  test('streams incremental server-sent events', () async {
    final client = OpenAiCompatibleAiClient(
      config: config(),
      tokenProvider: () async => 'token',
      httpClient: MockClient((request) async {
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['stream'], isTrue);
        return http.Response(
          'data: {"choices":[{"delta":{"content":"Hello "}}]}\n\n'
          'data: {"choices":[{"delta":{"content":"world"}}]}\n\n'
          'data: [DONE]\n\n',
          200,
          headers: {'content-type': 'text/event-stream'},
        );
      }),
    );

    expect(await client.stream('Say hello').toList(), ['Hello ', 'world']);
    client.close();
  });

  test('maps malformed stream events to invalid-response errors', () async {
    final client = OpenAiCompatibleAiClient(
      config: config(),
      tokenProvider: () async => 'token',
      httpClient: MockClient(
        (_) async => http.Response('data: not-json\n\n', 200),
      ),
    );

    await expectLater(
      client.stream('Hello').toList(),
      throwsA(
        isA<AiException>().having(
          (error) => error.type,
          'type',
          AiErrorType.invalidResponse,
        ),
      ),
    );
    client.close();
  });
}
