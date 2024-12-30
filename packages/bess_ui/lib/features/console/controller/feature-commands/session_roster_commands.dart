import 'package:get/get.dart';

import '../../../session_roster/controllers/session_roster_controller.dart';
import '../console_controller.dart';

class SessionRosterCommands {
  void runCommand(String baseCommand, List<String> arguments, Map<String, String?> flags) {
    final SessionRosterController sessionRosterController = SessionRosterController();
    final ConsoleController consoleController = Get.find<ConsoleController>();

    // Execute the command
    switch (baseCommand) {
      case 'addcamper': // separate out commands by feature and have some kind of selection system to mirror navigating to a page/module
        sessionRosterController.addCamper(
          firstName: arguments[0],
          lastName: arguments [1],
          age: int.parse(arguments[2]),
        );
      case 'printroster':
        sessionRosterController.logSessionRoster();
      default:
        consoleController.log('Unknown command: $baseCommand');
    }
  }
}