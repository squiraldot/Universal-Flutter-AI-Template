import 'ai_cancellation_token.dart';

/// Provider-independent text-generation contract.
///
/// Feature code should depend on this interface, never on a provider adapter.
abstract interface class AiClient {
  Future<String> complete(
    String prompt, {
    AiCancellationToken? cancellationToken,
  });

  /// Emits incremental assistant text. Cancelling the subscription aborts the
  /// underlying request when the adapter supports HTTP request abortion.
  Stream<String> stream(
    String prompt, {
    AiCancellationToken? cancellationToken,
  });

  void close();
}
