import 'dart:math';

import 'package:ember_core/src/models/core_objects/schedule_day.dart';
import 'package:ember_core/src/utils/model_helper_functions.dart';
import 'package:get/get.dart';

import '../../ember_core.dart';
import '../repositories/pull_repository.dart';

class ScheduleService extends GetxService {
  PullRepository pullRepo = Get.find<PullRepository>();
  ContextService clientContextService = Get.find<ContextService>();
  RosterService rosterService = Get.find<RosterService>();

  Future<Schedule> get schedule async => await clientContextService.schedule;
  Future<Set<ScheduleDay>> get scheduleDays async =>
      (await pullRepo.getObjectsInCollection<ScheduleDay>('schedule_day', 'ses')).values.toSet();
  Future<Set<AMABlock>> get amas async => (await pullRepo.getObjectsInCollection<AMABlock>('ama_block', 'ses')).values.toSet();
  Future<Set<ActivityDependent>> get activityDependents async =>
      (await pullRepo.getObjectsInCollection<ActivityDependent>('activity_dependent', 'ses')).values.toSet();
  Future<Map<PrincipalActivityId, PrincipalActivity>> get principleActivities async =>
      await pullRepo.getObjectsInCollection('principal_activity', 'brn');

  Future<List<dynamic>> getActivityData() async {
    return await Future.wait([amas, activityDependents, principleActivities]);
  }

  Future<Set<String>> getSkillsActivityIds() async {
    Schedule schedule = await clientContextService.schedule;
    Set<PrincipalActivity> scheduledPrincipalActivities = await pullRepo.getObjects(schedule.principalActivityRefs);
    final Set<String> output = {};
    for (PrincipalActivity activity in scheduledPrincipalActivities) {
      if (activity.isSkillsRec) {
        output.add(activity.id);
      }
    }
    return output;
  }

  // if onlySkillsRecs is false, skills recs will not be fetched
  Future<Map<PrincipalActivityId, String>> getScheduledPrincipalActivitiesToNames(bool onlySkillsRecs) async {
    Schedule schedule = await clientContextService.schedule;
    Set<String> scheduledPrincipalActivityIds = schedule.principalActivityRefs;
    Set<PrincipalActivity> scheduledPrincipalActivities = await pullRepo.getObjects(scheduledPrincipalActivityIds);
    Map<PrincipalActivityId, String> scheduledPrincipalActivityMap = {};
    for (PrincipalActivity activity in scheduledPrincipalActivities) {
      if (activity.isSkillsRec == onlySkillsRecs) {
        scheduledPrincipalActivityMap[activity.id] = activity.name;
      }
    }
    return scheduledPrincipalActivityMap;
  }

  Future<List<PrincipalActivityId>> getOrderedActivities(CamperId camperId, bool onlySkillsRecs) async {
    final results = await Future.wait([pullRepo.getObject(camperId), clientContextService.schedule, getSkillsActivityIds()]);
    final Camper camper = results[0] as Camper;
    final Schedule schedule = results[1] as Schedule;
    final List<String> skillsActivityIds = (results[2] as Set<String>).toList();

    final List<MapEntry<PrincipalActivityId, double?>> entries = camper.preferenceRefs.entries.toList();
    if (onlySkillsRecs) {
      entries.removeWhere((element) => !skillsActivityIds.contains(element.key));
    } else {
      entries.removeWhere((element) => skillsActivityIds.contains(element.key));
    }

    if (ModelHelperFunctions.preferenceCompleted(camper, schedule)) {
      entries.sort((entryA, entryB) {
        final double? scoreA = entryA.value;
        final double? scoreB = entryB.value;

        // Handle null cases: nulls are considered lower than any number
        if (scoreA == null && scoreB == null) {
          return 0; // Keep original relative order if both are null
        } else if (scoreA == null) {
          return 1; // scoreA (null) is considered smaller, should come after scoreB
        } else if (scoreB == null) {
          return -1; // scoreB (null) is considered smaller, scoreA should come before it
        } else {
          // Both scores are non-null, compare them in descending order
          // Using compareTo: B.compareTo(A) gives descending order
          return scoreB.compareTo(scoreA);
        }
      });
      return entries.map((entry) => entry.key).toList();
    } else {
      // If the camper hasn't already set their preferences, return the activities in a random order
      final List<PrincipalActivityId> activityIds = entries.map((e) => e.key).toList();
      activityIds.shuffle(Random());
      return activityIds;
    }
  }

  Future<void> addBlockToDay(Commit commit, String scheduleDayToAddToId, ScheduleBlock blockToAdd) async {
    ScheduleDay day = commit.getObject(scheduleDayToAddToId) ?? await pullRepo.getObject(scheduleDayToAddToId);
    day.blockCmps.add(blockToAdd.id);
    commit.addObjectsToPush({blockToAdd, day});
  }

  Future<void> scheduleAMABlock(
    Commit commit,
    String name,
    String scheduleDayId,
    DateTime start,
    DateTime end,
    bool isSkillsRec,
  ) async {
    // TODO: infer the day from the start and end
    //  TODO: Add robust checking to make sure the AMA block doesn't overlap with other blocks or span days
    AMABlock amaBlockToCreate = AMABlock(title: name, isTemplate: false, start: start, end: end, isSkillsRec: isSkillsRec);
    commit.addObjectToPush(amaBlockToCreate);
    Schedule schedule = commit.getObjectOfType() ?? await clientContextService.schedule; // TODO: Remove this
    addBlockToDay(commit, schedule.scheduleDayCmps.first, amaBlockToCreate);
  }

  void createPrincipalActivity(Commit commit, String name, int capacity, String description, bool isSkillsRec) {
    // TODO: Check with a query to make sure name is unique
    PrincipalActivity activityToCreate = PrincipalActivity(
      name: name,
      capacity: capacity,
      description: description,
      isSkillsRec: isSkillsRec,
    );
    commit.addObjectToPush(activityToCreate);
  }

  Future<void> scheduleActivity(Commit commit, String principalActivityId, String blockToAddToId) async {
    PrincipalActivity principalActivity =
        commit.getObject(principalActivityId) ?? (await pullRepo.getObject(principalActivityId));
    AMABlock blockToAddTo = commit.getObject(blockToAddToId) ?? (await pullRepo.getObject(blockToAddToId));
    ActivityDependent activityToSchedule = ActivityDependent(principalPar: principalActivity.id, blockRef: blockToAddTo.id);
    blockToAddTo.activityDependentCmps.add(activityToSchedule.id);

    Schedule schedule = commit.getObjectOfType() ?? await clientContextService.schedule;
    schedule.principalActivityRefs.add(activityToSchedule.principalPar);

    commit.addObjectsToPush({activityToSchedule, blockToAddTo, schedule});
  }

  Future<Map<String, ScheduleBlock>> getScheduleBlocks() async {
    Set<ScheduleDay> scheduleDays = await this.scheduleDays;
    Set<String> blockRefs = {};
    for (ScheduleDay scheduleDay in scheduleDays) {
      blockRefs.addAll(scheduleDay.blockCmps);
    }
    Set<ScheduleBlock> blocks = await pullRepo.getObjects(blockRefs);
    Map<String, ScheduleBlock> output = {};
    for (ScheduleBlock block in blocks) {
      output[block.id] = block;
    }
    return output;
  }

  Future<Map<String, AMABlock>> getAMABlocks() async {
    Map<String, ScheduleBlock> blocks = await getScheduleBlocks();
    Map<String, AMABlock> output = {};
    for (ScheduleBlock block in blocks.values) {
      if (block is AMABlock) {
        output[block.id] = block;
      }
    }
    return output;
  }

  // Future<void> assignCampersForBlock({
  //   required Commit commit,
  //   required String blockId
  //   bool reassignAssignedCampers
  // }) async {
  //   // 1. Fetch the Block object
  //   AMABlock? block = commit.getObject<AMABlock>(blockId) ?? await pullRepo.getObject<AMABlock>(blockId);
  //
  //   // 2. Fetch all relevant campers (e.g., from the current session roster)
  //   // TODO: FIX THIS METHOD IN SESSION ROSTER SERVICE TO TAKE A COMMIT AND CHECK IT FIRST
  //   List<Camper> campersToProcess = (await rosterService.registeredCampers).toList();
  //
  //   // Randomize the order to ensure fairness if multiple campers have same prefs
  //   campersToProcess.shuffle(Random());
  //
  //   // 3. Iterate through campers and attempt assignment
  //   for (Camper camper in campersToProcess) {
  //     if (camper.activityAssignmentRefs.containsKey(blockId)) {
  //       // Already assigned in this block (maybe manually or previous run), skip.
  //       continue;
  //     }
  //
  //     // ASSUMPTION: Camper model has activityPreferences Map<String, String> { blockId: activityPreferenceSetId }
  //     // TODO: Verify 'activityPreferences' field name and structure
  //     String? preferenceSetId = camper.activityPreferences[blockId];
  //     if (preferenceSetId == null) {
  //       // TODO: Log appropriately (e.g., ConsoleController.error)
  //       Debug.logInfo('Error: ${camper.fullName} has no preference set defined for block ${block.name} ($blockId).');
  //       continue;
  //     }
  //
  //     // Fetch the preferences object
  //     // ASSUMPTION: An ActivityPreferenceSet model exists with isComplete (bool) and rankedPreferences (Map<String, int> { activityDependentId: rank })
  //     // TODO: Verify ActivityPreferenceSet model name and field names ('isComplete', 'rankedPreferences')
  //     ActivityPreferenceSet? preferences = commit.getObject<ActivityPreferenceSet>(preferenceSetId) ?? await pullRepo.getObject<ActivityPreferenceSet>(preferenceSetId);
  //     if (preferences == null) {
  //       // TODO: Log appropriately
  //       Debug.logInfo('Error: Could not load preference set $preferenceSetId for ${camper.fullName} in block ${block.name}.');
  //       continue;
  //     }
  //     if (!preferences.isComplete) {
  //       // TODO: Log appropriately (e.g., ConsoleController.warning)
  //       Debug.logInfo('Warning: ${camper.fullName} has incomplete preferences for ${block.name} and will not be assigned.');
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
  //       ActivityDependent? actDep = commit.getObject<ActivityDependent>(activityDepId) ?? await pullRepo.getObject<ActivityDependent>(activityDepId);
  //       if (actDep == null) {
  //         // TODO: Log appropriately
  //         Debug.logInfo('Warning: ActivityDependent $activityDepId (Rank $rank for ${camper.fullName}) not found. Skipping.');
  //         rank++;
  //         continue;
  //       }
  //       // ASSUMPTION: ActivityDependent has blockRef (String) field
  //       // TODO: Verify 'blockRef' field name
  //       if (actDep.blockRef != blockId) {
  //         // TODO: Log appropriately
  //         Debug.logInfo('Warning: Activity ${actDep.id} is in camper ${camper.fullName}\'s preferences for block ${block.name}, but belongs to a different block (${actDep.blockRef}). Skipping.');
  //         rank++;
  //         continue;
  //       }
  //
  //       // TODO: Log attempt (e.g., ConsoleController.log)
  //       // Debug.logInfo('Attempting to assign ${camper.fullName} to activity $activityDepId, ranked: $rank');
  //
  //       // Call the updated assignment function, passing the commit and IDs
  //       bool success = await assignCamperToActivity(commit, camper.id, activityDepId);
  //
  //       if (success) {
  //         camperAssigned = true;
  //         // assignCamperToActivity handles adding modified objects to the commit
  //         // TODO: Log success (e.g., ConsoleController.success)
  //         // Fetching the PrincipalActivity name for logging might be nice, but requires another fetch here or passing more data back from assignCamperToActivity.
  //         // Debug.logInfo('Successfully assigned ${camper.fullName} to activity $activityDepId');
  //         break; // Move to the next camper
  //       }
  //       rank++;
  //     }
  //
  //     if (!camperAssigned) {
  //       // TODO: Handle unassigned campers (e.g., assign to a default 'unassigned' activity, log for manual review - ConsoleController.error)
  //       Debug.logInfo('Error: ${camper.fullName} could not be assigned to any preferred activity in ${block.name}.');
  //     }
  //   }
  //   // No explicit commit.push() here, assuming it happens after the calling function finishes its operations.
  // }
}
