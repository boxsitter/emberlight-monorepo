import 'package:bessie/features/console/controller/console_controller.dart';
import 'package:get/get.dart';

import '../../../common/data/models/camper.dart';
import '../../../common/data/models/local_data.dart';
import '../../../common/data/models/roster.dart';

class SessionRosterController extends GetxController {
  final LocalData localData = Get.find<LocalData>();
  late final Roster sessionRoster;
  final ConsoleController consoleController = Get.find<ConsoleController>();

  SessionRosterController() {
    if (localData.session != null){
      sessionRoster = localData.session!.sessionRoster;
    } else {
      // TODO: Error handling!
    }
  }

  void addCamper({
    String firstName = '',
    String lastName = '',
    String preferredName = '',
    int age = 0,
  }) {
    Camper camperToAdd = Camper(
      firstName: firstName,
      lastName: lastName,
      preferredName: preferredName,
      age: age,
    );
    sessionRoster.addCamper(camperToAdd);
    consoleController.log('${camperToAdd.bessToString()}\nadded to session: ${localData.session?.name}');
  }

  void logSessionRoster() {
    consoleController.log(sessionRoster.bessToString());
  }


}