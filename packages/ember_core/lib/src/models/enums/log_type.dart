import 'ansi_color.dart';

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