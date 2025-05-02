import 'ember_exception.dart';
import 'logable.dart';

class ExceptionTest extends EmberException {
  ExceptionTest() : super(
    module: Module.core,
    devMessage: 'Minor failure exception',
    logType: LogType.error,
    userMessage: 'Operation failed',
    metadata: {
      'string1': 'hello world',
      'string2': 'hello world',
      'string3': 'hello world',
      'string4': 'hello world',
      'string5': 'hello world',
      'string6': 'hello world',
      'string7': 'hello world',
    }
  );
}

class CoreUninitializedError extends EmberException {
  CoreUninitializedError(String devMessage) : super(
      module: Module.core,
    logType: LogType.error,
      devMessage: devMessage,

  );
}

class CoreUnsupportedError extends EmberException {
  CoreUnsupportedError(String devMessage) : super(
    module: Module.core,
    logType: LogType.error,
    devMessage: devMessage,
  );
}