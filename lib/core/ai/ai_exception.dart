/// Stable categories for failures crossing the AI client boundary.
enum AiErrorType {
  network,
  authentication,
  rateLimit,
  invalidResponse,
  timeout,
  cancelled,
}

/// A user-safe error raised by the AI integration layer.
///
/// Provider response bodies and credentials are deliberately never included.
class AiException implements Exception {
  const AiException(
    this.message, {
    this.statusCode,
    this.type = AiErrorType.network,
  });

  final String message;
  final int? statusCode;
  final AiErrorType type;

  factory AiException.missingCredentials() => const AiException(
    'AI credentials are not configured.',
    type: AiErrorType.authentication,
  );

  factory AiException.timeout() => const AiException(
    'The AI service took too long to respond.',
    type: AiErrorType.timeout,
  );

  factory AiException.network({int? statusCode}) => AiException(
    'Could not connect to the AI service.',
    statusCode: statusCode,
    type: AiErrorType.network,
  );

  factory AiException.rateLimit({int? statusCode}) => AiException(
    'The AI service is receiving too many requests. Try again shortly.',
    statusCode: statusCode,
    type: AiErrorType.rateLimit,
  );

  factory AiException.invalidResponse() => const AiException(
    'The AI service returned an unexpected response.',
    type: AiErrorType.invalidResponse,
  );

  factory AiException.cancelled() => const AiException(
    'The AI request was cancelled.',
    type: AiErrorType.cancelled,
  );

  @override
  String toString() => message;
}
