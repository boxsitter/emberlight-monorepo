import 'package:bessie/common/services/schedule_service.dart';
import 'package:get/get.dart';

import '../../../../data/abstract/command.dart';
import '../../../../data/abstract/command_set.dart';

class ScheduleCommands extends CommandSet{
  ScheduleCommands() : super(
    controller: Get.find<ScheduleService>(),
    featureName: 'activitysignup',
  );

  @override
  void initializeCommands() {
    super.commands['simpleassign'] = SimpleAssign();
    super.commands['activityrosters'] = ActivityRosters();
    super.commands['exportactivities'] = ExportActivities();
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

class ExportActivities extends Command {
  ExportActivities() : super(
    maxArgs: 0,
    minArgs: 0,
    possibleFlag: false,
    argTypes: [],
    commandName: 'exportactivities',
  );

  @override
  void runCommand(dynamic controller, List<String> arguments, Map<String, String?> flags) {
    controller.exportActivities();
  }
}