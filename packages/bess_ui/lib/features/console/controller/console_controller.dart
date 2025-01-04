import 'package:get/get.dart';
import 'package:xterm/core.dart';

import '../../../common/data/abstract/command.dart';
import '../../../common/data/abstract/command_set.dart';
import 'feature_commands/session_roster_commands.dart';

class ConsoleController extends GetxController {
  static final ConsoleController _instance = ConsoleController._internal();

  final List<String> history = [];
  int historyIndex = -1;
  String _prompt = 'home❯ ';
  String inputBuffer = '';

  final Map<String, Command> globalCommands = <String, Command>{};
  final Map<String, CommandSet> features = <String, CommandSet>{};
  CommandSet? currentFeatureCommands;

  late final Terminal terminal;

  factory ConsoleController() {
    return _instance;
  }

  ConsoleController._internal()
  {
    initializeGlobalCommands();
    initializeFeatures();
  }

  void initializeGlobalCommands() {
    globalCommands['clear'] = Clear();
    globalCommands['ls'] = Ls();
    globalCommands['cd'] = Cd();
    globalCommands['help'] = Help();
  }

  void initializeFeatures() {
    features['sessionRoster'] = SessionRosterCommands();
  }

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

  void error(String text) {
    final adjustedText = text.replaceAll('\n', '\r\n ');
    terminal.write('\r\n\x1B[91m $adjustedText\x1B[0m');
  }

  set prompt(String value) {
    _prompt = '$value❯ ';
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
    if(globalCommands.containsKey(baseCommand)) {
      globalCommands[baseCommand]?.runCommand(this, arguments, flags);
    } else if (currentFeatureCommands != null){
      currentFeatureCommands?.runCommand(baseCommand, arguments, flags);
    } else {
      error('Command not found, type "help" to view a list of commands');
    }
  }
}

class Clear extends Command {
  Clear() : super(
      maxArgs: 0,
      minArgs: 0,
      possibleFlag: false,
      argTypes: [],
      commandName: 'clear',
      usage: 'Usage: clear'
  );

  @override
  void runCommand(dynamic controller, List<String> arguments, Map<String, String?> flags) {
    controller.terminal.write('\x1B[2J\x1B[H');
  }
}

class Ls extends Command {
  Ls() : super(
      maxArgs: 0,
      minArgs: 0,
      possibleFlag: false,
      argTypes: [],
      commandName: 'ls',
      usage: 'Usage: ls'
  );

  @override
  void runCommand(dynamic controller, List<String> arguments, Map<String, String?> flags) {
    String output = '';
    for (CommandSet feature in controller.features.values) {
      output += '${feature.featureName} ';
    }
    controller.log(output);
  }
}

class Cd extends Command {
  Cd() : super(
      maxArgs: 1,
      minArgs: 1,
      possibleFlag: false,
      argTypes: ['String'],
      commandName: 'cd',
      usage: 'Usage: cd <Feature>'
  );

  @override
  void runCommand(dynamic controller, List<String> arguments, Map<String, String?> flags) {
    if(controller.features.containsKey(arguments[0])) {
      controller.currentFeatureCommands = controller.features[arguments[0]];
      controller.prompt = (arguments[0]);
    } else {
      controller.error('${arguments[0]} is not a valid feature, type "ls" to see a list of features');
    }
  }
}

class Help extends Command {
  Help() : super(
      maxArgs: 0,
      minArgs: 0,
      possibleFlag: false,
      argTypes: ['String'],
      commandName: 'help',
      usage: 'Usage: help'
  );

  @override
  void runCommand(dynamic controller, List<String> arguments, Map<String, String?> flags) {
    controller.log('----  global commands ----');
    for(Command command in controller.globalCommands.values) {
      controller.log(command.commandName);
      controller.log('${command.usage}\n');
    }

    if(controller.currentFeatureCommands != null) {
      controller.log('----  ${controller.currentFeatureCommands.featureName} commands ----');
      for(Command command in controller.currentFeatureCommands.commands.values) {
        controller.log(command.commandName);
        controller.log('${command.usage}\n');
      }
    }
  }
}