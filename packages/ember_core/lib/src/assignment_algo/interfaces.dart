import 'data_models/assignment_context .dart';
import 'data_models/assignment_result.dart';
import 'data_models/potential_assignment.dart';

/// Defines the contract for a scoring strategy.
/// Its role is to calculate a numerical score for a potential assignment,
/// representing its desirability.
abstract class ScoringStrategy {
  /// Calculates the score for a single potential assignment.
  // MODIFICATION: The result of the current run is now passed in
  // so the score can be dynamically adjusted as assignments are made.
  double score(PotentialAssignment assignment, AssignmentContext context, AssignmentResult result);
}

/// Defines the contract for a constraint that an assignment must satisfy.
abstract class Constraint {
  /// Returns true if the proposed assignment violates this constraint.
  /// It checks against both the initial state (context) and the live
  /// results of the current algorithm run (result).
  bool isViolated(PotentialAssignment assignment, AssignmentContext context, AssignmentResult result);

  /// A message describing why the constraint was violated.
  String get violationMessage;
}

abstract class AssignmentAlgorithm {
  /// Runs the assignment process using the provided data context.
  void run(AssignmentContext context);
}
