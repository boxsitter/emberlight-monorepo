import 'package:ember_cli_utils/ember_cli_utils.dart';
import 'package:ember_core/ember_core_services.dart';
import 'package:get/get.dart';

import '../../ember_core_frontend.dart';
import '../../ember_core_models.dart';
import '../../ember_core_validators.dart';

class DevCommands {
  static Map<String, EmberCommand> list = {
    'inithc': InitHardCode(
      userInput: FrontendManager.instance.getUserInputImplementation(),
      userOutput: FrontendManager.instance.getUserOutputImplementation(),
    ),
  };
}

// THIS WILL NOT MERGE, IT WILL CREATE DUPES
class InitHardCode extends EmberCommand {
  final UserService userService = Get.find<UserService>();
  final ClientContext clientContext = Get.find<ClientContext>();
  final FrontendCommitService commitService = Get.find<FrontendCommitService>();

  @override
  final String name = 'inithc';
  @override
  final String description = 'Initializes hardcoded objects';
  @override
  String get invocationDetails => 'inithc';
  @override
  List<String> get examples => ['inithc'];

  InitHardCode({
    required super.userInput,
    required super.userOutput,
  });

  @override
  Future<dynamic> run() async {

    commitService.commit(commit);
  }
}