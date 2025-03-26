enum ExceptionSeverity {
  error,
  warning,
  info,
}

abstract class AppException implements Exception {
  final String message;
  final bool alertUser;
  final ExceptionSeverity severity;

  AppException({
    required this.message,
    this.alertUser = true,
    this.severity = ExceptionSeverity.error,
  });

  @override
  String toString() => '$runtimeType: $message';
}

class InvalidSessionPathException extends AppException {
  InvalidSessionPathException({
    super.alertUser,
    super.message = "Invalid session path.",
  });
}

