import 'package:universal_app/core/ai/ai_cancellation_token.dart';
import 'package:universal_app/core/ai/ai_client.dart';

typedef AiCompletionHandler = Future<String> Function(String prompt);
typedef AiStreamHandler = Stream<String> Function(String prompt);

/// Lightweight deterministic fake for tests; no network or provider is used.
class MockAiClient implements AiClient {
  MockAiClient({AiCompletionHandler? onComplete, AiStreamHandler? onStream})
    : _onComplete = onComplete ?? _defaultComplete,
      _onStream = onStream ?? _defaultStream;

  final AiCompletionHandler _onComplete;
  final AiStreamHandler _onStream;
  final List<String> prompts = <String>[];
  bool isClosed = false;

  static Future<String> _defaultComplete(String prompt) async =>
      'Mock response: $prompt';

  static Stream<String> _defaultStream(String prompt) async* {
    yield 'Mock ';
    yield 'stream: $prompt';
  }

  @override
  Future<String> complete(
    String prompt, {
    AiCancellationToken? cancellationToken,
  }) {
    cancellationToken?.throwIfCancelled();
    prompts.add(prompt);
    return _onComplete(prompt);
  }

  @override
  Stream<String> stream(
    String prompt, {
    AiCancellationToken? cancellationToken,
  }) async* {
    cancellationToken?.throwIfCancelled();
    prompts.add(prompt);
    await for (final chunk in _onStream(prompt)) {
      cancellationToken?.throwIfCancelled();
      yield chunk;
    }
  }

  @override
  void close() {
    isClosed = true;
  }
}
