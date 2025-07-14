import '../../../ember_core.dart';

/// A data class representing a single potential assignment of a camper
/// to an activity within a specific block.
class PotentialAssignment {
  final Camper camper;
  final ActivityDependent dependent;

  // We also keep references to the principal and block for easier access
  // in constraints and scoring, avoiding repeated lookups.
  final PrincipalActivity activity;
  final AMABlock block;

  PotentialAssignment({
    required this.camper,
    required this.dependent,
    required this.activity,
    required this.block,
  });
}