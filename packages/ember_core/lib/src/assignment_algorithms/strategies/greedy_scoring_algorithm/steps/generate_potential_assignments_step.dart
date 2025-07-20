import '../../../../../ember_core.dart';
import '../../../data_models/analogs/algo_activity.dart';
import '../../../data_models/analogs/algo_period.dart';
import '../../../data_models/analogs/algo_scheduled_activity.dart';
import '../../../data_models/interfaces/Constraint.dart';
import '../../../data_models/interfaces/algorithm_step.dart';
import '../../../data_models/potential_assignment.dart';
import '../../../evaluation/step_report.dart';
import '../../../data_models/pipeline_state.dart';

/// The first step in the assignment pipeline, updated to handle double-periods.
///
/// This step generates a list of possible assignments. It now intelligently
/// identifies and links double-period activities, creating a single
/// `PotentialAssignment` to represent the two-period block.
class GeneratePotentialAssignmentsStep extends AlgorithmStep {
  @override
  String get stepName => 'Generate Potential Assignments';

  @override
  StepReport execute(PipelineState state) {
    final List <PotentialAssignment> potentialAssignments = [];
    // Loop 1: Go through every participant in the system.
    // Keep track of periods that have been consumed as the second half
    // of a double-assignment, to avoid creating duplicates.
    final consumedPeriodIds = <String>{};

    for (final participant in state.context.participants.values) {
      for (final period in state.context.targetPeriods.values) {
        // Skip if this participant is already assigned in this period.
        if (state.context.isParticipantAssignedInPeriod(participant.id, period.id)) {
          continue;
        }
        // Skip if this period was already handled as the second part of a double.
        if (consumedPeriodIds.contains(period.id)) {
          continue;
        }

        for (final scheduledActivity in state.context.getScheduledActivitiesInPeriod(period.id)) {
          final activity = state.context.allActivities[scheduledActivity.activityId];
          if (activity == null) continue;

          if (activity.doubleSchedule) {
            // --- Handle Double-Period Activities ---
            final AlgoPeriod? nextPeriod = state.context.getNextPeriod(period.id);

            // Ensure the next period exists and is on the same day.
            if (nextPeriod != null && state.context.isSameDay(period, nextPeriod)) {
              final AlgoScheduledActivity? linkedScheduled = state.context.getScheduledActivityInPeriod(activity.id, nextPeriod.id);

              // If the same activity is scheduled in the next block, create a merged assignment.
              if (linkedScheduled != null) {
                potentialAssignments.add(PotentialAssignment(
                  participant: participant,
                  activity: activity,
                  scheduledActivity: scheduledActivity,
                  period: period,
                  linkedScheduledActivity: linkedScheduled,
                  linkedPeriod: nextPeriod,
                ));
                // Mark the second period as handled so we don't process it again.
                consumedPeriodIds.add(nextPeriod.id);
              }
            }
          } else {
            // --- Handle Single-Period Activities ---
            potentialAssignments.add(PotentialAssignment(
              participant: participant,
              scheduledActivity: scheduledActivity,
              activity: activity,
              period: period,
            ));
          }
        }
      }
    }
    state.potentialAssignments = potentialAssignments;

    return StepReport(
      stepName: stepName,
      summary: 'Generated ${potentialAssignments.length} potential assignments (merged doubles).',
      details: {'count': potentialAssignments.length},
      duration: Duration.zero,
    );
  }
}
