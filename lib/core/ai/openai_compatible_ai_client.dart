import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'ai_cancellation_token.dart';
import 'ai_client.dart';
import 'ai_config.dart';
import 'ai_exception.dart';

/// Supplies a short-lived access token at request time.
///
/// Implement this with a secure backend/session flow. Never ship provider
/// secrets in the Flutter application or its APK.
typedef AiTokenProvider = Future<String?> Function();

/// HTTP adapter for APIs implementing the OpenAI chat-completions format.
///
/// The public contract is [AiClient], so app features can replace this adapter
/// without depending on a provider-specific implementation.
class OpenAiCompatibleAiClient implements AiClient {
  OpenAiCompatibleAiClient({
    required this.config,
    required this.tokenProvider,
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client(),
       _ownsHttpClient = httpClient == null;

  final AiConfig config;
  final AiTokenProvider tokenProvider;
  final http.Client _httpClient;
  final bool _ownsHttpClient;

  @override
  Future<String> complete(
    String prompt, {
    AiCancellationToken? cancellationToken,
  }) async {
    _validatePrompt(prompt);
    final cancellation = _operationToken(cancellationToken);
    final token = await _getToken(cancellation);
    final result = await _sendWithRetries(
      prompt: prompt.trim(),
      token: token,
      cancellation: cancellation,
      streaming: false,
    );
    _throwForStatus(result);

    final body = await _readBody(result.response, result.cancellation);
    try {
      final decoded = jsonDecode(body);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Expected a JSON object.');
      }
      final choices = decoded['choices'];
      if (choices is! List || choices.isEmpty) {
        throw const FormatException('Missing choices.');
      }
      final first = choices.first;
      if (first is! Map<String, dynamic>) {
        throw const FormatException('Invalid choice.');
      }
      final message = first['message'];
      if (message is! Map<String, dynamic>) {
        throw const FormatException('Missing message.');
      }
      final content = message['content'];
      if (content is! String || content.trim().isEmpty) {
        throw const FormatException('Missing text content.');
      }
      return content.trim();
    } on FormatException {
      throw AiException.invalidResponse();
    }
  }

  @override
  Stream<String> stream(
    String prompt, {
    AiCancellationToken? cancellationToken,
  }) {
    _validatePrompt(prompt);
    final cancellation = _operationToken(cancellationToken);
    late final StreamController<String> controller;
    controller = StreamController<String>(
      onListen: () {
        unawaited(_runStream(prompt, cancellation, controller));
      },
      onCancel: cancellation.cancel,
    );
    return controller.stream;
  }

  Future<void> _runStream(
    String prompt,
    AiCancellationToken cancellation,
    StreamController<String> controller,
  ) async {
    try {
      final accessToken = await _getToken(cancellation);
      final result = await _sendWithRetries(
        prompt: prompt.trim(),
        token: accessToken,
        cancellation: cancellation,
        streaming: true,
      );
      _throwForStatus(result);
      await for (final chunk in _decodeEvents(
        result.response,
        result.cancellation,
      )) {
        if (controller.isClosed) return;
        controller.add(chunk);
      }
    } catch (error, stackTrace) {
      if (controller.hasListener && !controller.isClosed) {
        controller.addError(error, stackTrace);
      }
    } finally {
      if (!controller.isClosed) {
        await controller.close();
      } else {
        cancellation.cancel();
      }
    }
  }

  AiCancellationToken _operationToken(
    AiCancellationToken? callerCancellation,
  ) {
    final operation = AiCancellationToken();
    callerCancellation?.whenCancelled.then((_) => operation.cancel());
    return operation;
  }

  Future<String> _getToken(AiCancellationToken cancellation) async {
    cancellation.throwIfCancelled();
    try {
      final value = await Future.any<String?>([
        tokenProvider(),
        cancellation.whenCancelled.then<String?>(
          (_) => throw AiException.cancelled(),
        ),
      ]).timeout(
        config.timeout,
        onTimeout: () {
          cancellation.cancel();
          throw TimeoutException('AI token request timed out.');
        },
      );
      final normalized = value?.trim();
      if (normalized == null || normalized.isEmpty) {
        throw AiException.missingCredentials();
      }
      return normalized;
    } on AiException {
      rethrow;
    } on TimeoutException {
      throw AiException.timeout();
    } catch (_) {
      if (cancellation.isCancelled) throw AiException.cancelled();
      throw AiException.network();
    }
  }

  Future<_AiHttpResponse> _sendWithRetries({
    required String prompt,
    required String token,
    required AiCancellationToken cancellation,
    required bool streaming,
  }) async {
    for (var attempt = 0; ; attempt++) {
      cancellation.throwIfCancelled();
      final attemptCancellation = AiCancellationToken();
      cancellation.whenCancelled.then((_) => attemptCancellation.cancel());
      try {
        final request = http.AbortableRequest(
          'POST',
          config.chatCompletionsUri,
          abortTrigger: attemptCancellation.whenCancelled,
        )
          ..headers.addAll({
            'content-type': 'application/json',
            'authorization': 'Bearer $token',
          })
          ..body = jsonEncode({
            'model': config.model,
            'messages': [
              {'role': 'user', 'content': prompt},
            ],
            'stream': streaming,
          });

        final response = await Future.any<http.StreamedResponse>([
          _httpClient.send(request),
          attemptCancellation.whenCancelled.then<http.StreamedResponse>(
            (_) => throw AiException.cancelled(),
          ),
        ]).timeout(
          config.timeout,
          onTimeout: () {
            attemptCancellation.cancel();
            throw TimeoutException('AI request timed out.');
          },
        );

        final retryableStatus =
            response.statusCode == 429 || response.statusCode >= 500;
        if (retryableStatus && attempt < config.maxRetries) {
          await response.stream.listen(null).cancel();
          attemptCancellation.cancel();
          await _waitBeforeRetry(attempt, cancellation);
          continue;
        }
        return _AiHttpResponse(response, attemptCancellation);
      } on AiException {
        rethrow;
      } on TimeoutException {
        attemptCancellation.cancel();
        if (cancellation.isCancelled) throw AiException.cancelled();
        if (attempt >= config.maxRetries) throw AiException.timeout();
        await _waitBeforeRetry(attempt, cancellation);
      } on http.ClientException {
        attemptCancellation.cancel();
        if (cancellation.isCancelled) throw AiException.cancelled();
        if (attempt >= config.maxRetries) throw AiException.network();
        await _waitBeforeRetry(attempt, cancellation);
      } catch (_) {
        attemptCancellation.cancel();
        if (cancellation.isCancelled) throw AiException.cancelled();
        if (attempt >= config.maxRetries) throw AiException.network();
        await _waitBeforeRetry(attempt, cancellation);
      }
    }
  }

  Future<void> _waitBeforeRetry(
    int attempt,
    AiCancellationToken cancellation,
  ) async {
    cancellation.throwIfCancelled();
    final milliseconds =
        config.retryBaseDelay.inMilliseconds * (1 << attempt);
    final delay = Duration(
      milliseconds: milliseconds.clamp(
        1,
        config.maxRetryDelay.inMilliseconds,
      ).toInt(),
    );
    await Future.any<void>([
      Future<void>.delayed(delay),
      cancellation.whenCancelled.then<void>(
        (_) => throw AiException.cancelled(),
      ),
    ]);
  }

  Future<String> _readBody(
    http.StreamedResponse response,
    AiCancellationToken cancellation,
  ) async {
    try {
      return await Future.any<String>([
        response.stream.transform(utf8.decoder).join(),
        cancellation.whenCancelled.then<String>(
          (_) => throw AiException.cancelled(),
        ),
      ]).timeout(
        config.timeout,
        onTimeout: () {
          cancellation.cancel();
          throw TimeoutException('AI response body timed out.');
        },
      );
    } on AiException {
      rethrow;
    } on TimeoutException {
      throw AiException.timeout();
    } on http.ClientException {
      if (cancellation.isCancelled) throw AiException.cancelled();
      throw AiException.network();
    } catch (_) {
      if (cancellation.isCancelled) throw AiException.cancelled();
      throw AiException.network();
    }
  }

  Stream<String> _decodeEvents(
    http.StreamedResponse response,
    AiCancellationToken cancellation,
  ) async* {
    final dataLines = <String>[];
    try {
      await for (final line
          in response.stream
              .transform(utf8.decoder)
              .transform(const LineSplitter())
              .timeout(config.timeout)) {
        cancellation.throwIfCancelled();
        if (line.isEmpty) {
          final data = dataLines.join('\n');
          dataLines.clear();
          if (data == '[DONE]') return;
          if (data.isNotEmpty) {
            final text = _extractDelta(data);
            if (text != null && text.isNotEmpty) yield text;
          }
        } else if (line.startsWith('data:')) {
          dataLines.add(line.substring(5).trimLeft());
        }
      }
      if (dataLines.isNotEmpty) {
        final data = dataLines.join('\n');
        if (data != '[DONE]') {
          final text = _extractDelta(data);
          if (text != null && text.isNotEmpty) yield text;
        }
      }
    } on AiException {
      rethrow;
    } on TimeoutException {
      cancellation.cancel();
      throw AiException.timeout();
    } on FormatException {
      throw AiException.invalidResponse();
    } on http.ClientException {
      if (cancellation.isCancelled) throw AiException.cancelled();
      throw AiException.network();
    } catch (_) {
      if (cancellation.isCancelled) throw AiException.cancelled();
      throw AiException.network();
    }
  }

  String? _extractDelta(String data) {
    final decoded = jsonDecode(data);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Expected an event object.');
    }
    final choices = decoded['choices'];
    if (choices is! List || choices.isEmpty) return null;
    final first = choices.first;
    if (first is! Map<String, dynamic>) {
      throw const FormatException('Invalid stream choice.');
    }
    final delta = first['delta'];
    if (delta is! Map<String, dynamic>) return null;
    final content = delta['content'];
    if (content == null) return null;
    if (content is! String) {
      throw const FormatException('Invalid stream content.');
    }
    return content;
  }

  void _throwForStatus(_AiHttpResponse result) {
    final statusCode = result.response.statusCode;
    if (statusCode >= 200 && statusCode < 300) return;
    result.cancellation.cancel();
    if (statusCode == 401 || statusCode == 403) {
      throw AiException(
        'The AI service rejected the supplied credentials.',
        statusCode: statusCode,
        type: AiErrorType.authentication,
      );
    }
    if (statusCode == 429) {
      throw AiException.rateLimit(statusCode: statusCode);
    }
    throw AiException.network(statusCode: statusCode);
  }

  void _validatePrompt(String prompt) {
    if (prompt.trim().isEmpty) {
      throw ArgumentError.value(prompt, 'prompt', 'Prompt must not be empty.');
    }
  }

  @override
  void close() {
    if (_ownsHttpClient) _httpClient.close();
  }
}

class _AiHttpResponse {
  const _AiHttpResponse(this.response, this.cancellation);

  final http.StreamedResponse response;
  final AiCancellationToken cancellation;
}
