/// Defines tunable constants that control the behavior of the Diplomatic Algorithm.
class DiplomaticAlgorithmConsts {
  // --- Promise-Based Scoring ---
  /// The score awarded for fulfilling a participant's explicit request.
  static const double promiseRequestBonus = 100.0;

  /// The neutral score for a flexible choice (neither requested nor vetoed).
  static const double flexibleChoiceScore = 10.0;

  /// A penalty so severe it effectively blocks an assignment for a vetoed activity.
  static const double hardVetoPenalty = -1000.0;

  // --- Age-Based Weighting for Requests ---
  /// The maximum bonus a younger participant receives *for a requested activity*.
  static const double youngerParticipantMaxBonus = 20.0;

  /// The age at which participants start receiving the age bonus for requests.
  static const int youngerParticipantMinAge = 8;

  /// The age at which the age bonus for requests becomes zero.
  static const int youngerParticipantMaxAge = 13;

  // --- Repetition Penalties ---
  /// The base penalty for being assigned to the same activity more than once on the same day.
  /// This penalty decays with distance.
  static const double baseRepetitionPenalty = -50.0;

  /// A factor (0.0 to 1.0) by which the repetition penalty is reduced for each
  /// block separating two assignments.
  static const double repetitionPenaltyDecayFactor = 0.6;
}