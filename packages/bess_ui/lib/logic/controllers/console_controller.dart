import 'package:bessie/logic/console_command_parser.dart';
import 'package:get/get.dart';

class ConsoleController extends GetxController {
  final logs = <Map<String, String>>[].obs;
  late final CommandParser commandParser;

  ConsoleController() {
    commandParser = CommandParser(this); // Pass `this` to the CommandParser.
  }

  void executeCommand(String command) {
    logs.add({'type': 'user', 'message': '> $command'});
    commandParser.runCommand(command);
  }

  void log(String textToLog) {
    logs.add({'type': 'system', 'message': textToLog});
  }

  void clear() {
    logs.clear();
  }
}
