import 'package:intl/intl.dart';

import 'assignment_helpers.dart';
import 'data_models/assignment_context .dart';
import 'data_models/assignment_result.dart';
import 'data_models/potential_assignment.dart';
import 'interfaces.dart';

/// A constraint that checks if an activity has exceeded its capacity.
class CapacityConstraint implements Constraint {
  @override
  String get violationMessage => 'Activity is at full capacity.';

  @override
  bool isViolated(PotentialAssignment assignment, AssignmentContext context, AssignmentResult result) {

    // The capacity of THIS specific instance.
    final capacity = assignment.activity.capacity;

    // Count how many campers are already assigned to this SPECIFIC dependent instance.
    // The result.successfulAssignments list includes both pre-existing and newly-made assignments.
    final currentEnrollment = result.successfulAssignments
        .where((a) => a.dependent.id == assignment.dependent.id)
        .length;

    return currentEnrollment >= capacity;
  }
}

/// A constraint that checks if a camper has been assigned to an activity
/// more times than its reassignment cap allows within the week.
class ReassignmentConstraint implements Constraint {
  @override
  String get violationMessage => 'Camper has reached the maximum number of reassignments for this activity.';

  @override
  bool isViolated(PotentialAssignment assignment, AssignmentContext context, AssignmentResult result) {
    final camperId = assignment.camper.id;
    final activityId = assignment.activity.id;
    final maxAssignments = assignment.activity.maxAssignments;

    // A null maxAssignments means infinite reassignments are allowed.
    if (maxAssignments == null) {
      return false;
    }

    // Count existing assignments from before this run
    final existingCount =
        context.existingDependents.values
            .where((dep) => context.allActivities[dep.principalPar]?.id == activityId && dep.camperRefs.contains(camperId))
            .length;

    // Count new assignments from this run
    final newCount = result.getAssignmentsForCamper(camperId).where((a) => a.activity.id == activityId).length;

    return (existingCount + newCount) >= maxAssignments;
  }
}

/// A constraint to handle the "double schedule" rule.
/// If an activity is marked for double scheduling, this constraint ensures that
/// a camper can only be assigned to the first block if they can ALSO be
/// assigned to the same activity in the immediately following block.
class DoubleScheduleConstraint implements Constraint {
  @override
  String get violationMessage => 'Cannot start a double-schedule activity at the end of the day or across different days.';

  @override
  bool isViolated(PotentialAssignment assignment, AssignmentContext context, AssignmentResult result) {
    // If the activity isn't a double schedule, this constraint doesn't apply.
    if (!assignment.activity.doubleSchedule) {
      return false;
    }

    // Find the next chronological block.
    final nextBlock = context.getNextBlock(assignment.block.id);

    // If there is no next block, it's a violation.
    if (nextBlock == null) {
      return true;
    }

    // Additionally, ensure the next block is on the same day.
    // We can reuse our helper for this.
    final formatter = DateFormat('yyyy-MM-dd');
    if (formatter.format(assignment.block.start) != formatter.format(nextBlock.start)) {
      return true; // Violation: The next block is on a different day.
    }

    // --- NEW AND IMPORTANT FIX ---
    // Check if a dependent for the same activity actually exists in the next block.
    // If not, this assignment is impossible to fulfill as a double schedule.
    final linkedDependent = context.getDependentInBlock(assignment.activity.id, nextBlock.id);
    if (linkedDependent == null) {
      // Violation: The second half of this activity isn't scheduled.
      return true;
    }
    // --- END OF FIX ---

    // No violation found. The core algorithm will handle capacity checks for the linked assignment.
    return false;
  }
}

/// A constraint that prevents a camper from being assigned to the same
/// activity in a chronologically adjacent block on the same day,
/// unless the activity is marked as `doubleSchedule`.
class AdjacentRepetitionConstraint implements Constraint {
  // --- MODIFICATION START ---
  final AssignmentHelpers helpers;

  /// Creates a new AdjacentRepetitionConstraint.
  /// An [AssignmentHelpers] instance can be injected for testability.
  AdjacentRepetitionConstraint({this.helpers = const DefaultAssignmentHelpers()});
  // --- MODIFICATION END ---

  @override
  String get violationMessage => 'Camper is already assigned to this activity in an adjacent block.';

  @override
  bool isViolated(PotentialAssignment assignment, AssignmentContext context, AssignmentResult result) {
    // This rule does not apply to double schedule activities, as they REQUIRE adjacent assignment.
    if (assignment.activity.doubleSchedule) {
      return false;
    }

    final camperId = assignment.camper.id;
    final activityId = assignment.activity.id;

    // Check against assignments from this run
    for (final successfulAssignment in result.getAssignmentsForCamper(camperId)) {
      if (successfulAssignment.activity.id == activityId &&
          // --- MODIFICATION: Use the injected helper instance ---
          helpers.areBlocksAdjacentOnSameDay(
            assignment.block,
            successfulAssignment.block,
            context.weeklyBlocksSorted,
          )) {
        return true;
      }
    }

    // Check against assignments that already existed before this run
    for (final existingAssignment in context.getAssignmentsForCamper(camperId)) {
      if (existingAssignment.activity.id == activityId &&
          // --- MODIFICATION: Use the injected helper instance ---
          helpers.areBlocksAdjacentOnSameDay(assignment.block, existingAssignment.block, context.weeklyBlocksSorted)) {
        return true;
      }
    }

    return false;
  }
}
