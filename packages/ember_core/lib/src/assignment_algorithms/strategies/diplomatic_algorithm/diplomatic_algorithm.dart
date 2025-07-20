import 'package:ember_core/src/assignment_algorithms/strategies/diplomatic_algorithm/steps/process_promise_step.dart';
import 'package:ember_core/src/assignment_algorithms/strategies/diplomatic_algorithm/steps/score_diplomatic_assignments_step.dart';
import 'package:ember_core/src/assignment_algorithms/strategies/greedy_scoring_algorithm/steps/generate_potential_assignments_step.dart';
import 'package:ember_core/src/assignment_algorithms/strategies/greedy_scoring_algorithm/steps/process_assignments_step.dart';
import 'package:ember_core/src/assignment_algorithms/strategies/greedy_scoring_algorithm/steps/score_assignments_step.dart';
import 'package:ember_core/src/assignment_algorithms/strategies/greedy_scoring_algorithm/steps/sort_assignments_step.dart';

import '../../data_models/interfaces/algorithm_step.dart';
import '../../data_models/interfaces/assignment_algorithm.dart';

class DiplomaticAlgorithm implements AssignmentAlgorithm {
  @override
  List<AlgorithmStep> get steps => [
    GeneratePotentialAssignmentsStep(),
    ScoreDiplomaticAssignmentsStep(),
  ];
}
