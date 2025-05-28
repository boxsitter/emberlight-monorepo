import 'dart:async';
import 'package:ember_cli_utils/ember_cli_utils.dart';

class ReleaseCommands {
  UserInput userInput;
  UserOutput userOutput;
  final List<EmberCommand> list = [];

  ReleaseCommands({required this.userInput, required this.userOutput}) {
    // Populate the list in the constructor's body
    list.addAll([
      Release(userInput: userInput, userOutput: userOutput),
      // You can add more commands to this list here
      // e.g., AnotherConfigCommand(userInput: userInput, userOutput: userOutput),
    ]);
  }
}

class Release extends EmberCommand<void> {
  @override
  final String name = 'release';

  @override
  final String description = 'Handles the release process for packages in the monorepo.';

  // You can add command-specific arguments here
  Release({required super.userInput, required super.userOutput}) {
    // argParser.addFlag('dry-run', help: 'Simulates the release process without making actual changes.');
    // argParser.addOption('package', abbr: 'p', help: 'Specify the package to release.');
  }

  @override
  FutureOr<void> run() async {
    userOutput.warning('Not implemented!');
  }
}