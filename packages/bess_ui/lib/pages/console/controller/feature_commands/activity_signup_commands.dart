import 'package:get/get.dart';

import '../../../../data/abstract/command.dart';
import '../../../../data/abstract/command_set.dart';
import '../../../../common/services/activity_signup_service.dart';

class ActivitySignupCommands extends CommandSet{
  ActivitySignupCommands() : super(
    controller: Get.find<ActivitySignupService>(),
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
