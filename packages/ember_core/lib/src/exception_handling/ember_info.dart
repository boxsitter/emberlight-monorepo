import 'package:ember_core/src/exception_handling/logable.dart';

abstract class EmberInfo extends Logable{

  final String? userTitle;
  final String? userMessage;

  const EmberInfo({
    this.userTitle,
    this.userMessage,
    required super.timestamp,
    required super.module,
    required super.devMessage,
    super.metadata,
    required super.logType,
  });

}

class QuickLog extends EmberInfo {
  QuickLog(String message) : super(
    module: Module.quickLog,
    timestamp: DateTime.now(),
    devMessage: message,
    logType: LogType.quickLog,
  );
}
