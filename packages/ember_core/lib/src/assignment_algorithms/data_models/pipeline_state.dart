import 'assignment_context.dart';
import 'assignment_result.dart';
import 'potential_assignment.dart';

/// A container for the shared state that is passed through the algorithm pipeline.
///
/// Each [AlgorithmStep] can read from and write to this state, allowing data
/// to be built up and transformed progressively through the run.
class PipelineState {
  final AssignmentContext context;
  final AssignmentResult result;
  List<PotentialAssignment> potentialAssignments;

  PipelineState({
    required this.context,
    required this.result,
    this.potentialAssignments = const [],
  });
}