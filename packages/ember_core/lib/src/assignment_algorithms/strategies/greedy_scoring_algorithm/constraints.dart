import 'package:intl/intl.dart';

import '../../data_models/analogs/algo_period.dart';
import '../../data_models/assignment_context.dart';
import '../../data_models/assignment_result.dart';
import '../../data_models/interfaces/Constraint.dart';
import '../../data_models/potential_assignment.dart';

/// A constraint that checks if an activity has exceeded its capacity.
class CapacityConstraint implements Constraint {
  @override
  String get violationMessage => 'Activity is at full capacity.';

  @override
  bool isViolated(PotentialAssignment assignment, AssignmentContext context, AssignmentResult result) {
    final capacity = assignment.activity.capacity;

    // Count how many participants are already assigned to this specific scheduled activity instance.
    final currentEnrollment = result.successfulAssignments
        .where((a) => a.scheduledActivity.id == assignment.scheduledActivity.id)
        .length;

    return currentEnrollment >= capacity;
  }
}

/// A constraint that checks if a participant has been assigned to an activity
/// more times than its reassignment cap allows within the week.
class ReassignmentConstraint implements Constraint {
  @override
  String get violationMessage =>
      'Participant has reached the maximum number of reassignments for this activity.';

  @override
  bool isViolated(PotentialAssignment assignment, AssignmentContext context, AssignmentResult result) {
    final participantId = assignment.participant.id;
    final activityId = assignment.activity.id;
    final maxAssignments = assignment.activity.maxAssignments;

    if (maxAssignments == null) return false; // Null means infinite

    // Get all assignments for this participant (both existing and new)
    final allParticipantAssignments = [
      ...context.getAssignmentsForParticipant(participantId),
      ...result.getAssignmentsForParticipant(participantId),
    ];

    final count = allParticipantAssignments
        .where((a) => a.activity.id == activityId)
            .length;

    // The potential assignment hasn't been added yet, so we check if the current
    // count is already at the maximum.
    return count >= maxAssignments;
  }
}

/// A constraint to handle the "double schedule" rule.
class DoubleScheduleConstraint implements Constraint {
  @override
  String get violationMessage =>
      'Cannot fulfill double-schedule activity. The subsequent period is unavailable or unscheduled.';

  @override
  bool isViolated(PotentialAssignment assignment, AssignmentContext context, AssignmentResult result) {
    if (!assignment.activity.doubleSchedule) return false;

    final nextPeriod = context.getNextPeriod(assignment.period.id);

    // Violation if there's no next period at all.
    if (nextPeriod == null) return true;

    // Violation if the next period is on a different day.
    final formatter = DateFormat('yyyy-MM-dd');
    if (formatter.format(assignment.period.start) !=
        formatter.format(nextPeriod.start)) {
      return true;
    }

    // Violation if the same activity is not scheduled in the next period.
    final linkedScheduledActivity =
        context.getScheduledActivityInPeriod(assignment.activity.id, nextPeriod.id);
    if (linkedScheduledActivity == null) {
      return true;
    }

    // All checks passed, no violation.
    return false;
  }
}


/// A constraint that prevents a participant from being assigned to the same
/// activity in an adjacent period on the same day, unless it's a double schedule.
class AdjacentRepetitionConstraint implements Constraint {
  @override
  String get violationMessage =>
      'Participant is already assigned to this activity in an adjacent period.';

  @override
  bool isViolated(PotentialAssignment assignment, AssignmentContext context, AssignmentResult result) {
    if (assignment.activity.doubleSchedule) return false;

    final participantId = assignment.participant.id;
    final activityId = assignment.activity.id;

    // Combine existing and new assignments for a full view of the schedule.
    final allAssignments = [
      ...context.getAssignmentsForParticipant(participantId),
      ...result.getAssignmentsForParticipant(participantId)
    ];

    for (final existingAssignment in allAssignments) {
      if (existingAssignment.activity.id == activityId) {
        if (_arePeriodsAdjacentOnSameDay(
          assignment.period,
          existingAssignment.period,
          context.weeklyPeriodsSorted,
          )) {
          return true; // Violation found
      }
    }
    }

    return false;
  }

  bool _arePeriodsAdjacentOnSameDay(AlgoPeriod periodA, AlgoPeriod periodB, List<AlgoPeriod> weeklyPeriodsSorted) {
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final dayA = formatter.format(periodA.start);
    final dayB = formatter.format(periodB.start);

    if (dayA != dayB) return false;

    final indexA = weeklyPeriodsSorted.indexWhere((p) => p.id == periodA.id);
    final indexB = weeklyPeriodsSorted.indexWhere((p) => p.id == periodB.id);

    if (indexA == -1 || indexB == -1) return false;

    return (indexA - indexB).abs() == 1;
  }
}
