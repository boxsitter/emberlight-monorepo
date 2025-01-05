import 'package:bessie/common/data/models/camper_preference.dart';
import 'package:get/get.dart';

import '../../../common/data/models/camper.dart';
import '../../../common/data/models/local_data.dart';
import '../../../common/data/models/schedule/activity.dart';
import '../../../common/data/models/schedule/assignable_activity_block.dart';
import '../../../common/data/models/schedule/schedule.dart';

class ScheduleController extends GetxController {
  final LocalData localData = Get.find<LocalData>();

  Schedule _getSchedule() {
    return localData.session!.schedule;
  }

  void initializeSessionForTesting() {
    AssignableActivityBlock testBlock = createAssignableActivityBlock('Test Choice Activity');

    createActivity(
        name: 'Gaga Ball',
        capacity: 6,
        assignableActivityBlock: testBlock,
    );

    createActivity(
      name: 'Boating',
      capacity: 8,
      assignableActivityBlock: testBlock,
    );

    createActivity(
      name: 'OLS',
      capacity: 8,
      assignableActivityBlock: testBlock,
    );

    createActivity(
      name: 'Arts and Crafts',
      capacity: 8,
      assignableActivityBlock: testBlock,
    );
  }

  AssignableActivityBlock createAssignableActivityBlock(String name) {
    // creates the block and adds it to the schedule
    AssignableActivityBlock blockToCreate = AssignableActivityBlock(name: 'Test Choice Activity');
    _getSchedule().blocks[blockToCreate.id] = blockToCreate;

    // iterates through each camper, adds the new block to their preference list, and initializes a prefernece object for it
    for (Camper camper in localData.session!.sessionRoster.values) {
      camper.activityPreferences[blockToCreate] = CamperPreference(camper: camper, block: blockToCreate);
    }
    return blockToCreate;
  }

  void deleteAssignableActivityBlock(AssignableActivityBlock blockToDelete) {
    _getSchedule().blocks.remove(blockToDelete.id);

    for (Camper camper in localData.session!.sessionRoster.values) {
      camper.activityPreferences.remove(blockToDelete);
    }
  }

  void createActivity({
    required String name,
    required int capacity,
    required AssignableActivityBlock assignableActivityBlock,
  }) {
    Activity activityToAdd = Activity(
      name: name,
      capacity: capacity,
      assignableActivityBlock: assignableActivityBlock,
    );

    assignableActivityBlock.activities[activityToAdd.id] = activityToAdd;

    for (Camper camper in localData.session!.sessionRoster.values) {
      camper.activityPreferences[assignableActivityBlock]!.preferences[activityToAdd] = null;
    }
  }

  void removeActivityFromBlock(AssignableActivityBlock block, Activity activityToRemove) {
    block.activities.remove(activityToRemove.id);

    for (Camper camper in localData.session!.sessionRoster.values) {
      camper.activityPreferences[block]!.preferences.remove(activityToRemove);
    }
  }
}