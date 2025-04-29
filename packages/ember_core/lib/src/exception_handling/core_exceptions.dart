import '../../ember_core_exception_handling.dart';
import 'logable.dart';

class ExceptionTest extends EmberException {
  ExceptionTest() : super(
    timestamp: DateTime.now(),
    module: Module.core,
    devMessage: 'Minor failure exception',
    logType: LogType.seriousFailure,
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