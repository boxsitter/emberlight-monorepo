import 'command.dart';

abstract class CommandSet {
  final dynamic controller;
  final Map<String, Command> commands = <String, Command>{};
  final String featureName;

  CommandSet({
    required this.controller,
    required this.featureName,
  }) {
    initializeCommands();
  }

  void initializeCommands();

  bool runCommand(String baseCommand, List<String> arguments, Map<String, String?> flags) {
    if(commands.containsKey(baseCommand)) {
      commands[baseCommand]?.execute(controller, arguments, flags);
      return true;
    } else {
      return false;
    }
  }
}
