/// A user-safe error raised by the AI integration layer.
class AiException implements Exception {
  const AiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  factory AiException.missingCredentials() =>
      const AiException('AI credentials are not configured.');

  factory AiException.timeout() =>
      const AiException('The AI service took too long to respond.');

  factory AiException.network() =>
      const AiException('Could not connect to the AI service.');

  factory AiException.invalidResponse() =>
      const AiException('The AI service returned an unexpected response.');

  @override
  String toString() => message;
}
