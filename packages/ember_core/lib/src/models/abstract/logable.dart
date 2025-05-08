import 'package:ember_core/ember_core_utils.dart';

import '../../../ember_core_debug.dart';

enum LogType {
  failure(
    'Failure',
    'Oops',
    AnsiColor.yellow,
    Duration(milliseconds: 3500),
  ),

  unknownError(
    'Undefined Error',
    'Something went wrong',
    AnsiColor.brightRed,
    Duration(milliseconds: 4000),
  ),

  error(
    'Error',
    'Error',
    AnsiColor.brightRed,
    Duration(milliseconds: 4000),
  ),

  critical(
    'Critical Error',
    'Critical error',
    AnsiColor.red,
    Duration(milliseconds: 5000),
  ),

  info(
    'Info',
    'Info',
    AnsiColor.none,
    Duration(milliseconds: 2000),
  ),

  success(
    'Success',
    'Success!',
    AnsiColor.brightGreen,
    Duration(milliseconds: 2000),
  ),

  warning(
    'Warning',
    'Warning',
    AnsiColor.brightYellow,
    Duration(milliseconds: 3000),
  );

  final String devString;
  final String userString;
  final AnsiColor ansiColor;
  final Duration toastDuration;
  const LogType(this.devString, this.userString, this.ansiColor, this.toastDuration);
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

  Logable({
    required this.module,
    required this.devMessage,
    this.metadata = const{},
    required this.logType,
  }) : timestamp = DateTime.now();

  String toStringFormatted(StackTrace? stackTrace) {
    String output = '';

    // [Module Name]
    final String moduleName = '[${module.name}]';
    if (Debug.colorfulLogs) {
      output += CoreFormatter.formatAnsi(
        text: moduleName,
        color: logType == LogType.info || logType == LogType.success ? AnsiColor.cyan : AnsiColor.red,
      );
    } else {
      output += moduleName;
    }

    // [Module Name] Main Content
    final String mainContent = logType != LogType.info ? ' ${logType.devString}: $devMessage' : ' $devMessage';
    if (Debug.colorfulLogs) {
      output += CoreFormatter.formatAnsi(
        text: mainContent,
        color: logType.ansiColor,
      );
    } else {
      output += mainContent;
    }

    // [Module Name] Main Content
    // - Meta

    if (metadata.isNotEmpty) {
      String meta = '';
      meta += '\n';
      for (var entry in metadata.entries) {
        meta += '- ${entry.key}: ${entry.value}\n';
      }

      if (Debug.colorfulLogs) {
        output += CoreFormatter.formatAnsi(
          text: meta,
          color: logType.ansiColor,
        );
      } else {
        output += meta;
      }
    }

    // [Module Name] Main Content
    // - Meta
    // Stack Trace
    if (stackTrace != null) {
      String formattedStackTrace;
      if (Debug.simplifyStackTraces) {
        formattedStackTrace = CoreFormatter.simplifyStackTrace(stackTrace);
      } else {
        formattedStackTrace = stackTrace.toString();
      }

      if (Debug.colorfulLogs) {
        output += CoreFormatter.formatAnsi(
          text: formattedStackTrace,
          color: logType.ansiColor,
        );
      } else {
        output += formattedStackTrace;
      }
    }

    return  output;
  }

  @override
  String toString() {
    return toStringFormatted(null);
  }
}