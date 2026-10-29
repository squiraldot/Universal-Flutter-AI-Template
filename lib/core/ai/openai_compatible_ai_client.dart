import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'ai_config.dart';
import 'ai_exception.dart';

/// Supplies a short-lived access token at request time.
///
/// Implement this with a secure backend/session flow. Do not hardcode API
/// keys in the Flutter application or ship provider secrets in the APK.
typedef AiTokenProvider = Future<String?> Function();

/// Minimal client for APIs implementing the OpenAI chat-completions format.
class OpenAiCompatibleAiClient {
  OpenAiCompatibleAiClient({
    required this.config,
    required AiTokenProvider tokenProvider,
    http.Client? httpClient,
  })  : _tokenProvider = tokenProvider,
        _httpClient = httpClient ?? http.Client(),
        _ownsHttpClient = httpClient == null;

  final AiConfig config;
  final AiTokenProvider _tokenProvider;
  final http.Client _httpClient;
  final bool _ownsHttpClient;

  /// Sends a user prompt and returns the assistant's text response.
  ///
  /// This intentionally exposes only the small text-chat surface needed by
  /// many apps. Provider-specific features can be added behind this boundary.
  Future<String> complete(String prompt) async {
    if (prompt.trim().isEmpty) {
      throw ArgumentError.value(prompt, 'prompt', 'Prompt must not be empty.');
    }

    final token = (await _tokenProvider())?.trim();
    if (token == null || token.isEmpty) {
      throw AiException.missingCredentials();
    }

    late final http.Response response;
    try {
      response = await _httpClient
          .post(
            config.chatCompletionsUri,
            headers: <String, String>{
              'content-type': 'application/json',
              'authorization': 'Bearer $token',
            },
            body: jsonEncode(<String, Object>{
              'model': config.model,
              'messages': <Map<String, String>>[
                <String, String>{'role': 'user', 'content': prompt.trim()},
              ],
            }),
          )
          .timeout(config.timeout);
    } on TimeoutException {
      throw AiException.timeout();
    } on http.ClientException {
      throw AiException.network();
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      // Do not surface raw provider bodies; they may contain sensitive data.
      throw AiException(
        'The AI service request failed.',
        statusCode: response.statusCode,
      );
    }

    try {
      final decoded = jsonDecode(response.body);
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

  /// Closes the underlying client only when this class created it.
  void close() {
    if (_ownsHttpClient) {
      _httpClient.close();
    }
  }
}
