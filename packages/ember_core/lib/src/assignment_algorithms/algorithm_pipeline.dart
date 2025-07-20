import 'data_models/assignment_context.dart';
import 'data_models/assignment_result.dart';
import 'data_models/interfaces/Constraint.dart';
import 'data_models/interfaces/algorithm_step.dart';
import 'evaluation/step_report.dart';
import 'data_models/interfaces/constraint.dart';
import 'data_models/pipeline_state.dart';

/// An orchestrator that executes a series of [AlgorithmStep]s in sequence.
///
/// It manages the [PipelineState], runs each step, times its execution,
/// and collects the resulting [StepReport] into the final [AssignmentResult].
class AlgorithmPipeline {
  final List<AlgorithmStep> steps;

  AlgorithmPipeline(this.steps);

  AssignmentResult run(AssignmentContext context) {
    final result = _initializeResult(context);
    final state = PipelineState(context: context, result: result);
    final stopwatch = Stopwatch();

    for (final step in steps) {
      stopwatch.reset();
      stopwatch.start();

      // The step generates its report content (with a dummy duration).
      final stepGeneratedReport = step.execute(state);

      stopwatch.stop();

      // A new, final report is created with the actual measured duration.
      final finalReport = StepReport(
        stepName: stepGeneratedReport.stepName,
        summary: stepGeneratedReport.summary,
        details: stepGeneratedReport.details,
        duration: stopwatch.elapsed, // Use the real duration here.
      );

      result.addReport(finalReport);
    }

    return result;
  }

  /// Initializes the result object, pre-populating it with existing assignments.
  AssignmentResult _initializeResult(AssignmentContext context) {
    final result = AssignmentResult();
    for (final participantId in context.existingAssignments.keys) {
      final assignments = context.getAssignmentsForParticipant(participantId);
      result.existingAssignments.addAll(assignments);
      result.successfulAssignments.addAll(assignments);
    }
    return result;
  }
}