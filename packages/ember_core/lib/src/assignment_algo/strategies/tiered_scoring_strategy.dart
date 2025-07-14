import 'dart:math';

import '../../../ember_core.dart';
import '../assignment_constants.dart';
import '../assignment_helpers.dart';
import '../data_models/assignment_context .dart';
import '../data_models/assignment_result.dart';
import '../data_models/potential_assignment.dart';
import '../interfaces.dart';

/// A scoring strategy that uses a tiered system of bonuses and penalties
/// to calculate an assignment's desirability.
class TieredScoringStrategy implements ScoringStrategy {
  final AssignmentHelpers helpers;

  // We provide a default instance for convenience in the main app.
  TieredScoringStrategy({this.helpers = const DefaultAssignmentHelpers()});

  @override
  // MODIFICATION: Added the result object to the signature.
  double score(PotentialAssignment assignment, AssignmentContext context, AssignmentResult result) {
    final Camper camper = assignment.camper;
    final activity = assignment.activity;

    double score = 0.0;

    // 1. Add Preference Bonus
    final preference = context.camperPreferences[camper.id]?[activity.id] ?? 0.5;
    score += _getPreferenceBonus(preference);

    // Use the injected helper instance now!
    score += helpers.calculateAgeBonus(camper.birthdate);

    // 3. Apply Repetition Penalties
    // MODIFICATION: Pass the result object to the penalty calculation.
    score += _getRepetitionPenalty(assignment, context, result);

    return score;
  }

  double _getPreferenceBonus(double preference) {
    if (preference >= 0.9) return AssignmentConstants.goldenTicketBonus;
    if (preference >= 0.7) return AssignmentConstants.highInterestBonus;
    if (preference >= 0.3) return AssignmentConstants.flexibleChoiceBonus;
    if (preference >= 0.1) return AssignmentConstants.lowInterestPenalty;
    return AssignmentConstants.hardNoPenalty;
  }

  double _getRepetitionPenalty(
      PotentialAssignment assignment, AssignmentContext context, AssignmentResult result) {
    double totalPenalty = 0.0;
    final camperId = assignment.camper.id;
    final activityId = assignment.activity.id;

    // MODIFICATION: Combine existing and new assignments for a full view.
    final allCamperAssignments = [
      ...context.getAssignmentsForCamper(camperId),
      ...result.getAssignmentsForCamper(camperId)
    ];

    for (final existingAssignment in allCamperAssignments) {
        if (existingAssignment.activity.id == activityId) {
        // Use the injected helper instance here too!
        final distance = helpers.calculateBlockDistance(
            assignment.block, existingAssignment.block, context.weeklyBlocksSorted);

        if (distance != -1) { // -1 means different days
          // Apply the decay factor. 0 distance = full penalty.
          final decayMultiplier = pow(AssignmentConstants.repetitionPenaltyDecayFactor, distance);
          totalPenalty += (AssignmentConstants.baseRepetitionPenalty * decayMultiplier);
            }
        }
    }
    return totalPenalty;
  }
}