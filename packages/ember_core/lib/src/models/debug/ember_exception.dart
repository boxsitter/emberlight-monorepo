// lib/ember_core/src/error_handling/ember_exception.dart
import 'package:ember_core/ember_core_utils.dart';

import '../../../ember_core_debug.dart';

// warning: can be normally triggered by the user, doesn't cause issues, cancels action, user needs to be notified
// error: something has gone wrong, won't cause issues
// critical: something has gone very wrong and it is going to break something

/// -------------  Base class -------------
abstract class EmberException extends Logable implements Exception {
  final String? userMessage;
  bool isHandled = false;

  EmberException({
    this.userMessage,
    required super.module,
    required super.devMessage,
    super.metadata,
    required super.logType,
  });
}

extension UnknownExceptionWrapping on Object {
  EmberException toEmberException(StackTrace? stackTrace) {
    if (this is EmberException) return this as EmberException;
    return _UnknownEmberException(this, LogType.unknownError, stackTrace);
  }
}

class _UnknownEmberException extends EmberException {
  _UnknownEmberException(Object original, LogType type, StackTrace? stackTrace) : super(
    module: stackTrace != null ? CoreFormatter.extractModuleFromStackTrace(stackTrace) : Module.unknown,
    devMessage: original.toString(),
    logType: type,
  );
}
