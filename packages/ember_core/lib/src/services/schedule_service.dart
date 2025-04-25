import 'package:ember_core/ember_core_backend.dart';
import 'package:ember_core/ember_core_models.dart';
import 'package:ember_core/src/models/core_objects/schedule_day.dart';
import 'package:ember_core/src/utils/model_helper_functions.dart';
import 'package:get/get.dart';
import '../../ember_core_services.dart';


class ScheduleService extends GetxService {
  BackendInterface backend = BackendManager.instance;
  ClientContextService clientContextService = Get.find<ClientContextService>();
  SessionRosterService sessionRosterService = Get.find<SessionRosterService>();

  Future<Map<PrincipalActivityId, String>> getScheduledPrincipalActivity() async {
    Schedule schedule = await clientContextService.schedule;
    Set<String> scheduledPrincipalActivityIds = schedule.principalActivityRefs;
    Set<PrincipalActivity> scheduledPrincipalActivities = await backend.getObjects(scheduledPrincipalActivityIds);
    Map<PrincipalActivityId, String> scheduledPrincipalActivityMap = {};
    for (PrincipalActivity activity in scheduledPrincipalActivities) {
      scheduledPrincipalActivityMap[activity.id] = activity.name;
    }
    return scheduledPrincipalActivityMap;
  }

  // Future<List<PrincipalActivityId>> orderActivities(CamperId camperId, Set<PrincipalActivityId> principalActivityIds) async {
  //   Camper camper = await backend.getObject(camperId);
  //   CamperPreference? camperPreference = camper.camperPreferenceCmp != null ? await backend.getObject(camper.camperPreferenceCmp!) : null;
  //   if (camperPreference != null && ModelHelperFunctions.preferenceCompleted(camperPreference, schedule) ) {
  //
  //   }
  // }

  Future<void> addBlockToDay(Commit commit, String scheduleDayToAddToId, ScheduleBlock blockToAdd) async {
    ScheduleDay day = commit.getObject(scheduleDayToAddToId) ?? await backend.getObject(scheduleDayToAddToId);
    day.blockCmps.add(blockToAdd.id);
    commit.addObjectsToPush({blockToAdd, day});
  }

  Future<void> scheduleAMABlock(Commit commit, String name, String scheduleDayId, DateTime start, DateTime end) async {
    // TODO: infer the day from the start and end
    //  TODO: Add robust checking to make sure the AMA block doesn't overlap with other blocks or span days
    AMABlock amaBlockToCreate = AMABlock(name: name, isTemplate: false, start: start, end: end);
    commit.addObjectToPush(amaBlockToCreate);
    Schedule schedule = commit.getObjectOfType() ?? await clientContextService.schedule; // TODO: Remove this
    addBlockToDay(commit, schedule.scheduleDayCmps.first, amaBlockToCreate);
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

    Schedule schedule = commit.getObjectOfType() ?? await clientContextService.schedule;
    schedule.principalActivityRefs.add(activityToSchedule.principalPar);

    commit.addObjectsToPush({activityToSchedule, blockToAddTo, schedule});
  }

  // Future<void> assignCampersForBlock(Commit commit, String blockId) async {
  //   // 1. Fetch the Block object
  //   AMABlock? block = commit.getObject<AMABlock>(blockId) ?? await backend.getObject<AMABlock>(blockId);
  //   if (block == null) {
  //     // TODO: Use a more robust error handling/logging mechanism (e.g., ConsoleController)
  //     print('Error: Block with ID $blockId not found for assignment.');
  //     return;
  //   }
  //
  //   // 2. Fetch all relevant campers (e.g., from the current session roster)
  //   // TODO: Verify this is the correct way to get campers for the context
  //   List<String> camperIds = await sessionRosterService.getActiveCamperIds(); // Assuming this method exists
  //   List<Camper> campersToProcess = [];
  //   for (String camperId in camperIds) {
  //     Camper? camper = commit.getObject<Camper>(camperId) ?? await backend.getObject<Camper>(camperId);
  //     if (camper != null) {
  //       campersToProcess.add(camper);
  //     } else {
  //       // TODO: Log appropriately (e.g., ConsoleController.warning)
  //       print('Warning: Camper with ID $camperId not found while preparing for assignment.');
  //     }
  //   }
  //
  //   // Randomize the order to ensure fairness if multiple campers have same prefs
  //   campersToProcess.shuffle(Random());
  //
  //   // 3. Iterate through campers and attempt assignment
  //   for (Camper camper in campersToProcess) {
  //     // ASSUMPTION: Camper model has activityAssignments Map<String, String> { blockId: activityDependentId }
  //     // TODO: Verify 'activityAssignments' field name and structure
  //     if (camper.activityAssignments.containsKey(blockId)) {
  //       // Already assigned in this block (maybe manually or previous run), skip.
  //       continue;
  //     }
  //
  //     // ASSUMPTION: Camper model has activityPreferences Map<String, String> { blockId: activityPreferenceSetId }
  //     // TODO: Verify 'activityPreferences' field name and structure
  //     String? preferenceSetId = camper.activityPreferences[blockId];
  //     if (preferenceSetId == null) {
  //       // TODO: Log appropriately (e.g., ConsoleController.error)
  //       print('Error: ${camper.fullName} has no preference set defined for block ${block.name} ($blockId).');
  //       continue;
  //     }
  //
  //     // Fetch the preferences object
  //     // ASSUMPTION: An ActivityPreferenceSet model exists with isComplete (bool) and rankedPreferences (Map<String, int> { activityDependentId: rank })
  //     // TODO: Verify ActivityPreferenceSet model name and field names ('isComplete', 'rankedPreferences')
  //     ActivityPreferenceSet? preferences = commit.getObject<ActivityPreferenceSet>(preferenceSetId) ?? await backend.getObject<ActivityPreferenceSet>(preferenceSetId);
  //     if (preferences == null) {
  //       // TODO: Log appropriately
  //       print('Error: Could not load preference set $preferenceSetId for ${camper.fullName} in block ${block.name}.');
  //       continue;
  //     }
  //     if (!preferences.isComplete) {
  //       // TODO: Log appropriately (e.g., ConsoleController.warning)
  //       print('Warning: ${camper.fullName} has incomplete preferences for ${block.name} and will not be assigned.');
  //       continue;
  //     }
  //
  //     // Get sorted list of preferred activity IDs for this block
  //     var rankedPrefs = preferences.rankedPreferences;
  //     List<String> sortedActivityIds = rankedPrefs.keys.toList()
  //       ..sort((actIdA, actIdB) => rankedPrefs[actIdA]!.compareTo(rankedPrefs[actIdB]!));
  //
  //     // Attempt assignment based on rank order
  //     bool camperAssigned = false;
  //     int rank = 1;
  //     for (String activityDepId in sortedActivityIds) {
  //       // Ensure the activity is actually part of the block we're processing
  //       ActivityDependent? actDep = commit.getObject<ActivityDependent>(activityDepId) ?? await backend.getObject<ActivityDependent>(activityDepId);
  //       if (actDep == null) {
  //         // TODO: Log appropriately
  //         print('Warning: ActivityDependent $activityDepId (Rank $rank for ${camper.fullName}) not found. Skipping.');
  //         rank++;
  //         continue;
  //       }
  //       // ASSUMPTION: ActivityDependent has blockRef (String) field
  //       // TODO: Verify 'blockRef' field name
  //       if (actDep.blockRef != blockId) {
  //         // TODO: Log appropriately
  //         print('Warning: Activity ${actDep.id} is in camper ${camper.fullName}\'s preferences for block ${block.name}, but belongs to a different block (${actDep.blockRef}). Skipping.');
  //         rank++;
  //         continue;
  //       }
  //
  //       // TODO: Log attempt (e.g., ConsoleController.log)
  //       // print('Attempting to assign ${camper.fullName} to activity $activityDepId, ranked: $rank');
  //
  //       // Call the updated assignment function, passing the commit and IDs
  //       bool success = await assignCamperToActivity(commit, camper.id, activityDepId);
  //
  //       if (success) {
  //         camperAssigned = true;
  //         // assignCamperToActivity handles adding modified objects to the commit
  //         // TODO: Log success (e.g., ConsoleController.success)
  //         // Fetching the PrincipalActivity name for logging might be nice, but requires another fetch here or passing more data back from assignCamperToActivity.
  //         // print('Successfully assigned ${camper.fullName} to activity $activityDepId');
  //         break; // Move to the next camper
  //       }
  //       rank++;
  //     }
  //
  //     if (!camperAssigned) {
  //       // TODO: Handle unassigned campers (e.g., assign to a default 'unassigned' activity, log for manual review - ConsoleController.error)
  //       print('Error: ${camper.fullName} could not be assigned to any preferred activity in ${block.name}.');
  //     }
  //   }
  //   // No explicit commit.push() here, assuming it happens after the calling function finishes its operations.
  // }

  // /// Attempts to assign a specific camper to a specific activity.
  // /// Checks capacity, handles re-assignment within the same block, and updates objects in the commit.
  // /// Returns true if successful, false otherwise.
  // Future<bool> assignCamperToActivity(Commit commit, String camperId, String activityDepId) async {
  //   // 1. Fetch objects needed
  //   Camper? camper = commit.getObject<Camper>(camperId) ?? await backend.getObject<Camper>(camperId);
  //   ActivityDependent? activityDep = commit.getObject<ActivityDependent>(activityDepId) ?? await backend.getObject<ActivityDependent>(activityDepId);
  //
  //   if (camper == null || activityDep == null) {
  //     // TODO: Log appropriately
  //     print('Error: Could not find Camper ($camperId) or ActivityDependent ($activityDepId) for assignment.');
  //     return false;
  //   }
  //
  //   // Fetch the PrincipalActivity to get capacity and name
  //   // ASSUMPTION: ActivityDependent has principalPar (String) field linking to PrincipalActivity ID
  //   // TODO: Verify 'principalPar' field name
  //   PrincipalActivity? principalActivity = commit.getObject<PrincipalActivity>(activityDep.principalPar) ?? await backend.getObject<PrincipalActivity>(activityDep.principalPar);
  //   if (principalActivity == null) {
  //     // TODO: Log appropriately
  //     print('Error: Could not find PrincipalActivity (${activityDep.principalPar}) for ActivityDependent ${activityDep.id}. Cannot check capacity.');
  //     return false;
  //   }
  //
  //   // 2. Check capacity
  //   // ASSUMPTION: ActivityDependent has rosterCmps (List<String>) field for camper IDs
  //   // TODO: Verify 'rosterCmps' field name
  //   // ASSUMPTION: PrincipalActivity has capacity (int) field
  //   // TODO: Verify 'capacity' field name
  //   int currentSize = activityDep.rosterCmps.length;
  //   int capacity = principalActivity.capacity;
  //
  //   // Ensure camper isn't already counted if they happen to be in the roster list already (shouldn't happen if logic is correct, but safe check)
  //   bool alreadyInRoster = activityDep.rosterCmps.contains(camperId);
  //   if (!alreadyInRoster && currentSize >= capacity) {
  //     // TODO: Log appropriately (e.g., ConsoleController.error or .log)
  //     print('Assigning ${camper.fullName} to ${principalActivity.name} ($activityDepId) would exceed capacity. Current: $currentSize, Capacity: $capacity');
  //     return false;
  //   }
  //
  //   // 3. Handle potential reassignment within the same block
  //   // ASSUMPTION: ActivityDependent has blockRef (String) field
  //   // TODO: Verify 'blockRef' field name
  //   // ASSUMPTION: Camper has activityAssignments Map<String, String> { blockId: activityDependentId }
  //   // TODO: Verify 'activityAssignments' field name
  //   String blockId = activityDep.blockRef;
  //   if (camper.activityAssignments.containsKey(blockId)) {
  //     String? currentAssignedActivityId = camper.activityAssignments[blockId];
  //     if (currentAssignedActivityId != null && currentAssignedActivityId != activityDepId) {
  //       // Camper is assigned to a *different* activity in this block, remove them first.
  //       // TODO: Log appropriately
  //       print('Info: ${camper.fullName} is currently in activity $currentAssignedActivityId, removing before assigning to ${principalActivity.name} ($activityDepId).');
  //       bool removed = await removeCamperFromActivity(commit, camperId, currentAssignedActivityId);
  //       if (!removed) {
  //         // TODO: Log appropriately
  //         print('Error: Failed to remove ${camper.fullName} from previous activity $currentAssignedActivityId. Assignment to $activityDepId aborted.');
  //         return false;
  //       }
  //       // Re-fetch camper object as it was modified in the commit by removeCamperFromActivity
  //       // It *must* be in the commit now, so no fallback to backend.
  //       camper = commit.getObject<Camper>(camperId);
  //       if (camper == null) {
  //         // This would be a critical internal error with the commit system
  //         print('CRITICAL Error: Camper $camperId disappeared from commit after removal.');
  //         return false;
  //       }
  //     } else if (currentAssignedActivityId == activityDepId) {
  //       // Already assigned to this exact activity. Consider it success.
  //       // TODO: Log appropriately (e.g., ConsoleController.log or .info)
  //       print('Info: ${camper.fullName} is already assigned to ${principalActivity.name} ($activityDepId). No action needed.');
  //       return true;
  //     }
  //   }
  //
  //   // 4. Perform the assignment: Update ActivityDependent roster and Camper assignment
  //   // Create modifiable copies, update them, and assign back to the objects.
  //
  //   // Update roster (handle potential immutability)
  //   List<String> updatedRoster = activityDep.rosterCmps.toList(); // Create modifiable copy
  //   if (!updatedRoster.contains(camperId)) { // Add camper if not already present
  //     updatedRoster.add(camperId);
  //     activityDep.rosterCmps = updatedRoster; // Assign the updated list back
  //   }
  //
  //   // Update camper's assignments (handle potential immutability)
  //   Map<String, String> updatedAssignments = camper.activityAssignments.toMap(); // Create modifiable copy
  //   updatedAssignments[blockId] = activityDepId; // Set the assignment for this block
  //   camper.activityAssignments = updatedAssignments; // Assign the updated map back
  //
  //   // 5. Add the modified objects to the commit
  //   commit.addObjectsToPush({camper, activityDep});
  //
  //   // TODO: Log success (e.g., ConsoleController.success)
  //   print('${camper.fullName} successfully assigned to ${principalActivity.name} ($activityDepId)');
  //   return true;
  // }
  //
  // /// Removes a camper from a specific activity's roster and updates their assignment map.
  // /// Modifies objects within the commit. Returns true on success or if state was already correct.
  // Future<bool> removeCamperFromActivity(Commit commit, String camperId, String activityDepId) async {
  //   Camper? camper = commit.getObject<Camper>(camperId) ?? await backend.getObject<Camper>(camperId);
  //   ActivityDependent? activityDep = commit.getObject<ActivityDependent>(activityDepId) ?? await backend.getObject<ActivityDependent>(activityDepId);
  //
  //   if (camper == null || activityDep == null) {
  //     // TODO: Log appropriately
  //     print('Error: Could not find Camper ($camperId) or ActivityDependent ($activityDepId) for removal.');
  //     return false; // Indicate failure
  //   }
  //
  //   // Fetch Principal name for logging clarity
  //   PrincipalActivity? principalActivity = commit.getObject<PrincipalActivity>(activityDep.principalPar) ?? await backend.getObject<PrincipalActivity>(activityDep.principalPar);
  //   String activityName = principalActivity?.name ?? 'Unknown Activity';
  //
  //
  //   // ASSUMPTION: ActivityDependent has blockRef (String) field
  //   // TODO: Verify 'blockRef' field name
  //   String blockId = activityDep.blockRef;
  //   bool changed = false;
  //
  //   // Remove camper from activity roster
  //   // ASSUMPTION: ActivityDependent has rosterCmps (List<String>) field
  //   // TODO: Verify 'rosterCmps' field name
  //   List<String> updatedRoster = activityDep.rosterCmps.toList(); // Modifiable copy
  //   if (updatedRoster.remove(camperId)) {
  //     activityDep.rosterCmps = updatedRoster; // Assign back updated list
  //     changed = true;
  //   }
  //
  //   // Remove assignment from camper object
  //   // ASSUMPTION: Camper has activityAssignments Map<String, String> { blockId: activityDependentId }
  //   // TODO: Verify 'activityAssignments' field name
  //   Map<String, String> updatedAssignments = camper.activityAssignments.toMap(); // Modifiable copy
  //   // Only remove if the assignment map actually points to this activity for this block
  //   if (updatedAssignments.containsKey(blockId) && updatedAssignments[blockId] == activityDepId) {
  //     updatedAssignments.remove(blockId);
  //     camper.activityAssignments = updatedAssignments; // Assign back updated map
  //     changed = true;
  //   }
  //
  //   if (changed) {
  //     // Add modified objects to commit ONLY if changes were made
  //     commit.addObjectsToPush({camper, activityDep});
  //     // TODO: Log removal (e.g., ConsoleController.log)
  //     print('${camper.fullName} removed from ${activityName} ($activityDepId)');
  //     return true; // Indicate success
  //   } else {
  //     // TODO: Log warning (e.g., ConsoleController.warning)
  //     print('Warning: Attempted to remove ${camper.fullName} from ${activityName} ($activityDepId), but they were not found in the roster or assignment map for that block.');
  //     // Return true because the desired state (camper not assigned to this activity) is effectively true.
  //     return true;
  //   }
  // }

}