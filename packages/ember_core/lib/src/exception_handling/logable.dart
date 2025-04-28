import 'package:ember_core/ember_core_utils.dart';

enum LogType {
  failure('Failure'),
  error('Error'),
  critical('Critical'),
  info('Info'),
  success('Success'),
  warning('Warning');

  final String asText;
  const LogType(this.asText);
}

abstract class Logable {
  final DateTime timestamp;
  final String module;
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

  @override
  String toString() {
    AnsiColor color = CoreFormatter.logTypeToAnsiColor(logType);
    AnsiStyle? style = logType == LogType.critical ? AnsiStyle.bold : null;

    String meta = '';
    for (var entry in metadata.entries) {
      meta += '    - ${entry.key}: ${entry.value}\n';
    }

    String moduleString = CoreFormatter.formatAnsi(text: '[$module]', color: AnsiColor.gray);

    String output =
        '[$module] ${logType.asString}: $devMessage'
        '\n$meta';

    return CoreFormatter.formatAnsi(text: output, color: color, style: style);

  }

}