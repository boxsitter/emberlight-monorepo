import 'package:bessie/features/schedule/controllers/schedule_controller.dart';
import 'package:get/get.dart';

import '../../../../common/data/abstract/command.dart';
import '../../../../common/data/abstract/command_set.dart';

class ScheduleCommands extends CommandSet{
  ScheduleCommands() : super(
    controller: Get.find<ScheduleController>(),
    featureName: 'activitysignup',
  );

  @override
  void initializeCommands() {
    super.commands['simpleassign'] = SimpleAssign();
    super.commands['activityrosters'] = ActivityRosters();
  }

}

class SimpleAssign extends Command {
  SimpleAssign() : super(
    maxArgs: 0,
    minArgs: 0,
    possibleFlag: false,
    argTypes: [],
    commandName: 'simpleassign',
  );

  @override
  void runCommand(dynamic controller, List<String> arguments, Map<String, String?> flags) {
    controller.assignCampersForBlock();
  }
}

class ActivityRosters extends Command {
  ActivityRosters() : super(
    maxArgs: 0,
    minArgs: 0,
    possibleFlag: false,
    argTypes: [],
    commandName: 'activityrosters',
  );

  @override
  void runCommand(dynamic controller, List<String> arguments, Map<String, String?> flags) {
    controller.logAllRosters();
  }
}