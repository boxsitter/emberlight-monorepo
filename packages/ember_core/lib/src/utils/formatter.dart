import 'package:intl/intl.dart';

import '../exception_handling/logable.dart';

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
  static String formatAnsi({required String text, AnsiColor? color, AnsiStyle? style,}) {
    final buffer = StringBuffer();

    // Add style code if provided
    if (style != null && style != AnsiStyle.reset) {
      buffer.write(style.code);
    }

    // Add color code if provided
    if (color != null && color != AnsiColor.reset) {
      buffer.write(color.code);
    }

    // Add the actual text
    buffer.write(text);

    // Add reset codes to ensure subsequent text is not affected
    if (color != null && color != AnsiColor.reset) {
      buffer.write(AnsiColor.reset.code);
    }
    if (style != null && style != AnsiStyle.reset) {
      // Only add style reset if a style was applied.
      // The color reset also resets style, but being explicit can be clearer.
      // However, adding style reset *after* color reset is redundant.
      // A single reset code (\x1B[0m) resets all attributes.
      // Let's rely on the color reset or add a single reset at the end if no color was used.
    } else if (color == null && style != null && style != AnsiStyle.reset) {
      // If only style was applied, add a single reset
      buffer.write(AnsiStyle.reset.code);
    } else if (color != null || (style != null && style != AnsiStyle.reset)) {
      // If either color or style (or both) were applied, a single reset is sufficient.
      // The color reset code (\x1B[0m) resets all attributes (color and style).
      // So, we only need to ensure a reset is added if any formatting was applied.
      // The color reset check above already handles the case where color is used.
      // If only style was used, we need to add the reset.
      // Let's simplify: add reset if *any* formatting was applied.
      buffer.write(AnsiColor.reset.code); // AnsiColor.reset.code is \x1B[0m
    }


    return buffer.toString();
  }

  static AnsiColor logTypeToAnsiColor(LogType type) {
    switch (type) {
      case LogType.failure:
        return AnsiColor.yellow;
      case LogType.error:
        return AnsiColor.brightRed;
      case LogType.critical:
        return AnsiColor.red;
      case LogType.info:
        return AnsiColor.white;
      case LogType.success:
        return AnsiColor.brightGreen;
      case LogType.warning:
        return AnsiColor.brightYellow;
    }
  }
}
