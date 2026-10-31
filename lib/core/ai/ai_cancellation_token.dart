import 'dart:async';

import 'ai_exception.dart';

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
      throw AiException.cancelled();
    }
  }
}
