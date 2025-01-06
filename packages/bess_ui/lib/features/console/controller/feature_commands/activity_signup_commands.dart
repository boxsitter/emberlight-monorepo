import 'package:get/get.dart';

import '../../../../common/data/abstract/command.dart';
import '../../../../common/data/abstract/command_set.dart';
import '../../../activity_signup/controllers/activity_signup_controller.dart';

class ActivitySignupCommands extends CommandSet{
  ActivitySignupCommands() : super(
    controller: Get.find<ActivitySignupController>(),
    featureName: 'activitysignup',
  );

  @override
  void initializeCommands() {
    super.commands['rankrandom'] = RankRandom();
  }

}

class RankRandom extends Command {
  RankRandom() : super(
      maxArgs: 0,
      minArgs: 0,
      possibleFlag: false,
      argTypes: [],
      commandName: 'rankrandom',
  );

  @override
  void runCommand(dynamic controller, List<String> arguments, Map<String, String?> flags) {
    controller.rankRandom();
  }

}