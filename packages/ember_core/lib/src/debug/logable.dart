import 'package:ember_core/ember_core_utils.dart';

enum LogType {
  failure('Failure', 'Action could not be completed', true, AnsiColor.yellow),
  unknown('Undefined Error', 'Something went wrong', false, AnsiColor.brightRed),
  error('Error', 'Error', false, AnsiColor.brightRed),
  critical('Critical Error', 'Critical error', false, AnsiColor.red),
  info('Info', 'Info', true, AnsiColor.brightCyan),
  success('Success', 'Success!', true, AnsiColor.brightGreen),
  warning('Warning', 'Warning', true, AnsiColor.brightYellow);

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
    String moduleString = CoreFormatter.formatAnsi(text: '[${module.name}]', color: AnsiColor.cyan);

    String secondPart = CoreFormatter.formatAnsi(
      text: logType != LogType.info ? ' ${logType.devString}: $devMessage' : ' $devMessage',
      color: logType.ansiColor,
      style: AnsiStyle.bold,
    );

    if (metadata.isEmpty) return moduleString + secondPart;

    String meta = '\n';
    for (var entry in metadata.entries) {
      meta += '- ${entry.key}: ${entry.value}\n';
    }

    String formattedMeta = CoreFormatter.formatAnsi(
      text: meta,
      color: logType.ansiColor,
    );

    if (stackTrace == null || logType == LogType.failure) return '$moduleString$secondPart${formattedMeta.trim()}';

    String colorfulStackTrace = CoreFormatter.formatAnsi(
      text: stackTrace.toString(),
      color: logType.ansiColor,
    );

    return moduleString + secondPart + formattedMeta + colorfulStackTrace;
  }

  @override
  String toString() {
    if (metadata.isEmpty) return '[${module.name}] ${logType.devString}: $devMessage';

    String meta = '';
    for (var entry in metadata.entries) {
      meta += '- ${entry.key}: ${entry.value}\n';
    }

    return '[${module.name}] ${logType.devString}: $devMessage\n${meta.trim()}';
  }

}