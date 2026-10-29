import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:universal_app/core/ai/ai_config.dart';
import 'package:universal_app/core/ai/ai_exception.dart';
import 'package:universal_app/core/ai/openai_compatible_ai_client.dart';

void main() {
  final config = AiConfig(
    baseUrl: Uri.parse('https://example.com/v1'),
    model: 'demo-model',
  );

  test('sends a chat request and returns assistant text', () async {
    final client = OpenAiCompatibleAiClient(
      config: config,
      tokenProvider: () async => 'test-token',
      httpClient: MockClient((request) async {
        expect(request.url, config.chatCompletionsUri);
        expect(request.headers['authorization'], 'Bearer test-token');
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['model'], 'demo-model');
        expect(body['messages'][0]['content'], 'Hello');
        return http.Response(
          jsonEncode({
            'choices': [
              {
                'message': {'content': '  Hi there!  '},
              },
            ],
          }),
          200,
        );
      }),
    );

    expect(await client.complete(' Hello '), 'Hi there!');
    client.close();
  });

  test('rejects empty prompts before making a request', () async {
    final client = OpenAiCompatibleAiClient(
      config: config,
      tokenProvider: () async => 'test-token',
      httpClient: MockClient((_) async => http.Response('{}', 200)),
    );

    await expectLater(client.complete('  '), throwsArgumentError);
    client.close();
  });

  test('fails safely when no token is available', () async {
    final client = OpenAiCompatibleAiClient(
      config: config,
      tokenProvider: () async => null,
      httpClient: MockClient((_) async => http.Response('{}', 200)),
    );

    await expectLater(
      client.complete('Hello'),
      throwsA(isA<AiException>()),
    );
    client.close();
  });

  test('does not expose provider response bodies for HTTP errors', () async {
    final client = OpenAiCompatibleAiClient(
      config: config,
      tokenProvider: () async => 'test-token',
      httpClient: MockClient(
        (_) async => http.Response('private provider detail', 429),
      ),
    );

    try {
      await client.complete('Hello');
      fail('Expected an AiException');
    } on AiException catch (error) {
      expect(error.statusCode, 429);
      expect(error.message, isNot(contains('private provider detail')));
    } finally {
      client.close();
    }
  });

  test('rejects malformed success responses with a safe error', () async {
    final client = OpenAiCompatibleAiClient(
      config: config,
      tokenProvider: () async => 'test-token',
      httpClient: MockClient((_) async => http.Response('not-json', 200)),
    );

    await expectLater(
      client.complete('Hello'),
      throwsA(isA<AiException>()),
    );
    client.close();
  });
}
