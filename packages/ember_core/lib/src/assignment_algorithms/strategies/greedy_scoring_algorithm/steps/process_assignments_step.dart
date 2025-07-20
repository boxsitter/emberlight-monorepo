import '../../../data_models/assignment_result.dart';
import '../../../data_models/interfaces/Constraint.dart';
import '../../../data_models/interfaces/algorithm_step.dart';
import '../../../data_models/potential_assignment.dart';
import '../../../evaluation/step_report.dart';
import '../../../data_models/pipeline_state.dart';

/// The final step, updated to correctly handle merged double-assignments.
///
/// This step iterates through the sorted list. When it encounters a successful
/// assignment, it checks if it's a double. If so, it confirms both halves
/// and blocks both periods simultaneously.
class ProcessAssignmentsStep extends AlgorithmStep {
  final List<Constraint> constraints;

  ProcessAssignmentsStep({required this.constraints});

  @override
  String get stepName => 'Process & Finalize Assignments';

  @override
  StepReport execute(PipelineState state) {
    final assignedInPeriod = _getInitialAssignments(state.result);
    int newSuccessCount = 0;

    for (final assignment in state.potentialAssignments) {
      final participantId = assignment.participant.id;

      // --- Check Primary Period ---
      if (assignedInPeriod[assignment.period.id]?.contains(participantId) ?? false) {
        continue;
      }

      // --- Handle Double Assignments ---
      if (assignment.isDoubleAssignment) {
        final linkedPeriodId = assignment.linkedPeriod!.id;

        // Check if the participant is already busy during the second period.
        if (assignedInPeriod[linkedPeriodId]?.contains(participantId) ?? false) {
          continue;
        }

        // Both halves of the assignment must be valid.
        final primaryViolation = _getViolationReason(assignment, state);
        if (primaryViolation != null) continue;

        // Create a temporary assignment for the second half to check its constraints.
        final linkedAssignment = PotentialAssignment(
          participant: assignment.participant,
          activity: assignment.activity,
          scheduledActivity: assignment.linkedScheduledActivity!,
          period: assignment.linkedPeriod!,
        );
        final linkedViolation = _getViolationReason(linkedAssignment, state);
        if (linkedViolation != null) continue;

        // SUCCESS: Both halves are valid. Add both to the results.
        state.result.addSuccess(assignment); // The primary half
        state.result.addSuccess(linkedAssignment); // The secondary half
        newSuccessCount += 2;

        (assignedInPeriod[assignment.period.id] ??= {}).add(participantId);
        (assignedInPeriod[linkedPeriodId] ??= {}).add(participantId);
      } else {
        // --- Handle Single Assignments ---
        if (_getViolationReason(assignment, state) != null) {
          continue;
        }

        // SUCCESS: The single assignment is valid.
        state.result.addSuccess(assignment);
        newSuccessCount++;
        (assignedInPeriod[assignment.period.id] ??= {}).add(participantId);
      }
    }

    _recordStalemates(state, assignedInPeriod);

    return StepReport(
      stepName: stepName,
      summary: 'Created $newSuccessCount new assignments. Found ${state.result.stalemates.length} stalemates.',
      details: {'newlyAssignedCount': newSuccessCount, 'stalemateCount': state.result.stalemates.length},
      duration: Duration.zero,
    );
  }

  String? _getViolationReason(PotentialAssignment assignment, PipelineState state) {
    for (final constraint in constraints) {
      // We no longer need a separate DoubleScheduleConstraint, as that logic
      // is now handled during the generation step.
      if (constraint.runtimeType.toString() == 'DoubleScheduleConstraint') continue;

      if (constraint.isViolated(assignment, state.context, state.result)) {
        return constraint.violationMessage;
      }
    }
    return null;
  }

  /// Helper to build the initial map of assigned participants from existing results.
  Map<String, Set<String>> _getInitialAssignments(AssignmentResult result) {
    final map = <String, Set<String>>{};
    for (final success in result.successfulAssignments) {
      (map[success.period.id] ??= {}).add(success.participant.id);
    }
    return map;
  }

  void _recordStalemates(PipelineState state, Map<String, Set<String>> assignedInPeriod) {
    for (final participant in state.context.participants.values) {
      for (final period in state.context.targetPeriods.values) {
        if (!(assignedInPeriod[period.id]?.contains(participant.id) ?? false)) {
          state.result.addStalemate(participant.id, period.id, 'No valid assignment found.');
        }
      }
    }
  }
}
