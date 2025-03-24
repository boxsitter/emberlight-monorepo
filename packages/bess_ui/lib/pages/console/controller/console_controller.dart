import 'package:get/get.dart';
import 'package:xterm/core.dart';

class ConsoleController extends GetxController {
  static final ConsoleController _instance = ConsoleController._internal();

  factory ConsoleController() {
    return _instance;
  }

  ConsoleController._internal();

  // Terminal / Input
  late final Terminal terminal;
  final List<String> history = [];
  int historyIndex = -1;
  String _prompt = 'home❯ ';
  String inputBuffer = '';

  @override
  void onInit() {
    super.onInit();
    // Initialize terminal
    terminal = Terminal(
      maxLines: 10000,
      onOutput: (String key) {
        if (key == '\x1B[A') {
          // Up arrow
          if (history.isNotEmpty && historyIndex > 0) {
            historyIndex--;
            _replaceInputBuffer(history[historyIndex]);
          }
        } else if (key == '\x1B[B') {
          // Down arrow
          if (history.isNotEmpty && historyIndex < history.length - 1) {
            historyIndex++;
            _replaceInputBuffer(history[historyIndex]);
          } else if (historyIndex == history.length - 1) {
            historyIndex++;
            _replaceInputBuffer('');
          }
        } else if (key == '\x1B[D' || key == '\x1B[C') {
          // Disable left and right arrows (do nothing)
        } else {
          _handleInput(key);
        }
      },
    );

    // Display the initial prompt
    writePrompt();
  }

  // -------------
  // Core Methods
  // -------------

  void writePrompt() {
    terminal.write('\r');
    terminal.write('\x1B[1;32m$_prompt\x1B[0m'); // Green prompt
  }

  void _handleInput(String data) {
    for (var char in data.split('')) {
      switch (char) {
        case '\r': // Enter key
          terminal.write('\r');
          runCommand(inputBuffer);
          // If the command was clear, we’ve already re-printed the prompt
          // but for all else, we add a new line and re-print the prompt.
          if (inputBuffer != 'clear') {
            terminal.write('\n');
          }
          inputBuffer = '';
          writePrompt();
          break;

        case '\b': // Backspace
        case '\u007F': // Some systems send delete as '\u007F'
          if (inputBuffer.isNotEmpty) {
            inputBuffer = inputBuffer.substring(0, inputBuffer.length - 1);
            // Erase visually
            terminal.write('\b \b');
          }
          break;

        case '\x1B[A': // Up arrow
          if (history.isNotEmpty && historyIndex > 0) {
            historyIndex--;
            _replaceInputBuffer(history[historyIndex]);
          }
          break;

        case '\x1B[B': // Down arrow
          if (history.isNotEmpty && historyIndex < history.length - 1) {
            historyIndex++;
            _replaceInputBuffer(history[historyIndex]);
          } else {
            _replaceInputBuffer('');
          }
          break;

        default:
          inputBuffer += char;
          terminal.write(char);
      }
    }
  }

  void _replaceInputBuffer(String newInput) {
    // Clear current buffer visually
    while (inputBuffer.isNotEmpty) {
      terminal.write('\b \b');
      inputBuffer = inputBuffer.substring(0, inputBuffer.length - 1);
    }
    // Set new
    inputBuffer = newInput;
    terminal.write(newInput);
  }

  // ----------------
  // Logging / Output
  // ----------------

  void log(String text) {
    final adjustedText = text.replaceAll('\n', '\r\n ');
    terminal.write('\r\n\x1B[96m $adjustedText\x1B[0m');
  }

  void error(String text) {
    final adjustedText = text.replaceAll('\n', '\r\n ');
    terminal.write('\r\n\x1B[91m $adjustedText\x1B[0m');
  }

  void success(String text) {
    final adjustedText = text.replaceAll('\n', '\r\n ');
    terminal.write('\r\n\x1B[92m $adjustedText\x1B[0m');
  }

  // -------------
  // Prompt setter
  // -------------

  set prompt(String value) {
    _prompt = '$value❯ ';
  }

  // -------------
  // Command Logic
  // -------------

  void runCommand(String input) {
    if (input.trim().isEmpty) return;

    // Avoid duplicating the last command in history
    if (history.isEmpty || history.last != input) {
      history.add(input);
    }
    historyIndex = history.length;

    final parts = input.split(' ');
    if (parts.isEmpty) return;

    final baseCommand = parts.first;
    final flags = <String, String?>{};
    final arguments = <String>[];

    parseCommand(parts, flags, arguments);

    // Single switch statement for all commands:
    switch (baseCommand) {
      case 'clear':
        _clearScreen();
        return;

      default:
        error('Command not found, type "help" for a list of commands');
        break;
    }
  }

  /// Simple argument parser that collects flags/args.
  /// Example usage:  `mycmd -abc --fullName=foo bar1 bar2`
  ///   =>  flags={a:null, b:null, c:null, fullName:'foo'}, arguments=[bar1, bar2]
  void parseCommand(List<String> parts, Map<String, String?> flags, List<String> arguments) {
    for (var i = 1; i < parts.length; i++) {
      final part = parts[i];
      if (part.startsWith('--')) {
        // Long flag
        if (part.contains('=')) {
          final split = part.split('=');
          final flagName = split[0].substring(2);
          final flagValue = split[1];
          flags[flagName] = flagValue;
        } else {
          flags[part.substring(2)] = null;
        }
      } else if (part.startsWith('-')) {
        // Short flag(s)
        for (var c in part.substring(1).split('')) {
          flags[c] = null;
        }
      } else {
        // Positional argument
        arguments.add(part);
      }
    }
  }

  // -------------
  // Command Helpers
  // -------------

  void _clearScreen() {
    terminal.write('\x1B[2J\x1B[H'); // ANSI clear screen
    // Prompt is automatically re-written in _handleInput after "Enter"
    // but you might want to re-issue it here too:
    writePrompt();
  }
}
