import 'package:get/get.dart';

import 'controllers/console_controller.dart';

class CommandParser {
  final ConsoleController consoleController;
  CommandParser(this.consoleController);

  void runCommand(String input) {
    // Parse the input string
    final parts = input.split(' ');
    if (parts.isEmpty) return;

    final baseCommand = parts.first;
    final arguments = <String>[];
    final flags = <String, String?>{};

    // Process arguments and flags
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

    // Execute the command
    switch (baseCommand) {
      case 'cl' || 'clear':
        _clear();
        break;
      default:
        consoleController.log('Unknown command: $baseCommand');
    }
  }

  void _clear() {
    consoleController.clear();
  }
}
