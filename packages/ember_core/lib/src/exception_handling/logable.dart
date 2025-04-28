import 'package:ember_core/ember_core_exception_handling.dart';

abstract class Logable {
  DateTime get timestamp;
  String get devMessage;
  Map<String, String> get metadata;
  ErrorSeverity get severity;
  @override
  String toString();
}