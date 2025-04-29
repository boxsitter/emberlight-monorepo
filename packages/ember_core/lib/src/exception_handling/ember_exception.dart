// lib/ember_core/src/error_handling/ember_exception.dart
import 'package:ember_core/ember_core_utils.dart';
import 'package:ember_core/src/exception_handling/logable.dart';

// warning: can be normally triggered by the user, doesn't cause issues, cancels action, user needs to be notified
// error: something has gone wrong, won't cause issues
// critical: something has gone very wrong and it is going to break something

/// -------------  Base class -------------
abstract class EmberException extends Logable implements Exception {
  final String? userMessage;
  final bool reportToSentry;

  const EmberException({
    this.userMessage,
    this.reportToSentry = false,
    required super.timestamp,
    required super.module,
    required super.devMessage,
    super.metadata,
    required super.logType,
  });
}

extension UnknownExceptionWrapping on Object {
  EmberException toEmberException(StackTrace? stackTrace) {
    if (this is EmberException) return this as EmberException;
    return _UnknownEmberException(this, LogType.unknown, stackTrace);
  }
}

class _UnknownEmberException extends EmberException {
  _UnknownEmberException(Object original, LogType type, StackTrace? stackTrace) : super(
    timestamp: DateTime.now(),
    module: stackTrace != null ? CoreFormatter.extractModuleFromStackTrace(stackTrace) : Module.unknown,
    devMessage: original.toString(),
    logType: type,
  );
}
