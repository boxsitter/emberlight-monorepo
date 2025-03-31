import 'package:bessie/common/services/client_context_service.dart';
import 'package:bessie/common/services/session_roster_service.dart';
import 'package:bessie/data/abstract/schedule_block.dart';
import 'package:bessie/data/bess_objects/camper_preference.dart';
import 'package:bessie/data/bess_objects/schedule/activity_type.dart';
import 'package:bessie/data/repositories/push_repository.dart';
import 'package:bessie/pages/console/controller/console_controller.dart';
import 'package:get/get.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../data/bess_objects/branch.dart';
import '../../data/bess_objects/camper.dart';
import '../../data/bess_objects/schedule/scheduled_activity.dart';
import '../../data/bess_objects/schedule/assigned_multi_activity_block.dart';
import '../../data/bess_objects/schedule/schedule.dart';

class ScheduleService extends GetxService {
  PushRepository bessObjectRepo= Get.find<PushRepository>();
  ClientContextService clientContextService = Get.find<ClientContextService>();
  SessionRosterService sessionRosterService = Get.find<SessionRosterService>();

  Future<AssignedMultiActivityBlock> createAssignedMultiActivityBlock(String name) async {
    // creates the block and adds it to the schedule
    AssignedMultiActivityBlock blockToCreate = AssignedMultiActivityBlock(name: name);
    bessObjectRepo.pushObject(blockToCreate);
    Schedule schedule = await clientContextService.schedule;
    schedule.blockIds.add(blockToCreate.id);
    bessObjectRepo.pushObject(schedule);
    return blockToCreate;
  }

  Future<void> deleteAssignableActivityBlock(String blockToDeleteId) async {
    // TODO: This will need to replace the block in the schedule with an empty block!
    await bessObjectRepo._purgeReferencesTo(await clientContextService.scheduleId, blockToDeleteId);
    // TODO: Delete all activities inside, make sure activities are cleaned up properly
    bessObjectRepo.deleteDocument(blockToDeleteId);
  }

  Future<void> createActivityType(String name, int capacity, String description) async {
    // TODO: Check with a query to make sure name is unique
    ActivityType activityTypeToCreate = ActivityType(name: name, capacity: capacity, description: description);
    bessObjectRepo.pushObject(activityTypeToCreate);
    Branch branch = await bessObjectRepo.getObject(clientContextService.branchId, Branch.fromJson);
    branch.activityTypeIds.add(activityTypeToCreate.id);
    bessObjectRepo.pushObject(branch);
  }

  Future<void> deleteActivityType(String id) async { //TODO: ensure that delete is called on every scheduled activity of this type, which involves removing it from campers activity map
    Branch branch = await bessObjectRepo.getObject(clientContextService.branchId, Branch.fromJson);
    branch.activityTypeIds.remove(id);
    bessObjectRepo.pushObject(branch);
    bessObjectRepo._purgeReferencesTo(await clientContextService.scheduleId, id);

    // TODO: Get all camper preferences from camperIdToPreferenceId in session and remove the activity type from them

    bessObjectRepo.deleteDocument(id);
  }

  // void createActivity({
  //   required String name,
  //
  //   required int capacity,
  //   required AssignedMultiActivityBlock assignableActivityBlock,
  // }) {
  //   ScheduledActivity activityToAdd = ScheduledActivity(
  //     name: name,
  //     capacity: capacity,
  //     block: assignableActivityBlock,
  //   );
  //
  //   assignableActivityBlock.activities[activityToAdd.id] = activityToAdd;
  //
  //   for (Camper camper in localData.session!.sessionRoster.values) {
  //     camper.activityPreferences[assignableActivityBlock]!.preferences[activityToAdd] = null;
  //   }
  // }
  //
  // void removeActivityFromBlock(AssignedMultiActivityBlock block, ScheduledActivity activityToRemove) {
  //   block.activities.remove(activityToRemove.id);
  //
  //   for (Camper camper in localData.session!.sessionRoster.values) {
  //     camper.activityPreferences[block]!.preferences.remove(activityToRemove);
  //   }
  // }
  //
  // // hardcoded simple algorithm TODO: fix that
  // // hardcoded for testing to not take an AssignableActivityBlock as a parameter but to use the first block in the schedule and cast it TODO: fix that too
  // // assigns every camper that has completed their preferences for that block
  // // warns for every camper who hasn't, they won't be assigned
  // void assignCampersForBlock() {
  //   AssignedMultiActivityBlock block = schedule.blockIds.values.toList()[0] as AssignedMultiActivityBlock; // TODO: Remove hardcoded stuff
  //   List<Camper> randomizedRoster = campers.values.toList()..shuffle();
  //
  //   for (Camper camper in randomizedRoster) {
  //     // Skip campers already assigned in this block
  //     if (camper.activities[block] != null) {
  //       continue;
  //     }
  //
  //     // Skip campers with incomplete preferences
  //     if (!camper.activityPreferences[block]!.completed) {
  //       ConsoleController().error('${camper.fullName} has incomplete preferences for ${block.name} and will not be assigned.');
  //       continue;
  //     }
  //
  //     var map = camper.activityPreferences[block]!.preferences;
  //     List<ScheduledActivity> sortedKeys = map.keys.toList()..sort((a, b) => map[a]!.compareTo(map[b]!)); // a list of activities for the block sorted by the camper's ranking
  //
  //     // attempt to assign the camper to their preferred activities
  //     // moving down their list by rank when activities are full
  //     bool camperAssigned = false;
  //     int ranked = 1;
  //     for (ScheduledActivity activity in sortedKeys) {
  //       ConsoleController().log('Attempting to assign ${camper.fullName} to ${activity.name}, ranked: $ranked');
  //       if (assignCamperToActivity(camper, activity)) {
  //         camperAssigned = true;
  //         break;
  //       }
  //       ranked++;
  //     }
  //     if (!camperAssigned) {
  //       ConsoleController().error('Error: ${camper.fullName} could not be assigned to any activity in ${block.name}');
  //     }
  //   }
  // }
  //
  // // adds camper to an activity's roster as long as the activity has space
  // // returns false otherwise
  // // if the camper is in another activity, they are removed from it and added to
  // bool assignCamperToActivity(Camper camper, ScheduledActivity activity) {
  //   if (activity.roster.length + 1 > activity.capacity) {
  //     ConsoleController().error('Adding ${camper.fullName} to ${activity.name} would put it over capacity. Current count: ${activity.roster.length}, Capacity: ${activity.capacity}');
  //     return false;
  //   }
  //   if (camper.activities[activity.block] != null) {
  //     ScheduledActivity currentAssignedActivity = camper.activities[activity.block]!;
  //     removeCamperFromActivity(camper, currentAssignedActivity);
  //   }
  //   RosterUtils.addCamperToRoster(activity.roster, camper);
  //   camper.activities[activity.block] = activity;
  //   ConsoleController().success('${camper.fullName} successfully assigned to ${activity.name}');
  //   return true;
  // }
  //
  // void removeCamperFromActivity(Camper camper, ScheduledActivity activity) {
  //   RosterUtils.removeCamperFromRoster(activity.roster, camper);
  //   camper.activities[activity.block] = null;
  //   ConsoleController().log('${camper.fullName} removed from ${activity.name}');
  // }
  //
  // void logAllRosters() {
  //   for (ScheduleBlock scheduleBlock in schedule.blockIds.values) {
  //     if(scheduleBlock is AssignedMultiActivityBlock) {
  //       AssignedMultiActivityBlock block = scheduleBlock;
  //       ConsoleController().log('Block: ${block.name}\n');
  //       for (ScheduledActivity activity in block.activities.values) {
  //         ConsoleController().log('${activity.roster.bessToString()}\n');
  //       }
  //     }
  //   }
  // }
  //
  // void exportActivities() {
  //   pw.Document pdf = PdfUtils.assignableActivityBlockToPdf(schedule.blockIds.values.first as AssignedMultiActivityBlock);
  //   String formattedSessionName = localData.session!.name.replaceAll(' ', '_').toLowerCase();
  //   String formattedTimestamp = (schedule.blockIds.values.first as AssignedMultiActivityBlock).formattedUpdatedAt.replaceAll(' ', '_').replaceAll(RegExp(r'[^\w_]'), '-').toLowerCase();
  //   PdfUtils.savePdfLocally(pdf, 'master_roster_${formattedSessionName}_$formattedTimestamp.pdf');
  // }
}