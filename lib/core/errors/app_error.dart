final class AppError {
  const AppError({
    required this.code,
    required this.message,
    this.cause,
    this.stackTrace,
  });

  /// Stable machine-readable identifier for this failure.
  final String code;

  /// Safe message suitable for presentation to the user.
  final String message;

  /// Optional diagnostic cause. Do not expose this in user-facing UI.
  final Object? cause;

  /// Optional diagnostic stack trace. Do not expose this in user-facing UI.
  final StackTrace? stackTrace;
}
