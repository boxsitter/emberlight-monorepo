import '../../../features/console/controller/console_controller.dart';
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

  void runCommand(String baseCommand, List<String> arguments, Map<String, String?> flags) {
    if(commands.containsKey(baseCommand)) {
      commands[baseCommand]?.execute(controller, arguments, flags);
    } else {
      ConsoleController().error('Command not found, type "help" to view a list of commands');
    }
  }
}
