import 'dart:math';

import 'package:collection/collection.dart';
import 'package:get/get.dart';

import '../../ember_core.dart';

class AssignmentService extends GetxService {
  final RosterService rosterService = Get.find<RosterService>();
  final ScheduleService scheduleService = Get.find<ScheduleService>();

  /// Runs the full camper assignment algorithm for all registered campers.
  Future<void> runAssignmentAlgorithm({
    required Commit commit,
    required double assignmentPenalty,
    required double nonAssignmentFriction,
  }) async {
    Debug.logInfo('Running full assignment algorithm...', verbosity: Verbosity.verbose);
    final Set<Camper> allRegisteredCampersFromCommit = commit.getObjectsOfType<Camper>();
    final List<Camper> allCampers =
        (allRegisteredCampersFromCommit.isNotEmpty ? allRegisteredCampersFromCommit : await rosterService.registeredCampers)
            .toList();
    // Use the new targeted method, passing all camper IDs.
    await runAssignmentForCampers(
      commit: commit,
      camperIds: allCampers.map((c) => c.id).toSet(),
      assignmentPenalty: assignmentPenalty,
      nonAssignmentFriction: nonAssignmentFriction,
    );
    Debug.logSuccess('Full assignment algorithm complete.', verbosity: Verbosity.verbose);
  }

  /// Runs the assignment algorithm for a specific set of campers across all AMA blocks.
  ///
  /// This method uses preference weights, penalties, and friction.
  Future<void> runAssignmentForCampers({
    required Commit commit,
    required Set<CamperId> camperIds,
    required double assignmentPenalty,
    required double nonAssignmentFriction,
  }) async {
    Debug.logInfo('Running targeted assignment for ${camperIds.length} campers...', verbosity: Verbosity.verbose);
    // 1. Fetch all necessary data.
    Debug.logInfo('Fetching necessary data for assignment...', verbosity: Verbosity.verbose);
    // We fetch from the commit object first, and fall back to the service to avoid redundant pulls.
    final Set<Camper> campersInCommit = commit.getObjectsOfType<Camper>();
    final List<Camper> allRegisteredCampers =
        (campersInCommit.isNotEmpty ? campersInCommit.toList() : (await rosterService.registeredCampers).toList());

    final Set<AMABlock> blocksInCommit = commit.getObjectsOfType<AMABlock>();
    final Set<AMABlock> scheduleBlockSet =
        (blocksInCommit.isNotEmpty ? blocksInCommit : await scheduleService.amas);

    final Set<ActivityDependent> dependentsInCommit = commit.getObjectsOfType<ActivityDependent>();
    final Set<ActivityDependent> allDependentsSet =
        (dependentsInCommit.isNotEmpty ? dependentsInCommit : await scheduleService.activityDependents);

    final Set<PrincipalActivity> principalsInCommit = commit.getObjectsOfType<PrincipalActivity>();
    final Map<String, PrincipalActivity> allPrincipals;
    if (principalsInCommit.isNotEmpty) {
      allPrincipals = {for (var p in principalsInCommit) p.id: p};
    } else {
      allPrincipals = await scheduleService.principleActivities;
    }
    Debug.logSuccess('Data fetched.', verbosity: Verbosity.verbose);

    // Filter to get only the campers specified in the input set.
    final List<Camper> campersToAssign = allRegisteredCampers.where((c) => camperIds.contains(c.id)).toList();

    final List<AMABlock> scheduleBlocks = scheduleBlockSet.toList();

    if (campersToAssign.isEmpty || scheduleBlocks.isEmpty) {
      Debug.logWarning('Assignment algorithm skipped: No campers or AMA blocks to process.', verbosity: Verbosity.verbose);
      return;
    }

    // 2. Prepare data structures for the specified campers.
    Debug.logInfo('Preparing data structures for assignment...', verbosity: Verbosity.verbose);
    final Map<ActivityDependentId, ActivityDependent> allDependents = {for (var dep in allDependentsSet) dep.id: dep};
    final List<CamperId> shuffledCamperIds = _createShuffledCamperList(campersToAssign);
    final Map<CamperId, Camper> camperMap = {for (var c in campersToAssign) c.id: c};
    final Map<CamperId, Map<PrincipalActivityId, double>> workingPreferences = {
      for (var camper in campersToAssign) camper.id: Map<PrincipalActivityId, double>.from(camper.preferenceWeightRefs),
    };
    Debug.logSuccess('Data structures prepared.', verbosity: Verbosity.verbose);

    // 3. The core loop: iterate through blocks and assign the specified campers.
    Debug.logInfo('Starting camper assignment loop...', verbosity: Verbosity.verbose);
    await _assignCampersToBlocks(
      commit,
      camperMap,
      scheduleBlocks,
      shuffledCamperIds,
      workingPreferences,
      allDependents,
      allPrincipals,
      assignmentPenalty,
      nonAssignmentFriction,
    );
    Debug.logSuccess('Camper assignment loop complete.', verbosity: Verbosity.verbose);

    // 4. Persist the final calculated preference weights for the assigned campers.
    Debug.logInfo('Persisting final preference weights...', verbosity: Verbosity.verbose);
    for (var camperId in workingPreferences.keys) {
      final camper = camperMap[camperId]!;
      camper.preferenceWeightRefs
        ..clear()
        ..addAll(workingPreferences[camperId]!);
      commit.addObjectToPush(camper);
    }
    Debug.logSuccess('Preference weights persisted.', verbosity: Verbosity.verbose);
    Debug.logSuccess('Targeted assignment complete for ${camperIds.length} campers.', verbosity: Verbosity.verbose);
  }

  /// Assigns a single camper to their best available activity within a specific AMA block.
  ///
  /// This method uses the camper's base preferences but ignores preference weights.
  /// Returns `true` if the camper was successfully assigned, `false` otherwise.
  Future<bool> assignCamperInBlock({
    required Commit commit,
    required CamperId camperId,
    required AMABlockId amaId,
  }) async {
    Debug.logInfo('Assigning single camper $camperId in block $amaId...', verbosity: Verbosity.verbose);
    // 1. Fetch the necessary data.
    final Camper? camper = commit.getObject(camperId) ?? (await rosterService.registeredCampers).firstWhereOrNull((c) => c.id == camperId);
    final AMABlock? block = commit.getObject(amaId) ?? (await scheduleService.amas).firstWhereOrNull((b) => b.id == amaId);

    if (camper == null || block == null) {
      Debug.logWarning('Could not run single assignment: Camper or AMABlock not found.', verbosity: Verbosity.verbose);
      return false;
    }

    final Set<ActivityDependent> dependentsInCommit = commit.getObjectsOfType<ActivityDependent>();
    final allDependentsSet =
        (dependentsInCommit.isNotEmpty ? dependentsInCommit : await scheduleService.activityDependents).toSet();

    final Map<ActivityDependentId, ActivityDependent> allDependents =
    {for (var dep in allDependentsSet) dep.id: dep};

    final Set<PrincipalActivity> principalsInCommit = commit.getObjectsOfType<PrincipalActivity>();
    final Map<String, PrincipalActivity> allPrincipals;
    if (principalsInCommit.isNotEmpty) {
      allPrincipals = {for (var p in principalsInCommit) p.id: p};
    } else {
      allPrincipals = await scheduleService.principleActivities;
    }

    final List<ActivityDependent> activitiesInBlock =
        block.activityDependentCmps.map((id) => allDependents[id]).whereType<ActivityDependent>().toList();

    // 2. Find and assign the best activity using the refactored helper method.
    // No weights or penalties are passed, so it performs a simple preference-based assignment.
    final result = await _assignBestActivityForCamper(
      commit,
      camper,
      activitiesInBlock,
      allPrincipals,
    );
    if(result) {
      Debug.logSuccess('Successfully assigned camper $camperId in block $amaId.', verbosity: Verbosity.verbose);
    } else {
      Debug.logWarning('Failed to assign camper $camperId in block $amaId.', verbosity: Verbosity.verbose);
    }
    return result;
  }

  List<CamperId> _createShuffledCamperList(List<Camper> campers) {
    final List<CamperId> camperIds = campers.map((c) => c.id).toList();
    camperIds.shuffle(Random());
    return camperIds;
  }

  Future<void> _assignCampersToBlocks(
    Commit commit,
    Map<CamperId, Camper> camperMap,
    List<AMABlock> scheduleBlocks,
    List<CamperId> shuffledCamperIds,
    Map<CamperId, Map<PrincipalActivityId, double>> workingPreferences,
    Map<ActivityDependentId, ActivityDependent> allDependents,
    Map<PrincipalActivityId, PrincipalActivity> allPrincipals,
    double assignmentPenalty,
    double nonAssignmentFriction,
  ) async {
    bool forward = true;
    for (final block in scheduleBlocks) {
      Debug.logInfo('Assigning campers for block ${block.id}. Direction: ${forward ? "forward" : "backward"}', verbosity: Verbosity.verbose);
      final List<CamperId> camperOrder = forward ? shuffledCamperIds : shuffledCamperIds.reversed.toList();
      final List<ActivityDependent> activitiesInBlock =
          block.activityDependentCmps.map((id) => allDependents[id]).whereType<ActivityDependent>().toList();

      for (final camperId in camperOrder) {
        final camper = camperMap[camperId]!;
        final bool assigned = await _assignBestActivityForCamper(
          commit,
          camper,
          activitiesInBlock,
          allPrincipals,
          // Pass the weight-related parameters for the full algorithm
          camperWorkingPrefs: workingPreferences[camperId]!,
          assignmentPenalty: assignmentPenalty,
          nonAssignmentFriction: nonAssignmentFriction,
        );
        if (assigned) {
          camperMap[camperId] = commit.getObject(camperId)!;
        }
      }
      forward = !forward; // Snake draft reversal.
    }
  }

  /// Finds the best activity for a camper in a given list and assigns them.
  Future<bool> _assignBestActivityForCamper(
    Commit commit,
    Camper camper,
    List<ActivityDependent> activitiesInBlock,
    Map<PrincipalActivityId, PrincipalActivity> allPrincipals, {
    Map<PrincipalActivityId, double>? camperWorkingPrefs,
    double? assignmentPenalty,
    double? nonAssignmentFriction,
  }) async {
    // 1. Get the activities sorted by preference for this specific camper.
    final List<ActivityDependent> sortedActivities = _getSortedActivitiesForCamper(
      activitiesInBlock: activitiesInBlock,
      camper: camper,
      camperWorkingPrefs: camperWorkingPrefs,
    );

    // 2. Attempt to assign the camper from the now-sorted list of activities.
    return await _attemptAssignmentFromSortedList(
      commit: commit,
      camper: camper,
      sortedActivities: sortedActivities,
      allPrincipals: allPrincipals,
      camperWorkingPrefs: camperWorkingPrefs,
      assignmentPenalty: assignmentPenalty,
      nonAssignmentFriction: nonAssignmentFriction,
    );
  }

  /// Creates a shuffled copy of activities and sorts it based on the camper's preferences.
  List<ActivityDependent> _getSortedActivitiesForCamper({
    required List<ActivityDependent> activitiesInBlock,
    required Camper camper,
    Map<PrincipalActivityId, double>? camperWorkingPrefs,
  }) {
    // Create a new, shuffled list for each camper to prevent mutation issues and ensure fairness.
    final List<ActivityDependent> shuffledActivities = List.from(activitiesInBlock)..shuffle();

    shuffledActivities.sort((a, b) {
      final double weightA = camperWorkingPrefs?[a.principalPar] ?? 1.0;
      final double weightB = camperWorkingPrefs?[b.principalPar] ?? 1.0;
      final double prefA = _calculateScaledPreference(camper.preferenceRefs[a.principalPar], weightA);
      final double prefB = _calculateScaledPreference(camper.preferenceRefs[b.principalPar], weightB);

      // Descending sort.
      return prefB.compareTo(prefA);
    });
    return shuffledActivities;
  }

  /// Iterates through a sorted list of activities and assigns the camper to the first one with capacity.
  Future<bool> _attemptAssignmentFromSortedList({
    required Commit commit,
    required Camper camper,
    required List<ActivityDependent> sortedActivities,
    required Map<PrincipalActivityId, PrincipalActivity> allPrincipals,
    Map<PrincipalActivityId, double>? camperWorkingPrefs,
    double? assignmentPenalty,
    double? nonAssignmentFriction,
  }) async {
    for (final activityDep in sortedActivities) {
      final principalAct = allPrincipals[activityDep.principalPar];
      if (principalAct == null) {
        Debug.logWarning('Principal activity not found for dependent ${activityDep.id}, skipping.', verbosity: Verbosity.verbose);
        continue;
      }

      final ActivityDependent activityInCommit = commit.getObject(activityDep.id) ?? activityDep;

      if (activityInCommit.camperRefs.length < principalAct.capacity) {
        final bool success = await rosterService.assignCamperToActivity(commit, camper.id, activityDep.id);
        if (success) {
          Debug.logSuccess('Assigned camper ${camper.id} to activity ${activityDep.id}', verbosity: Verbosity.verbose);
          if (camperWorkingPrefs != null && assignmentPenalty != null && nonAssignmentFriction != null) {
          _updateWorkingPreferences(camperWorkingPrefs, activityDep.principalPar, assignmentPenalty, nonAssignmentFriction);
        }
          return true;
        } else {
          Debug.logWarning('Failed to assign camper ${camper.id} to activity ${activityDep.id} via rosterService.', verbosity: Verbosity.verbose);
      }
    }
  }
    Debug.logInfo('Camper ${camper.id} could not be assigned to any activity in this block.', verbosity: Verbosity.verbose);
    return false;
  }

  double _calculateScaledPreference(double? basePreference, double? currentWeight) {
    // Treat a null (unspecified) preference as 0.5 instead of 0.0.
    return (basePreference ?? 0.5) * (currentWeight ?? 1.0);
  }

  void _updateWorkingPreferences(
    Map<PrincipalActivityId, double> workingPreferences,
    PrincipalActivityId assignedActivityId,
    double assignmentPenalty,
    double nonAssignmentFriction,
  ) {
    final allKeys = Set<String>.from(workingPreferences.keys)..add(assignedActivityId);
    for (final key in allKeys) {
      workingPreferences.putIfAbsent(key, () => 1.0);
    }

    workingPreferences.forEach((activityId, weight) {
      if (activityId == assignedActivityId) {
        workingPreferences[activityId] = weight * assignmentPenalty;
      } else {
        workingPreferences[activityId] = weight + ((1.0 - weight) * nonAssignmentFriction);
      }
    });
  }
}
