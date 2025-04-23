import 'package:ember_core/ember_core_backend.dart';
import 'package:ember_core/ember_core_models.dart';
import 'package:ember_core/src/models/core_objects/schedule_day.dart';
import 'package:get/get.dart';
import '../../ember_core_services.dart';


class ScheduleService extends GetxService {
  BackendInterface backend = BackendManager.instance;
  ClientContextService clientContextService = Get.find<ClientContextService>();
  SessionRosterService sessionRosterService = Get.find<SessionRosterService>();

  Future<void> addBlockToDay(Commit commit, String scheduleDayToAddToId, ScheduleBlock blockToAdd) async {
    ScheduleDay day = commit.getObject(scheduleDayToAddToId) ?? await backend.getObject(scheduleDayToAddToId);
    day.blockCmps.add(blockToAdd.id);
    commit.addObjectsToPush({blockToAdd, day});
  }

  void scheduleAMABlock(Commit commit, String name, String scheduleDayId, DateTime start, DateTime end) {
    // TODO: infer the day from the start and end
    //  TODO: Add robust checking to make sure the AMA block doesn't overlap with other blocks or span days
    AMABlock amaBlockToCreate = AMABlock(name: name, isTemplate: false, start: start, end: end);
    commit.addObjectToPush(amaBlockToCreate);
    addBlockToDay(commit, amaBlockToCreate);
  }

  void createPrincipalActivity(Commit commit, String name, int capacity, String description, bool isSkillsRec) {
    // TODO: Check with a query to make sure name is unique
    PrincipalActivity activityToCreate = PrincipalActivity(name: name, capacity: capacity, description: description, isSkillsRec: isSkillsRec);
    commit.addObjectToPush(activityToCreate);
  }

  Future<void> scheduleActivity(Commit commit, String principalActivityId, String blockToAddToId) async {
    PrincipalActivity principalActivity = commit.getObject(principalActivityId) ?? (await backend.getObject(principalActivityId));
    AMABlock blockToAddTo = commit.getObject(blockToAddToId) ?? (await backend.getObject(blockToAddToId));
    ActivityDependent activityToSchedule = ActivityDependent(principalPar: principalActivity.id, blockRef: blockToAddTo.id);
    blockToAddTo.activityDependentCmps.add(activityToSchedule.id);
    commit.addObjectsToPush({activityToSchedule, blockToAddTo});
  }

  void assignCampersForBlock() {
    AMABlock block = schedule.blockIds.values.toList()[0] as AMABlock; // TODO: Remove hardcoded stuff
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
      List<ActivityDependent> sortedKeys = map.keys.toList()..sort((a, b) => map[a]!.compareTo(map[b]!)); // a list of activities for the block sorted by the camper's ranking

      // attempt to assign the camper to their preferred activities
      // moving down their list by rank when activities are full
      bool camperAssigned = false;
      int ranked = 1;
      for (ActivityDependent activity in sortedKeys) {
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
  bool assignCamperToActivity(Camper camper, ActivityDependent activity) {
    if (activity.roster.length + 1 > activity.capacity) {
      ConsoleController().error('Adding ${camper.fullName} to ${activity.name} would put it over capacity. Current count: ${activity.roster.length}, Capacity: ${activity.capacity}');
      return false;
    }
    if (camper.activities[activity.block] != null) {
      ActivityDependent currentAssignedActivity = camper.activities[activity.block]!;
      removeCamperFromActivity(camper, currentAssignedActivity);
    }
    RosterUtils.addCamperToRoster(activity.roster, camper);
    camper.activities[activity.block] = activity;
    ConsoleController().success('${camper.fullName} successfully assigned to ${activity.name}');
    return true;
  }

  void removeCamperFromActivity(Camper camper, ActivityDependent activity) {
    RosterUtils.removeCamperFromRoster(activity.roster, camper);
    camper.activities[activity.block] = null;
    ConsoleController().log('${camper.fullName} removed from ${activity.name}');
  }
}