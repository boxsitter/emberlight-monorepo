import 'package:ember_core/src/assignment_algo/data_models/potential_assignment.dart';

import '../../../ember_core.dart';

/// Holds all the data required for a single run of the assignment algorithm.
/// This object is the single source of truth, ensuring the algorithm does not
/// need to perform additional database fetches after initialization.
class AssignmentContext {
  /// The campers to be assigned for this run.
  final Map<String, Camper> campers;

  /// A map of camper IDs to their activity preferences.
  /// The inner map holds PrincipalActivity IDs and their preference scores (0.0-1.0).
  final Map<String, Map<String, double>> camperPreferences;

  /// The specific AMABlocks to be filled in this run.
  final Map<String, AMABlock> targetBlocks;

  /// All PrincipalActivity documents available in the system.
  final Map<String, PrincipalActivity> allActivities;

  /// A pre-filtered map of activities that are not hidden and can be assigned.
  final Map<String, PrincipalActivity> availableActivities;

  /// All existing ActivityDependent documents for the relevant week.
  /// This provides the state of the schedule before the run. [cite: 5, 6]
  final Map<String, ActivityDependent> existingDependents;

  /// A sorted list of all AMABlocks for the week, used for chronological checks.
  final List<AMABlock> weeklyBlocksSorted;

  AssignmentContext({
    required this.campers,
    required this.camperPreferences,
    required this.targetBlocks,
    required this.allActivities,
    required this.existingDependents,
    required this.weeklyBlocksSorted,
  }) : availableActivities = _filterHiddenActivities(allActivities);

  /// Filters out activities marked as 'isHidden'.
  static Map<String, PrincipalActivity> _filterHiddenActivities(Map<String, PrincipalActivity> activities) {
    var filtered = Map<String, PrincipalActivity>.from(activities);
    filtered.removeWhere((key, activity) => activity.isHidden);
    return filtered;
  }

  /// Checks if a camper already has an assignment in a specific block
  /// based on the initial state of the schedule.
  bool isCamperAssignedInBlock(String camperId, String blockId) {
    return existingDependents.values.any((dependent) => dependent.blockRef == blockId && dependent.camperRefs.contains(camperId));
  }

  /// Retrieves all of a camper's existing assignments for the week.
  /// This has been updated to create the new PotentialAssignment object correctly.
  List<PotentialAssignment> getAssignmentsForCamper(String camperId) {
    final assignments = <PotentialAssignment>[];
    final allBlocksById = {for (var b in weeklyBlocksSorted) b.id: b};

    for (final dependent in existingDependents.values) {
      if (dependent.camperRefs.contains(camperId)) {
        final activity = allActivities[dependent.principalPar];
        final block = allBlocksById[dependent.blockRef];
        final camper = campers[camperId];

        if (activity != null && camper != null && block != null) {
          assignments.add(PotentialAssignment(
            camper: camper,
            dependent: dependent, // Correctly pass the dependent
            activity: activity,
            block: block,
          ));
        }
      }
    }
    return assignments;
  }

  /// Gets the next chronological block in the week.
  AMABlock? getNextBlock(String blockId) {
    final index = weeklyBlocksSorted.indexWhere((b) => b.id == blockId);
    if (index == -1 || index + 1 >= weeklyBlocksSorted.length) {
      return null;
    }
    return weeklyBlocksSorted[index + 1];
  }

  /// Retrieves a specific ActivityDependent for a given PrincipalActivity in a specific block.
  ActivityDependent? getDependentInBlock(String principalActivityId, String blockId) {
    for (final dependent in existingDependents.values) {
      if (dependent.blockRef == blockId && dependent.principalPar == principalActivityId) {
        return dependent;
      }
    }
    return null;
  }
}
