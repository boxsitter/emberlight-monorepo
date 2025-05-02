import 'package:intl/intl.dart';

import '../models/abstract/logable.dart';

enum AnsiColor {
  // Standard colors
  black('\x1B[30m'),
  red('\x1B[31m'),
  green('\x1B[32m'),
  yellow('\x1B[33m'),
  blue('\x1B[34m'),
  magenta('\x1B[35m'),
  cyan('\x1B[36m'),
  white('\x1B[37m'),

  // Bright colors (often includes gray for bright black)
  gray('\x1B[90m'), // Often displayed as Gray
  brightRed('\x1B[91m'),
  brightGreen('\x1B[92m'),
  brightYellow('\x1B[93m'),
  brightBlue('\x1B[94m'),
  brightMagenta('\x1B[95m'),
  brightCyan('\x1B[96m'),
  brightWhite('\x1B[97m'),

  reset('\x1B[0m'); // Reset code

  final String code;
  const AnsiColor(this.code);
}

/// Defines ANSI escape codes for text styles.
enum AnsiStyle {
  bold('\x1B[1m'),
  italic('\x1B[3m'),
  underline('\x1B[4m'),
  strikethrough('\x1B[9m'),
  reset('\x1B[0m'); // Reset code

  final String code;
  const AnsiStyle(this.code);
}

class CoreFormatter {
  static String formatDate(DateTime? date) {
    date ??= DateTime.now();
    final onlyDate = DateFormat('dd/MM/yyyy').format(date);
    final onlyTime = DateFormat('hh:mm').format(date);
    return '$onlyDate at $onlyTime';
  }

  static String weekdayToString(int weekday, bool lowercase) {
    final weekdays = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];
    return lowercase ? weekdays[weekday - 1] : weekdays[weekday - 1].toUpperCase();
  }

  /// Formats a string with specified ANSI color and style.
  ///
  /// [text]: The string to format.
  /// [color]: The desired text color (optional).
  /// [style]: The desired text style (optional).
  ///
  /// Returns the formatted string with ANSI escape codes.
  static String formatAnsi({required String text, AnsiColor? color, AnsiStyle? style}) {
    final buffer = StringBuffer();

    final hasFormatting = (color != null && color != AnsiColor.reset) || (style != null && style != AnsiStyle.reset);

    if (style != null && style != AnsiStyle.reset) {
      buffer.write(style.code);
    }
    if (color != null && color != AnsiColor.reset) {
      buffer.write(color.code);
    }

    if (hasFormatting) {
      if (text.endsWith('\n')) {
        // Insert reset *before* the newline
        final withoutNewline = text.substring(0, text.length - 1);
        buffer.write(withoutNewline);
        buffer.write('\x1B[0m\n');
      } else {
        buffer.write(text);
        buffer.write('\x1B[0m');
      }
    } else {
      // No formatting applied, just write the text directly
      buffer.write(text);
    }

    return buffer.toString().trim();
  }

  static Module extractModuleFromStackTrace(StackTrace stackTrace) {
    final traceString = stackTrace.toString();
    final linesBackwards = traceString.split('\n');
    final lines = linesBackwards.reversed.toList();

    String moduleDirName = '';
    for (final line in lines) {
      final trimmed = line.trim();

      if (trimmed.startsWith('packages/')) {
        final afterPackages = trimmed.substring('packages/'.length);
        final parts = afterPackages.split('/');

        if (parts.isNotEmpty) {
          moduleDirName = parts.first;
        }
      }
    }

    switch (moduleDirName) {
      case 'bessie_app':
        return Module.bessie;
      case 'ember_core':
        return Module.core;
      case 'ember_fire':
        return Module.fire;
      default:
        return Module.unknown;
    }
  }

  /// Masks an email address for logging or display purposes, showing only the
  /// first character of the local part and the full domain.
  ///
  /// Examples:
  /// - 'john.doe@example.com' -> 'j*******@example.com'
  /// - 'a@domain.net' -> '*@domain.net'
  /// - 'invalid-email' -> '***'
  /// - null -> '***'
  static String maskEmail(String? email) {
    const String defaultMask = '***';

    if (email == null || email.isEmpty || !email.contains('@')) {
      return defaultMask;
    }

    final parts = email.split('@');
    // Ensure there's exactly one '@' symbol
    if (parts.length != 2) {
      return defaultMask;
    }

    final String localPart = parts[0];
    final String domain = parts[1];

    if (localPart.isEmpty) {
      // Handle emails starting with '@' (though unusual)
      return '$defaultMask@$domain';
    }

    if (localPart.length == 1) {
      // If local part is only one character, mask it
      return '*@$domain';
    }

    // Keep the first character, replace the rest with '*'
    final String maskedLocalPart = localPart[0] + ('*' * (localPart.length - 1));

    return '$maskedLocalPart@$domain';
  }

  static String simplifyStackTrace(StackTrace? stackTrace) {
    List<String> userPackagePrefixes = const ['package\\'];

    const String placeholder = '[No stack trace available]';
    if (stackTrace == null) {
      return placeholder;
    }

    final String fullTrace = stackTrace.toString();
    if (fullTrace.trim().isEmpty) {
      return placeholder;
    }

    final List<String> lines = fullTrace.split('\n');
    final List<String> formattedLines = [];
    int externalLinesCount = 0;

    bool isUserCodeLine(String line) {
      // Check if the line contains any of the specified user package prefixes
      // We look after the initial frame info (e.g., "#5 ")
      final contentStartIndex = line.indexOf('(');
      if (contentStartIndex != -1) {
        final relevantPart = line.substring(contentStartIndex);
        for (final prefix in userPackagePrefixes) {
          if (relevantPart.contains(prefix)) {
            return true;
          }
        }
      }
      // Lines without typical package info might be internal/VM/async gaps
      // Consider them external unless specifically needed otherwise.
      return false;
    }

    for (final line in lines) {
      final trimmedLine = line.trim();
      if (trimmedLine.isEmpty) continue; // Skip empty lines

      if (isUserCodeLine(trimmedLine)) {
        // Found a user code line. First, add collapsed count if any.
        if (externalLinesCount > 0) {
          formattedLines.add('[... $externalLinesCount external lines collapsed ...]');
          externalLinesCount = 0; // Reset counter
        }
        // Then, add the user code line itself
        formattedLines.add(trimmedLine);
      } else {
        // It's an external line, just increment the counter
        externalLinesCount++;
      }
    }

    // Add any remaining collapsed count at the end
    if (externalLinesCount > 0) {
      formattedLines.add('[... $externalLinesCount external lines collapsed ...]');
    }

    return formattedLines.join('\n');
  }
}
