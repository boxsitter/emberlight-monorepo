import 'potential_assignment.dart';

/// Represents the final output of the assignment algorithm.
class AssignmentResult {
  /// A list of all the successful assignments made.
  final List<PotentialAssignment> successfulAssignments = [];

  /// A map of campers who could not be assigned, along with the reason.
  /// MODIFICATION: The key is now "camperId-blockId" to uniquely identify a stalemate.
  final Map<String, String> stalemates = {}; // Key: "camperId-blockId", Value: reason

  /// A list of all assignments that existed *before* this algorithm run.
  /// This is populated at the start to provide a complete view of the schedule.
  final List<PotentialAssignment> existingAssignments = [];


  /// Adds a successful assignment to the results.
  void addSuccess(PotentialAssignment assignment) {
    successfulAssignments.add(assignment);
  }

  /// Records a stalemate for a camper in a specific block.
  void addStalemate(String camperId, String blockId, String reason) {
    // MODIFICATION: The key now includes the blockId to prevent overwrites.
    final key = '$camperId-$blockId';
    stalemates[key] = reason;
  }

  /// Helper to get all assignments in a specific block.
  Iterable<PotentialAssignment> getAssignmentsForBlock(String blockId) {
    return successfulAssignments.where((a) => a.block.id == blockId);
  }

  /// Helper to get all assignments for a specific camper.
  Iterable<PotentialAssignment> getAssignmentsForCamper(String camperId) {
    return successfulAssignments.where((a) => a.camper.id == camperId);
  }
}