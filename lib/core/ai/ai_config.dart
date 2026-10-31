/// Configuration for an OpenAI-compatible chat-completions endpoint.
///
/// [baseUrl] is the API root (for example, `https://api.example.com/v1`),
/// not the full `/chat/completions` endpoint. Never put API keys in this
/// object or in source-controlled configuration.
class AiConfig {
  AiConfig({
    required this.baseUrl,
    required this.model,
    this.timeout = const Duration(seconds: 30),
    this.maxRetries = 2,
    this.retryBaseDelay = const Duration(milliseconds: 250),
    this.maxRetryDelay = const Duration(seconds: 2),
  }) {
    if ((baseUrl.scheme != 'https' && baseUrl.scheme != 'http') ||
        baseUrl.host.isEmpty ||
        baseUrl.userInfo.isNotEmpty ||
        baseUrl.hasQuery ||
        baseUrl.hasFragment) {
      throw ArgumentError.value(
        baseUrl,
        'baseUrl',
        'Use an HTTP(S) API root without credentials, query, or fragment.',
      );
    }
    if (model.trim().isEmpty) {
      throw ArgumentError.value(model, 'model', 'Model must not be empty.');
    }
    if (timeout <= Duration.zero) {
      throw ArgumentError.value(
        timeout,
        'timeout',
        'Timeout must be greater than zero.',
      );
    }
    if (maxRetries < 0 || maxRetries > 5) {
      throw ArgumentError.value(
        maxRetries,
        'maxRetries',
        'Retries must be between zero and five.',
      );
    }
    if (retryBaseDelay <= Duration.zero ||
        maxRetryDelay < retryBaseDelay) {
      throw ArgumentError('Retry delays must be positive and bounded.');
    }
  }

  final Uri baseUrl;
  final String model;
  final Duration timeout;

  /// Number of retries after the first attempt (0–5).
  final int maxRetries;
  final Duration retryBaseDelay;
  final Duration maxRetryDelay;

  /// Builds the chat-completions URI while preserving any API path prefix.
  Uri get chatCompletionsUri {
    final root = baseUrl.toString().replaceFirst(RegExp(r'/+$'), '');
    return Uri.parse('$root/chat/completions');
  }
}
