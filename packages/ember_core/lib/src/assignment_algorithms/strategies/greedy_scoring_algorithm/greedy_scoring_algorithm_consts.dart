class GreedyScoringAlgorithmConsts {
  // --- Preference Tiers ---
  /// The score for a participant's most desired activities ("Golden Ticket").
  static const double goldenTicketBonus = 100.0;

  /// The score for activities a participant is highly interested in.
  static const double highInterestBonus = 50.0;

  /// The score for activities a participant is neutral or curious about.
  static const double flexibleChoiceBonus = 10.0;

  /// The penalty for activities a participant has low interest in.
  static const double lowInterestPenalty = -20.0;

  /// A penalty so severe it effectively blocks an assignment.
  static const double hardNoPenalty = -1000.0;

  // --- Age-Based Weighting (Now with a Curve) ---
  /// The maximum bonus a participant can receive based on their age.
  static const double youngerParticipantMaxBonus = 20.0;

  /// The age at which participants start receiving the age bonus.
  static const int youngerParticipantMinAge = 8;

  /// The age at which the age bonus becomes zero.
  static const int youngerParticipantMaxAge = 13;


  // --- Repetition Penalties ---
  /// The base penalty for being assigned to the same activity more than once on the same day.
  /// This penalty decays with distance.
  static const double baseRepetitionPenalty = -50.0;

  /// A harsh penalty for being assigned to the same activity in an adjacent time block.
  /// This is now primarily for the hard constraint but can be used as a score too.
  static const double adjacentRepetitionPenalty = -100.0;

  /// A factor (0.0 to 1.0) by which the repetition penalty is reduced for each
  /// block separating two assignments.
  /// e.g., 0.5 means the penalty is halved for each intervening block.
  static const double repetitionPenaltyDecayFactor = 0.6;
}