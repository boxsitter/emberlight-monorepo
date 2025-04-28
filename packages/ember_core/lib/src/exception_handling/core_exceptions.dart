import '../../ember_core_exception_handling.dart';

class ExceptionTest extends EmberException {
  ExceptionTest() : super(
    devMessage: 'OMG there was a fucking error!',
    severity: ErrorSeverity.warning,
    timestamp: DateTime.now(),
    userMessage: 'There was a fucking error!',
  );
}