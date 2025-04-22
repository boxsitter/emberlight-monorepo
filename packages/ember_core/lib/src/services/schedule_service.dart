import 'package:ember_core/ember_core_backend.dart';
import 'package:ember_core/ember_core_models.dart';
import 'package:get/get.dart';
import '../../ember_core_services.dart';


class ScheduleService extends GetxService {
  BackendInterface backend = BackendManager.instance;
  ClientContextService clientContextService = Get.find<ClientContextService>();
  SessionRosterService sessionRosterService = Get.find<SessionRosterService>();

  // Future<void> createAssignedMultiActivityBlock(String name) async {
  //   // creates the block and adds it to the schedule
  //   AssignedMultiActivityBlock blockToCreate = AssignedMultiActivityBlock(name: name);
  //   Schedule schedule = await clientContextService.schedule;
  //   schedule.blockCmps.add(blockToCreate.id);
  //   return Request(disarmRequirementsLevel: 0, initialObjects: {blockToCreate, schedule});
  // }
  //
  // // Future<DeleteRequest> deleteAssignableActivityBlock(String blockToDeleteId) async {
  // //   // TODO: This will need to replace the block in the schedule with an empty block!
  // //   await coreObjectRepo._purgeReferencesTo(await clientContextService.scheduleId, blockToDeleteId);
  // //   // TODO: Delete all activities inside, make sure activities are cleaned up properly
  // //   coreObjectRepo.deleteDocument(blockToDeleteId);
  // // }
  //
  // Future<void> createActivityType(String name, int capacity, String description) async {
  //   // TODO: Check with a query to make sure name is unique
  //   PrincipalActivity activityTypeToCreate = PrincipalActivity(name: name, capacity: capacity, description: description);
  //   return Request(disarmRequirementsLevel: 0, initialObjects: {activityTypeToCreate});
  // }

  // Future<DeleteRequest> deleteActivityType(String id) async { //TODO: ensure that delete is called on every scheduled activity of this type, which involves removing it from campers activity map
  //   Branch branch = await pullRepo.getObject(clientContextService.branchId, Branch.fromJson);
  //   branch.activityTypeIds.remove(id);
  //   pullRepo.pushObject(branch);
  //   pullRepo._purgeReferencesTo(await clientContextService.scheduleId, id);
  //
  //   // TODO: Get all camper preferences from camperIdToPreferenceId in session and remove the activity type from them
  //
  //   pullRepo.deleteDocument(id);
  // }

  // void createActivity({
  //   required String name,
  //
  //   required int capacity,
  //   required AssignedMultiActivityBlock assignableActivityBlock,
  // }) {
  //   ActivityDependent activityToAdd = ActivityDependent(
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
  // void removeActivityFromBlock(AssignedMultiActivityBlock block, ActivityDependent activityToRemove) {
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
  //     List<ActivityDependent> sortedKeys = map.keys.toList()..sort((a, b) => map[a]!.compareTo(map[b]!)); // a list of activities for the block sorted by the camper's ranking
  //
  //     // attempt to assign the camper to their preferred activities
  //     // moving down their list by rank when activities are full
  //     bool camperAssigned = false;
  //     int ranked = 1;
  //     for (ActivityDependent activity in sortedKeys) {
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
  // bool assignCamperToActivity(Camper camper, ActivityDependent activity) {
  //   if (activity.roster.length + 1 > activity.capacity) {
  //     ConsoleController().error('Adding ${camper.fullName} to ${activity.name} would put it over capacity. Current count: ${activity.roster.length}, Capacity: ${activity.capacity}');
  //     return false;
  //   }
  //   if (camper.activities[activity.block] != null) {
  //     ActivityDependent currentAssignedActivity = camper.activities[activity.block]!;
  //     removeCamperFromActivity(camper, currentAssignedActivity);
  //   }
  //   RosterUtils.addCamperToRoster(activity.roster, camper);
  //   camper.activities[activity.block] = activity;
  //   ConsoleController().success('${camper.fullName} successfully assigned to ${activity.name}');
  //   return true;
  // }
  //
  // void removeCamperFromActivity(Camper camper, ActivityDependent activity) {
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
  //       for (ActivityDependent activity in block.activities.values) {
  //         ConsoleController().log('${activity.roster.coreToString()}\n');
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