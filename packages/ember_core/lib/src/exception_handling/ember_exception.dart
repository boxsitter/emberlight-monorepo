// lib/ember_core/src/error_handling/ember_exception.dart
import 'package:ember_core/src/exception_handling/logable.dart';

enum ErrorSeverity { info, warning, error, critical }
// warning: can be normally triggered by the user, doesn't cause issues, cancels action, user needs to be notified
// error: something has gone wrong, won't cause issues
// critical: something has gone very wrong and it is going to break something

/// -------------  Base class -------------
abstract class EmberException implements Exception, Logable {
  static const String defaultUserMessage = 'Something went wrong, please try again';

  @override
  final DateTime timestamp;

  /// A concise, dev-readable description of **what** went wrong.
  @override
  final String devMessage;

  /// Optional, safe-for-user snackbar / toast text.
  final String? _userMessage;

  /// Arbitrary extra data that might help a developer (e.g. ids, payloads…).
  @override
  final Map<String, String> metadata;

  /// How bad is it?
  @override
  final ErrorSeverity severity;

  const EmberException({
    required this.devMessage,
    String? userMessage,
    this.severity = ErrorSeverity.error,
    this.metadata = const {},
    required this.timestamp,
  }) : _userMessage = userMessage;

  String? get userMessage {
    if (_userMessage != null) return _userMessage;
    if (severity != ErrorSeverity.warning) return null;
    return defaultUserMessage;
  }

  @override
  String toString() =>
      '$runtimeType($severity): $devMessage  '
      '[userMessage: ${_userMessage ?? "-"}]  '
      '[context: $metadata]';
}

/// -------------  Helper -------------
extension UnknownExceptionWrapping on Object {
  /// Turn an arbitrary `Object` (an Error, Exception, String, etc.)
  /// into an `EmberException` so our handler can treat *everything* uniformly.
  EmberException toEmberException({
    ErrorSeverity defaultSeverity = ErrorSeverity.error,
  }) {
    if (this is EmberException) return this as EmberException;
    return _UnknownEmberException(this, defaultSeverity);
  }
}

/// Private fallback wrapper
class _UnknownEmberException extends EmberException {
  _UnknownEmberException(Object original, ErrorSeverity sev)
      : super(devMessage: original.toString(), severity: sev, timestamp: DateTime.now());
}
