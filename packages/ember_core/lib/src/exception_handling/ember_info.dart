import 'package:ember_core/src/exception_handling/logable.dart';

import '../../ember_core_exception_handling.dart';

abstract class EmberInfo implements Logable{
  @override
  final DateTime timestamp;
  @override
  final String devMessage;
  final String? userTitle;
  final String? userMessage;
  @override
  final Map<String, String> metadata;
  @override
  final ErrorSeverity severity = ErrorSeverity.info;

  const EmberInfo({
    required this.devMessage,
    this.userTitle,
    this.userMessage,
    this.metadata = const {},
    required this.timestamp,
  });

  @override
  String toString() =>
      '$runtimeType(Info): $devMessage  '
          '[userMessage: ${userTitle ?? "-"}]  '
          '[userMessage: ${userMessage ?? "-"}]  '
          '[context: $metadata]';

}
