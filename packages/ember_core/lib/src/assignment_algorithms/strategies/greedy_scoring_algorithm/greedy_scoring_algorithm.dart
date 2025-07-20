import 'package:ember_core/src/assignment_algorithms/strategies/greedy_scoring_algorithm/steps/generate_potential_assignments_step.dart';
import 'package:ember_core/src/assignment_algorithms/strategies/greedy_scoring_algorithm/steps/process_assignments_step.dart';
import 'package:ember_core/src/assignment_algorithms/strategies/greedy_scoring_algorithm/steps/score_assignments_step.dart';
import 'package:ember_core/src/assignment_algorithms/strategies/greedy_scoring_algorithm/steps/sort_assignments_step.dart';

import '../../data_models/interfaces/algorithm_step.dart';
import '../../data_models/interfaces/assignment_algorithm.dart';
import 'constraints.dart';

class GreedyScoringAlgorithm implements AssignmentAlgorithm {
  @override
  List<AlgorithmStep> get steps => [
    GeneratePotentialAssignmentsStep(),
    ScoreAssignmentsStep(),
    SortAssignmentsStep(),
    ProcessAssignmentsStep(constraints: [CapacityConstraint(), ReassignmentConstraint(), AdjacentRepetitionConstraint(), DoubleScheduleConstraint()]),
  ];
}
