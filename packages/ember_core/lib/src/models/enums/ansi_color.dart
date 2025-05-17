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

  reset('\x1B[0m'), // Reset code
  none('');

  final String code;
  const AnsiColor(this.code);
}