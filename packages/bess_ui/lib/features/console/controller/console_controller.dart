import 'package:bessie/features/session_roster/controllers/session_roster_controller.dart';
import 'package:get/get.dart';
import 'package:xterm/core.dart';

import '../../../common/data/models/camper.dart';
import '../../../common/data/models/local_data.dart';
import 'feature-commands/session_roster_commands.dart';

class ConsoleController extends GetxController {
  final List<String> history = [];
  int historyIndex = -1;
  String _prompt = 'home❯ ';
  String inputBuffer = '';
  SessionRosterCommands commands = SessionRosterCommands();

  late final Terminal terminal;

  @override
  void onInit() {
    super.onInit();

    // Initialize terminal with a line buffer
    terminal = Terminal(
      maxLines: 10000,
      onOutput: (String key) {
        if (key == '\x1B[A') { // Up arrow
          if (history.isNotEmpty && historyIndex > 0) {
            historyIndex--;
            _replaceInputBuffer(history[historyIndex]);
          }
        } else if (key == '\x1B[B') { // Down arrow
          if (history.isNotEmpty && historyIndex < history.length - 1) {
            historyIndex++;
            _replaceInputBuffer(history[historyIndex]);
          } else if (historyIndex == history.length - 1) {
            historyIndex++;
            _replaceInputBuffer('');
          }
        } else if (key == '\x1B[D' || key == '\x1B[C') {
          // Disable left and right arrows
          // Do nothing
        } else {
          _handleInput(key); // Pass other keys to your input handler
        }
      },
    );

    // Display the initial prompt
    _writePrompt();
  }

  void _writePrompt() {
    terminal.write('\r');
    terminal.write('\x1B[1;32m$_prompt\x1B[0m'); // Green prompt
  }

  void _handleInput(String data) {
    for (var char in data.split('')) {
      switch (char) {
        case '\r': // Enter key
          terminal.write('\r'); // Move to a new line
          runCommand(inputBuffer);
          if (inputBuffer != 'cl' && inputBuffer != 'clear') {
            terminal.write('\n');
          }
          inputBuffer = '';
          _writePrompt();
          break;
        case '\b': // Backspace key
        case '\u007F': // Handle Delete key (sends '\u007F' on some systems)
          if (inputBuffer.isNotEmpty) {
            inputBuffer = inputBuffer.substring(0, inputBuffer.length - 1);
            // Send backspace to visually erase the character
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
          terminal.write(char); // Display character
      }
    }
  }

  void _replaceInputBuffer(String newInput) {
    while (inputBuffer.isNotEmpty) {
      terminal.write('\b \b'); // Clear current buffer visually
      inputBuffer = inputBuffer.substring(0, inputBuffer.length - 1);
    }
    inputBuffer = newInput;
    terminal.write(newInput); // Write new input to terminal
  }

  void log(String text) {
    final adjustedText = text.replaceAll('\n', '\r\n ');
    terminal.write('\r\n\x1B[96m $adjustedText\x1B[0m');
  }

  set prompt(String value) {
    _prompt = value;
  }

  void runCommand(String input) {
    if (history.isEmpty || history.last != input) {
      history.add(input); // Add only if it’s not identical to the last command
    }
    historyIndex = history.length;

    // Parse the input string
    final parts = input.split(' ');
    if (parts.isEmpty) return;

    final baseCommand = parts.first;
    final arguments = <String>[];
    final flags = <String, String?>{};

    // Process arguments and flags
    parseCommand(parts, flags, arguments);

    // Execute the command
    switch (baseCommand) {
      case 'cl' || 'clear':
        terminal.write('\x1B[2J\x1B[H');
        break;
      case 'echo':
        final echoOutput = parts.sublist(1).join(' ');
        log(echoOutput);
        break;
      case 'setprompt':
        _prompt = '${arguments[0]}❯ ';
      default:
        commands.runCommand(baseCommand, arguments, flags);
    }
  }

  void parseCommand(List<String> parts, Map<String, String?> flags, List<String> arguments) {
    for (var i = 1; i < parts.length; i++) {
      final part = parts[i];
      if (part.startsWith('--')) {
        // Long flag
        if (part.contains('=')) {
          final split = part.split('=');
          flags[split[0].substring(2)] = split[1];
        } else {
          flags[part.substring(2)] = null;
        }
      } else if (part.startsWith('-')) {
        // Short flag
        final split = part.substring(1).split('');
        for (var flag in split) {
          flags[flag] = null;
        }
      } else {
        // Positional argument
        arguments.add(part);
      }
    }
  }
}
