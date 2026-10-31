import 'dart:async';

/// Cooperative cancellation signal shared by an AI operation and its caller.
class AiCancellationToken {
  final Completer<void> _completer = Completer<void>();

  bool get isCancelled => _completer.isCompleted;

  /// Completes once [cancel] is called.
  Future<void> get whenCancelled => _completer.future;

  void cancel() {
    if (!_completer.isCompleted) {
      _completer.complete();
    }
  }

  void throwIfCancelled() {
    if (isCancelled) {
      throw AiExceptionBridge.cancelled();
    }
  }
}

/// Keeps the cancellation primitive independent of the exception library's
/// implementation details while providing a single public cancellation API.
abstract final class AiExceptionBridge {
  static Exception cancelled() => const _AiOperationCancelled();
}

class _AiOperationCancelled implements Exception {
  const _AiOperationCancelled();
}
