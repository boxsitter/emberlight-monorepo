import 'package:bessie/common/data/abstract/schedule_block.dart';
import 'package:bessie/common/data/models/camper_preference.dart';
import 'package:bessie/common/utils/model_utils/roster_utils.dart';
import 'package:bessie/features/console/controller/console_controller.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../common/data/models/camper.dart';
import '../../../common/data/models/local_data.dart';
import '../../../common/data/models/schedule/activity.dart';
import '../../../common/data/models/schedule/assignable_activity_block.dart';
import '../../../common/data/models/schedule/schedule.dart';

class ScheduleController extends GetxController {
  final LocalData localData = Get.find<LocalData>();

  Schedule get schedule => localData.session!.schedule;
  Map<String, Camper> get campers => localData.session!.sessionRoster.campers;

  void initializeSessionForTesting() {
    AssignableActivityBlock testBlock = createAssignableActivityBlock('Test Choice Activity');

    createActivity(
        name: 'Gaga Ball',
        capacity: 4,
        assignableActivityBlock: testBlock,
    );

    createActivity(
      name: 'Boating',
      capacity: 6,
      assignableActivityBlock: testBlock,
    );

    createActivity(
      name: 'OLS',
      capacity: 6,
      assignableActivityBlock: testBlock,
    );

    createActivity(
      name: 'Arts and Crafts',
      capacity: 10,
      assignableActivityBlock: testBlock,
    );
  }

  AssignableActivityBlock createAssignableActivityBlock(String name) {
    // creates the block and adds it to the schedule
    AssignableActivityBlock blockToCreate = AssignableActivityBlock(name: 'Test Choice Activity');
    schedule.blocks[blockToCreate.id] = blockToCreate;

    // iterates through each camper, adds the new block to their preference list, and initializes a prefernece object for it
    for (Camper camper in localData.session!.sessionRoster.values) {
      camper.activityPreferences[blockToCreate] = CamperPreference(camper: camper, block: blockToCreate);
      camper.activities[blockToCreate] = null;
    }
    return blockToCreate;
  }

  void deleteAssignableActivityBlock(AssignableActivityBlock blockToDelete) {
    schedule.blocks.remove(blockToDelete.id);

    for (Camper camper in localData.session!.sessionRoster.values) {
      camper.activityPreferences.remove(blockToDelete);
      camper.activities.remove(blockToDelete);
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
      block: assignableActivityBlock,
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

  // hardcoded simple algorithm TODO: fix that
  // hardcoded for testing to not take an AssignableActivityBlock as a parameter but to use the first block in the schedule and cast it TODO: fix that too
  // assigns every camper that has completed their preferences for that block
  // warns for every camper who hasn't, they won't be assigned
  void assignCampersForBlock() {
    AssignableActivityBlock block = schedule.blocks.values.toList()[0] as AssignableActivityBlock; // TODO: Remove hardcoded bullshit
    List<Camper> randomizedRoster = campers.values.toList()..shuffle();

    for (Camper camper in randomizedRoster) {
      // Skip campers already assigned in this block
      if (camper.activities[block] != null) {
        continue;
      }

      // Skip campers with incomplete preferences
      if (!camper.activityPreferences[block]!.completed) {
        ConsoleController().error('${camper.fullName} has incomplete preferences for ${block.name} and will not be assigned.');
        continue;
      }

      var map = camper.activityPreferences[block]!.preferences;
      List<Activity> sortedKeys = map.keys.toList()..sort((a, b) => map[a]!.compareTo(map[b]!)); // a list of activities for the block sorted by the camper's ranking

      // attempt to assign the camper to their preferred activities
      // moving down their list by rank when activities are full
      bool camperAssigned = false;
      int ranked = 1;
      for (Activity activity in sortedKeys) {
        ConsoleController().log('Attempting to assign ${camper.fullName} to ${activity.name}, ranked: $ranked');
        if (assignCamperToActivity(camper, activity)) {
          camperAssigned = true;
          break;
        }
        ranked++;
      }
      if (!camperAssigned) {
        ConsoleController().error('Error: ${camper.fullName} could not be assigned to any activity in ${block.name}');
      }
    }
  }

  // adds camper to an activity's roster as long as the activity has space
  // returns false otherwise
  // if the camper is in another activity, they are removed from it and added to
  bool assignCamperToActivity(Camper camper, Activity activity) {
    if (activity.roster.length + 1 > activity.capacity) {
      ConsoleController().error('Adding ${camper.fullName} to ${activity.name} would place it over capacity. Current count: ${activity.roster.length}, Capacity: ${activity.capacity}');
      return false;
    }
    if (camper.activities[activity.block] != null) {
      Activity currentAssignedActivity = camper.activities[activity.block]!;
      removeCamperFromActivity(camper, currentAssignedActivity);
    }
    RosterUtils.addCamperToRoster(activity.roster, camper);
    camper.activities[activity.block] = activity;
    ConsoleController().success('${camper.fullName} successfully assigned to ${activity.name}');
    return true;
  }

  void removeCamperFromActivity(Camper camper, Activity activity) {
    RosterUtils.removeCamperFromRoster(activity.roster, camper);
    camper.activities[activity.block] = null;
    ConsoleController().log('${camper.fullName} removed from ${activity.name}');
  }

  void logAllRosters() {
    for (ScheduleBlock scheduleBlock in schedule.blocks.values) {
      if(scheduleBlock is AssignableActivityBlock) {
        AssignableActivityBlock block = scheduleBlock;
        ConsoleController().log('Block: ${block.name}\n');
        for (Activity activity in block.activities.values) {
          ConsoleController().log('${activity.roster.bessToString()}\n');
        }
      }
    }
  }
}