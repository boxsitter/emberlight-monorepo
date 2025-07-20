import 'dart:math';
import 'package:intl/intl.dart';

import '../../../data_models/analogs/algo_period.dart';
import '../../../data_models/assignment_context.dart';
import '../../../data_models/assignment_result.dart';
import '../../../data_models/interfaces/algorithm_step.dart';
import '../../../data_models/potential_assignment.dart';
import '../../../evaluation/step_report.dart';
import '../../../data_models/pipeline_state.dart';
import '../diplomatic_algorithm_consts.dart';

/// Scores assignments based on the Diplomatic Algorithm's rules.
///
/// This step interprets preferences as Request, Veto, or Flexible, and applies
/// scoring logic for promises, age, and repetition.
class ScoreDiplomaticAssignmentsStep extends AlgorithmStep {
  @override
  String get stepName => 'Score Diplomatic Assignments';

  @override
  StepReport execute(PipelineState state) {
    for (final potentialAssignment in state.potentialAssignments) {
      potentialAssignment.score = _calculateScore(potentialAssignment, state.context, state.result);
    }

    return StepReport(
      stepName: stepName,
      summary: 'Calculated scores for ${state.potentialAssignments.length} assignments.',
      details: {'count': state.potentialAssignments.length},
      duration: Duration.zero,
    );
  }

  double _calculateScore(PotentialAssignment assignment, AssignmentContext context, AssignmentResult result) {
    double totalScore = 0.0;

    // Interpret the raw preference value
    final preferenceValue = context.participantPreferences[assignment.participant.id]?[assignment.activity.id];

    // 1. Get score from preference (Request, Veto, or Flexible)
    totalScore += _getPreferenceScore(assignment, preferenceValue, result);

    // 2. Add age bonus, but only for requests
    if ((preferenceValue ?? 0.5) > 0.5) {
      totalScore += _calculateAgeBonus(assignment.participant.birthdate);
    }

    // 3. Subtract points for repeating an activity on the same day
    totalScore += _getRepetitionPenalty(assignment, context, result);

    return totalScore;
  }

  /// Returns a score based on whether the preference is a Request, Veto, or Flexible.
  double _getPreferenceScore(PotentialAssignment assignment, double? preference, AssignmentResult result) {
    // Veto: 0 <= p < 0.5
    if (preference != null && preference < 0.5) {
      return DiplomaticAlgorithmConsts.hardVetoPenalty;
    }

    // Request: 0.5 < p <= 1.0
    if (preference != null && preference > 0.5) {
      // Check if this request has already been fulfilled
      final hasBeenFulfilled = result.getAssignmentsForParticipant(assignment.participant.id)
          .any((a) => a.activity.id == assignment.activity.id);

      return hasBeenFulfilled
          ? DiplomaticAlgorithmConsts.flexibleChoiceScore // Treat as flexible if already fulfilled
          : DiplomaticAlgorithmConsts.promiseRequestBonus;
    }

    // Flexible: p == 0.5 or p == null
    return DiplomaticAlgorithmConsts.flexibleChoiceScore;
  }

  /// Calculates a penalty for assigning the same activity too close together.
  /// This logic is reused from the previous scoring algorithm.
  double _getRepetitionPenalty(PotentialAssignment currentAssignment, AssignmentContext context, AssignmentResult result) {
    // This function can be copied directly from the original `ScoreAssignmentsStep`
    // as its logic for calculating distance-based penalties remains valid.
    double totalPenalty = 0.0;
    final participantId = currentAssignment.participant.id;
    final activityId = currentAssignment.activity.id;

    final allAssignments = [
      ...context.getAssignmentsForParticipant(participantId),
      ...result.getAssignmentsForParticipant(participantId),
    ];

    for (final otherAssignment in allAssignments) {
      if (otherAssignment.activity.id == activityId) {
        final distance = _calculatePeriodDistance(currentAssignment.period, otherAssignment.period, context.weeklyPeriodsSorted);
        if (distance != -1) {
          final decay = pow(DiplomaticAlgorithmConsts.repetitionPenaltyDecayFactor, distance);
          totalPenalty += (DiplomaticAlgorithmConsts.baseRepetitionPenalty * decay);
        }
      }
    }
    return totalPenalty;
  }

  /// Calculates an age-based bonus using a linear sliding scale.
  /// This logic is reused from the previous scoring algorithm.
  double _calculateAgeBonus(DateTime birthdate) {
    // This function can be copied directly from the original `ScoreAssignmentsStep`
    // using the new constants from `DiplomaticAlgorithmConsts`.
    final now = DateTime.now();
    int age = now.year - birthdate.year;
    if (now.month < birthdate.month || (now.month == birthdate.month && now.day < birthdate.day)) {
      age--;
    }

    if (age <= DiplomaticAlgorithmConsts.youngerParticipantMinAge) {
      return DiplomaticAlgorithmConsts.youngerParticipantMaxBonus;
    }
    if (age >= DiplomaticAlgorithmConsts.youngerParticipantMaxAge) {
      return 0.0;
    }

    final ageRange = (DiplomaticAlgorithmConsts.youngerParticipantMaxAge - DiplomaticAlgorithmConsts.youngerParticipantMinAge).toDouble();
    final participantPositionInRange = (age - DiplomaticAlgorithmConsts.youngerParticipantMinAge).toDouble();
    final bonus = DiplomaticAlgorithmConsts.youngerParticipantMaxBonus * (1 - (participantPositionInRange / ageRange));
    return max(0.0, bonus);
  }

  /// Calculates the number of periods between two assignments on the same day.
  /// This logic is reused from the previous scoring algorithm.
  int _calculatePeriodDistance(AlgoPeriod periodA, AlgoPeriod periodB, List<AlgoPeriod> weeklyPeriodsSorted) {
    // This function can be copied directly from the original `ScoreAssignmentsStep`.
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final dayA = formatter.format(periodA.start);
    final dayB = formatter.format(periodB.start);

    if (dayA != dayB) return -1;

    final indexA = weeklyPeriodsSorted.indexWhere((p) => p.id == periodA.id);
    final indexB = weeklyPeriodsSorted.indexWhere((p) => p.id == periodB.id);

    if (indexA == -1 || indexB == -1) return -1;

    return (indexA - indexB).abs() - 1;
  }
}