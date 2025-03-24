// import 'package:bessie/data/abstract/schedule_block.dart';
// import 'package:bessie/data/models/camper_preference.dart';
// import 'package:bessie/pages/console/controller/console_controller.dart';
// import 'package:get/get.dart';
// import 'package:pdf/widgets.dart' as pw;
//
// import '../../data/models/camper.dart';
// import '../../data/models/schedule/activity.dart';
// import '../../data/models/schedule/assignable_activity_block.dart';
// import '../../data/models/schedule/schedule.dart';
// import '../../data/repositories/firebase_repository.dart';
// import '../feature_utils/pdf_utils.dart';
// import '../feature_utils/roster_utils.dart';
//
// class ScheduleService extends GetxService {
//   FirebaseRepository firebaseRepo = Get.find<FirebaseRepository>();
//
//   Future<AssignedMultiActivityBlock> createAssignedMultiActivityBlock(String name) async {
//     // creates the block and adds it to the schedule
//     AssignedMultiActivityBlock blockToCreate = AssignedMultiActivityBlock(name: name);
//     Schedule schedule = await firebaseRepo.getObject('./', fromJson);
//     schedule.updateTimestamp();
//
//     // iterates through each camper, adds the new block to their preference list, and initializes a prefernece object for it
//     for (Camper camper in localData.session!.sessionRoster.values) {
//       camper.activityPreferences[blockToCreate] = CamperPreference(camper: camper, block: blockToCreate);
//       camper.activities[blockToCreate] = null;
//       camper.updateTimestamp();
//     }
//     return blockToCreate;
//   }
//
//   void deleteAssignableActivityBlock(AssignedMultiActivityBlock blockToDelete) {
//     schedule.blocks.remove(blockToDelete.id);
//     schedule.updateTimestamp();
//
//     for (Camper camper in localData.session!.sessionRoster.values) {
//       camper.activityPreferences.remove(blockToDelete);
//       camper.activities.remove(blockToDelete);
//       camper.updateTimestamp();
//     }
//   }
//
//   void createActivity({
//     required String name,
//     required int capacity,
//     required AssignedMultiActivityBlock assignableActivityBlock,
//   }) {
//     Activity activityToAdd = Activity(
//       name: name,
//       capacity: capacity,
//       block: assignableActivityBlock,
//     );
//
//     assignableActivityBlock.activities[activityToAdd.id] = activityToAdd;
//     assignableActivityBlock.updateTimestamp();
//
//     for (Camper camper in localData.session!.sessionRoster.values) {
//       camper.activityPreferences[assignableActivityBlock]!.preferences[activityToAdd] = null;
//       camper.updateTimestamp();
//     }
//   }
//
//   void removeActivityFromBlock(AssignedMultiActivityBlock block, Activity activityToRemove) {
//     block.activities.remove(activityToRemove.id);
//     block.updateTimestamp();
//
//     for (Camper camper in localData.session!.sessionRoster.values) {
//       camper.activityPreferences[block]!.preferences.remove(activityToRemove);
//       camper.updateTimestamp();
//     }
//   }
//
//   // hardcoded simple algorithm TODO: fix that
//   // hardcoded for testing to not take an AssignableActivityBlock as a parameter but to use the first block in the schedule and cast it TODO: fix that too
//   // assigns every camper that has completed their preferences for that block
//   // warns for every camper who hasn't, they won't be assigned
//   void assignCampersForBlock() {
//     AssignedMultiActivityBlock block = schedule.blocks.values.toList()[0] as AssignedMultiActivityBlock; // TODO: Remove hardcoded stuff
//     List<Camper> randomizedRoster = campers.values.toList()..shuffle();
//
//     for (Camper camper in randomizedRoster) {
//       // Skip campers already assigned in this block
//       if (camper.activities[block] != null) {
//         continue;
//       }
//
//       // Skip campers with incomplete preferences
//       if (!camper.activityPreferences[block]!.completed) {
//         ConsoleController().error('${camper.fullName} has incomplete preferences for ${block.name} and will not be assigned.');
//         continue;
//       }
//
//       var map = camper.activityPreferences[block]!.preferences;
//       List<Activity> sortedKeys = map.keys.toList()..sort((a, b) => map[a]!.compareTo(map[b]!)); // a list of activities for the block sorted by the camper's ranking
//
//       // attempt to assign the camper to their preferred activities
//       // moving down their list by rank when activities are full
//       bool camperAssigned = false;
//       int ranked = 1;
//       for (Activity activity in sortedKeys) {
//         ConsoleController().log('Attempting to assign ${camper.fullName} to ${activity.name}, ranked: $ranked');
//         if (assignCamperToActivity(camper, activity)) {
//           camperAssigned = true;
//           break;
//         }
//         ranked++;
//       }
//       if (!camperAssigned) {
//         ConsoleController().error('Error: ${camper.fullName} could not be assigned to any activity in ${block.name}');
//       }
//     }
//   }
//
//   // adds camper to an activity's roster as long as the activity has space
//   // returns false otherwise
//   // if the camper is in another activity, they are removed from it and added to
//   bool assignCamperToActivity(Camper camper, Activity activity) {
//     if (activity.roster.length + 1 > activity.capacity) {
//       ConsoleController().error('Adding ${camper.fullName} to ${activity.name} would put it over capacity. Current count: ${activity.roster.length}, Capacity: ${activity.capacity}');
//       return false;
//     }
//     if (camper.activities[activity.block] != null) {
//       Activity currentAssignedActivity = camper.activities[activity.block]!;
//       removeCamperFromActivity(camper, currentAssignedActivity);
//     }
//     RosterUtils.addCamperToRoster(activity.roster, camper);
//     camper.activities[activity.block] = activity;
//     camper.updateTimestamp();
//     ConsoleController().success('${camper.fullName} successfully assigned to ${activity.name}');
//     return true;
//   }
//
//   void removeCamperFromActivity(Camper camper, Activity activity) {
//     RosterUtils.removeCamperFromRoster(activity.roster, camper);
//     camper.activities[activity.block] = null;
//     camper.updateTimestamp();
//     ConsoleController().log('${camper.fullName} removed from ${activity.name}');
//   }
//
//   void logAllRosters() {
//     for (ScheduleBlock scheduleBlock in schedule.blocks.values) {
//       if(scheduleBlock is AssignedMultiActivityBlock) {
//         AssignedMultiActivityBlock block = scheduleBlock;
//         ConsoleController().log('Block: ${block.name}\n');
//         for (Activity activity in block.activities.values) {
//           ConsoleController().log('${activity.roster.bessToString()}\n');
//         }
//       }
//     }
//   }
//
//   void exportActivities() {
//     pw.Document pdf = PdfUtils.assignableActivityBlockToPdf(schedule.blocks.values.first as AssignedMultiActivityBlock);
//     String formattedSessionName = localData.session!.name.replaceAll(' ', '_').toLowerCase();
//     String formattedTimestamp = (schedule.blocks.values.first as AssignedMultiActivityBlock).formattedUpdatedAt.replaceAll(' ', '_').replaceAll(RegExp(r'[^\w_]'), '-').toLowerCase();
//     PdfUtils.savePdfLocally(pdf, 'master_roster_${formattedSessionName}_$formattedTimestamp.pdf');
//   }
// }