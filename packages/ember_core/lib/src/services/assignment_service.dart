import 'dart:math';

import 'package:collection/collection.dart';
import 'package:get/get.dart';

import '../../ember_core.dart';

/// A private helper class to hold all the data required for an assignment run.
/// This avoids passing many parameters and allows for cleaner data fetching.
class _AssignmentData {
  final Map<CamperId, Camper> campers;
  final List<AMABlock> blocks;
  final Map<ActivityDependentId, ActivityDependent> dependents;
  final Map<PrincipalActivityId, PrincipalActivity> principals;

  _AssignmentData({
    required this.campers,
    required this.blocks,
    required this.dependents,
    required this.principals,
  });
}

class AssignmentService extends GetxService {
  final RosterService rosterService = Get.find<RosterService>();
  final ScheduleService scheduleService = Get.find<ScheduleService>();

  /// Gathers all necessary data for the assignment algorithm in bulk.
  ///
  /// Fetches campers, AMA blocks, dependents, and principals from the commit or services,
  /// filters them based on the provided camperIds, and returns them in a tidy container.
  Future<_AssignmentData> _gatherDataForAssignment(Commit commit, Set<CamperId> camperIds) async {
    Debug.logInfo('Fetching necessary data for assignment...', verbosity: Verbosity.verbose);

    // 1. Fetch all data from commit or services
    final allCampersFuture =
        commit.getObjectsOfType<Camper>().isNotEmpty
            ? Future.value(commit.getObjectsOfType<Camper>())
            : rosterService.registeredCampers;
    final allBlocksFuture =
        commit.getObjectsOfType<AMABlock>().isNotEmpty ? Future.value(commit.getObjectsOfType<AMABlock>()) : scheduleService.amas;
    final allDependentsFuture =
        commit.getObjectsOfType<ActivityDependent>().isNotEmpty
            ? Future.value(commit.getObjectsOfType<ActivityDependent>())
            : scheduleService.activityDependents;
    final allPrincipalsFuture =
        commit.getObjectsOfType<PrincipalActivity>().isNotEmpty
            ? Future.value({for (var p in commit.getObjectsOfType<PrincipalActivity>()) p.id: p})
            : scheduleService.principleActivities;

    final results = await Future.wait([
      allCampersFuture,
      allBlocksFuture,
      allDependentsFuture,
      allPrincipalsFuture,
    ]);

    // 2. Process the fetched data
    final allCampers = (results[0] as Iterable<Camper>).toSet();
    final allBlocks = (results[1] as Iterable<AMABlock>).toSet();
    final allDependents = (results[2] as Iterable<ActivityDependent>).toSet();
    final allPrincipals = results[3] as Map<String, PrincipalActivity>;

    // 3. Filter campers based on the input camperIds
    final Map<CamperId, Camper> filteredCampers = {
      for (var c in allCampers)
        if (camperIds.contains(c.id)) c.id: c
    };

    Debug.logSuccess('Data fetched and processed.', verbosity: Verbosity.verbose);
    return _AssignmentData(
      campers: filteredCampers,
      blocks: allBlocks.toList(),
      dependents: {for (var dep in allDependents) dep.id: dep},
      principals: allPrincipals,
    );
  }

  /// Runs the full camper assignment algorithm for all registered campers.
  Future<void> runAssignmentAlgorithm({
    required Commit commit,
    required double assignedActivityWeight,
    required double weightRecoveryRate,
    required bool preventReassignmentIfAssigned,
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
      assignedActivityWeight: assignedActivityWeight,
      weightRecoveryRate: weightRecoveryRate,
      preventReassignmentIfAssigned: preventReassignmentIfAssigned,
    );
    Debug.logSuccess('Full assignment algorithm complete.', verbosity: Verbosity.verbose);
  }

  /// Runs the assignment algorithm for a specific set of campers across all AMA blocks.
  ///
  /// This method uses preference weights, penalties, and friction.
  Future<void> runAssignmentForCampers({
    required Commit commit,
    required Set<CamperId> camperIds,
    required double assignedActivityWeight,
    required double weightRecoveryRate,
    required bool preventReassignmentIfAssigned,
  }) async {
    Debug.logInfo('Running targeted assignment for ${camperIds.length} campers...', verbosity: Verbosity.verbose);
    // 1. Fetch all necessary data using the new bulk method.
    final assignmentData = await _gatherDataForAssignment(commit, camperIds);

    // Ensure blocks are processed in chronological order.
    assignmentData.blocks.sort((a, b) => a.start.compareTo(b.start));

    if (assignmentData.campers.isEmpty || assignmentData.blocks.isEmpty) {
      Debug.logWarning('Assignment algorithm skipped: No campers or AMA blocks to process.', verbosity: Verbosity.verbose);
      return;
    }

    // 2. Prepare data structures for the specified campers.
    Debug.logInfo('Preparing data structures for assignment...', verbosity: Verbosity.verbose);
    final List<CamperId> shuffledCamperIds = _createShuffledCamperList(assignmentData.campers.values.toList());
    final Map<CamperId, Map<PrincipalActivityId, double>> workingPreferences = {
      for (var camper in assignmentData.campers.values)
        camper.id: Map<PrincipalActivityId, double>.from(camper.preferenceWeightRefs),
    };
    Debug.logSuccess('Data structures prepared.', verbosity: Verbosity.verbose);

    // 3. The core loop: iterate through blocks and assign the specified campers.
    Debug.logInfo('Starting camper assignment loop...', verbosity: Verbosity.verbose);
    await _assignCampersToBlocks(
      commit,
      assignmentData.campers,
      assignmentData.blocks,
      shuffledCamperIds,
      workingPreferences,
      assignmentData.dependents,
      assignmentData.principals,
      assignedActivityWeight,
      weightRecoveryRate,
      preventReassignmentIfAssigned,
    );
    Debug.logSuccess('Camper assignment loop complete.', verbosity: Verbosity.verbose);

    // 4. Persist the final calculated preference weights for the assigned campers.
    Debug.logInfo('Persisting final preference weights...', verbosity: Verbosity.verbose);
    for (var camperId in workingPreferences.keys) {
      final camper = assignmentData.campers[camperId]!;
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
  Future<bool> assignCamperInBlock(
      {required Commit commit,
    required CamperId camperId,
    required AMABlockId amaId,
      required bool preventReassignmentIfAssigned}) async {
    Debug.logInfo('Assigning single camper $camperId in block $amaId...', verbosity: Verbosity.verbose);
    // 1. Fetch the necessary data.
    final Camper? camper =
        commit.getObject(camperId) ?? (await rosterService.registeredCampers).firstWhereOrNull((c) => c.id == camperId);
    final AMABlock? block = commit.getObject(amaId) ?? (await scheduleService.amas).firstWhereOrNull((b) => b.id == amaId);

    if (camper == null || block == null) {
      Debug.logWarning('Could not run single assignment: Camper or AMABlock not found.', verbosity: Verbosity.verbose);
      return false;
    }

    final Set<ActivityDependent> dependentsInCommit = commit.getObjectsOfType<ActivityDependent>();
    final allDependentsSet =
        (dependentsInCommit.isNotEmpty ? dependentsInCommit : await scheduleService.activityDependents).toSet();

    final Map<ActivityDependentId, ActivityDependent> allDependents = {for (var dep in allDependentsSet) dep.id: dep};

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
    final result =
        await _assignBestActivityForCamper(commit, camper, activitiesInBlock, allPrincipals, preventReassignmentIfAssigned);
    if (result) {
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

  void _recoverWeights(Map<PrincipalActivityId, double> workingPreferences, double weightRecoveryRate) {
    workingPreferences.forEach((key, value) {
      if (value < 1.0) {
        // Add the recovery rate, ensuring it doesn't exceed 1.0
        workingPreferences[key] = min(1.0, value + weightRecoveryRate);
      }
    });
  }

  Future<void> _assignCampersToBlocks(
    Commit commit,
    Map<CamperId, Camper> camperMap,
    List<AMABlock> scheduleBlocks,
    List<CamperId> shuffledCamperIds,
    Map<CamperId, Map<PrincipalActivityId, double>> workingPreferences,
    Map<ActivityDependentId, ActivityDependent> allDependents,
    Map<PrincipalActivityId, PrincipalActivity> allPrincipals,
    double assignedActivityWeight,
    double weightRecoveryRate,
    bool preventReassignmentIfAssigned,
  ) async {
    bool forward = true;
    for (final block in scheduleBlocks) {
      Debug.logInfo(
        'Assigning campers for block ${block.id}. Direction: ${forward ? "forward" : "backward"}',
        verbosity: Verbosity.verbose,
      );

      // At the start of each new block, apply the weight recovery for all campers.
      for (final camperId in shuffledCamperIds) {
        _recoverWeights(workingPreferences[camperId]!, weightRecoveryRate);
      }

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
          preventReassignmentIfAssigned,
          // Pass the weight-related parameters for the full algorithm
          camperWorkingPrefs: workingPreferences[camperId]!,
          assignedActivityWeight: assignedActivityWeight,
        );
        if (assigned) {
          // Refresh camper object from commit to ensure we have the latest state.
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
    Map<PrincipalActivityId, PrincipalActivity> allPrincipals,
    bool preventReassignmentIfAssigned, {
    Map<PrincipalActivityId, double>? camperWorkingPrefs,
    double? assignedActivityWeight,
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
      assignedActivityWeight: assignedActivityWeight,
      preventReassignmentIfAssigned: preventReassignmentIfAssigned,
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
    required bool preventReassignmentIfAssigned,
    Map<PrincipalActivityId, double>? camperWorkingPrefs,
    double? assignedActivityWeight,
  }) async {
    for (final activityDep in sortedActivities) {
      final principalAct = allPrincipals[activityDep.principalPar];
      if (principalAct == null) {
        Debug.logWarning('Principal activity not found for dependent ${activityDep.id}, skipping.', verbosity: Verbosity.verbose);
        continue;
      }

      final ActivityDependent activityInCommit = commit.getObject(activityDep.id) ?? activityDep;

      if (activityInCommit.camperRefs.length < principalAct.capacity) {
        final bool success = await rosterService.assignCamperToActivity(
          commit,
          camper.id,
          activityDep.id,
          preventReassignmentIfAssigned,
        );
        if (success) {
          Debug.logSuccess('Assigned camper ${camper.id} to activity ${activityDep.id}', verbosity: Verbosity.verbose);
          if (camperWorkingPrefs != null && assignedActivityWeight != null) {
            _updateWorkingPreferences(camperWorkingPrefs, activityDep.principalPar, assignedActivityWeight);
          }
          return true;
        } else {
          Debug.logWarning(
            'Failed to assign camper ${camper.id} to activity ${activityDep.id} via rosterService.',
            verbosity: Verbosity.verbose,
          );
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
    double assignedActivityWeight,
  ) {
    // SET the weight for the assigned activity directly to the specified value.
    workingPreferences[assignedActivityId] = assignedActivityWeight;
  }
}
