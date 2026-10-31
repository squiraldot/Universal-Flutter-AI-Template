import 'package:flutter_test/flutter_test.dart';
import 'package:universal_app/core/ai/ai_cancellation_token.dart';
import 'package:universal_app/core/ai/ai_client.dart';

import '../../support/mock_ai_client.dart';

void main() {
  test('MockAiClient implements AiClient and records prompts', () async {
    final client = MockAiClient();

    expect(client, isA<AiClient>());
    expect(await client.complete('hello'), 'Mock response: hello');
    expect(await client.stream('hello').toList(), ['Mock ', 'stream: hello']);
    expect(client.prompts, ['hello', 'hello']);

    client.close();
    expect(client.isClosed, isTrue);
  });

  test('MockAiClient supports deterministic custom handlers', () async {
    final client = MockAiClient(
      onComplete: (prompt) async => 'answer:$prompt',
      onStream: (prompt) => Stream<String>.fromIterable(['a', prompt]),
    );

    expect(await client.complete('question'), 'answer:question');
    expect(await client.stream('question').toList(), ['a', 'question']);
  });

  test('MockAiClient observes cancellation', () async {
    final token = AiCancellationToken()..cancel();
    final client = MockAiClient();

    await expectLater(
      client.complete('question', cancellationToken: token),
      throwsA(isA<Exception>()),
    );
    await expectLater(
      client.stream('question', cancellationToken: token).toList(),
      throwsA(isA<Exception>()),
    );
  });
}
