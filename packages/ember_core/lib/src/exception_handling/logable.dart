import 'package:ember_core/ember_core_utils.dart';

enum LogType {
  softFailure('Failure', 'Action could not be completed', false, AnsiColor.yellow),
  seriousFailure('Failure', 'Action encountered an error', true, AnsiColor.yellow),
  unknown('Error', 'Something went wrong', true, AnsiColor.brightRed),
  error('Error', 'Error', true, AnsiColor.brightRed),
  critical('Critical Error', 'Critical error', true, AnsiColor.red),
  info('Info', 'Info', false, AnsiColor.brightCyan),
  quickLog('Log', 'Debug message', false, AnsiColor.brightCyan),
  success('Success', 'Success!', false, AnsiColor.brightGreen),
  warning('Warning', 'Warning', false, AnsiColor.brightYellow);

  final String devString;
  final String userString;
  final bool eatMe;
  final AnsiColor ansiColor;
  const LogType(this.devString, this.userString, this.eatMe, this.ansiColor);
}

enum Module {
  bessie('BESSIE'),
  core('CORE'),
  fire('FIRE'),
  quickLog('LOG'),
  unknown('UNKNOWN');

  final String name;
  const Module(this.name);
}

abstract class Logable {
  final DateTime timestamp;
  final Module module;
  final String devMessage;
  final Map<String, String> metadata;
  final LogType logType;

  const Logable({
    required this.timestamp,
    required this.module,
    required this.devMessage,
    this.metadata = const{},
    required this.logType,
  });

  String toStringColorful(StackTrace? stackTrace) {
    String meta = '';
    for (var entry in metadata.entries) {
      meta += '- ${entry.key}: ${entry.value}\n';
    }

    String moduleString = CoreFormatter.formatAnsi(text: '[${module.name}]', color: AnsiColor.cyan);

    String secondPart = CoreFormatter.formatAnsi(
      text: ' ${logType.devString}: $devMessage\n',
      color: logType.ansiColor,
      style: AnsiStyle.bold,
    );

    String formattedMeta = CoreFormatter.formatAnsi(
      text: meta,
      color: logType.ansiColor,
    );

    if (stackTrace == null) return moduleString + secondPart + meta;

    String colorfulStackTrace = CoreFormatter.formatAnsi(
      text: stackTrace.toString(),
      color: logType.ansiColor,
    );

    return moduleString + secondPart + formattedMeta + colorfulStackTrace;
  }

  @override
  String toString() {
    String meta = '';
    for (var entry in metadata.entries) {
      meta += '- ${entry.key}: ${entry.value}\n';
    }

    return '[$module] ${logType.devString}: $devMessage\n$meta';
  }

}