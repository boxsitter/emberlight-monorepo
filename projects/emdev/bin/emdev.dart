import 'dart:io';
import 'package:ansicolor/ansicolor.dart';
import 'package:args/command_runner.dart';
import 'package:ember_cli_utils/ember_cli_utils.dart';
import 'package:emdev/src/commands/config_commands.dart';
import 'package:emdev/src/commands/release_commands.dart';


Future<void> main(List<String> args) async {
  final UserOutput userOutput = CliOutput();
  final UserInput userInput = CliInput();

  final ConfigCommands configCommands = ConfigCommands(userInput: userInput, userOutput: userOutput);
  final ReleaseCommands releaseCommands = ReleaseCommands(userInput: userInput, userOutput: userOutput);

  final List<EmberCommand> allCommands = [... configCommands.list, ... releaseCommands.list];

  final runner = CommandRunner<void>(
    'emdev', // Changed executable name to emdev as per your request
    'CLI for managing the EmberLight monorepo development and release tasks.',
  );

  for (final command in allCommands) {
    runner.addCommand(command);
  }

  if (args.isEmpty) {
    // No arguments provided, enter REPL mode
    userOutput.info('Welcome to EmberDev interactive mode. Type "help" for commands, or "exit" to quit.');
    while (true) {
      // Display prompt. Using CliOutput's emphasize for the prompt.
      // stdout.write doesn't add a newline, which is what we want for a prompt.
      stdout.write((AnsiPen()..cyan(bold: true))('emdev> '));
      final line = stdin.readLineSync();

      if (line == null || line.trim().toLowerCase() == 'exit' || line.trim().toLowerCase() == 'quit') {
        userOutput.info('Exiting EmberDev.');
        break;
      }

      if (line.trim().isEmpty) {
        continue; // Skip empty lines
      }

      // Split the input line into command and arguments
      // This is a simple split by space. For arguments with spaces,
      // you might need a more sophisticated parser later.
      final parts = line.trim().split(' ').where((part) => part.isNotEmpty).toList();

      try {
        await runner.run(parts);
      } on UsageException catch (e) {
        userOutput.error(e.message);
        if (e.usage.isNotEmpty) {
          print('');
          userOutput.log(e.usage); // CommandRunner's usage string
        }
      } catch (error, stackTrace) {
        userOutput.error('An unexpected error occurred: $error');
        // Optionally print stack trace for debugging in dev mode
        // print(stackTrace);
      }
      print(''); // Add a blank line for readability before the next prompt
    }
  } else {
    // Arguments provided, run the command directly and exit
    try {
      await runner.run(args);
    } on UsageException catch (e) {
      userOutput.error(e.message);
      if (e.usage.isNotEmpty) {
        print('');
        userOutput.log(e.usage);
      }
      exit(64); // Exit code 64 indicates a usage error
    } catch (error) {
      userOutput.error('An unexpected error occurred: $error');
      exit(1); // General error
    }
  }
}

// Helper to use CliOutput's styling.
// This is a bit of a workaround as CliOutput primarily uses print/writeln.
extension CliOutputStyling on CliOutput {
  String stylize(String message) {
    // This is a conceptual example. You might need to adjust based on how
    // AnsiPen is used internally or expose a method in CliOutput for this.
    // For simplicity, we'll just return the message as is,
    // but you'd ideally apply ANSI codes here.
    // The example above uses AnsiPen directly for the prompt.
    return message;
  }
}