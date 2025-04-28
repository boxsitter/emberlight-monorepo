// lib/ember_core/src/error_handling/ember_exception.dart
import 'package:ember_core/src/exception_handling/logable.dart';

// warning: can be normally triggered by the user, doesn't cause issues, cancels action, user needs to be notified
// error: something has gone wrong, won't cause issues
// critical: something has gone very wrong and it is going to break something

/// -------------  Base class -------------
abstract class EmberException extends Logable implements Exception {
  static const String defaultUserMessage = 'Something went wrong, please try again';
  final String? _userMessage;

  const EmberException({
    String? userMessage,
    required super.timestamp,
    required super.module,
    required super.devMessage,
    super.metadata,
    required super.logType,
  }) : _userMessage = userMessage;

  String? get userMessage {
    if (_userMessage != null) return _userMessage;
    if (logType != LogType.failure) return null;
    return defaultUserMessage;
  }
}

/// -------------  Helper -------------
extension UnknownExceptionWrapping on Object {
  /// Turn an arbitrary `Object` (an Error, Exception, String, etc.)
  /// into an `EmberException` so our handler can treat *everything* uniformly.
  EmberException toEmberException({
    LogType defaultSeverity = LogType.error,
  }) {
    if (this is EmberException) return this as EmberException;
    return _UnknownEmberException(this, defaultSeverity);
  }
}

/// Private fallback wrapper
class _UnknownEmberException extends EmberException {
  _UnknownEmberException(Object original, LogType sev)
      : super(timestamp: DateTime.now(), module: 'Unknown Exception', devMessage: original.toString(), logType: sev);
}
