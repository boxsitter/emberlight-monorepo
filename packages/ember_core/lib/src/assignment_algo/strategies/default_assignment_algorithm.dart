import 'dart:math';

import '../../../ember_core.dart';
import '../data_models/assignment_context .dart';
import '../data_models/assignment_result.dart';
import '../data_models/potential_assignment.dart';
import '../interfaces.dart';

/// The primary implementation of the assignment algorithm, designed to be
/// configured with various strategies and constraints.
class DefaultAssignmentAlgorithm implements AssignmentAlgorithm {
  final ScoringStrategy scoringStrategy;
  final List<Constraint> constraints;
  final bool continueOnStalemate;

  DefaultAssignmentAlgorithm({required this.scoringStrategy, required this.constraints, this.continueOnStalemate = true});

  @override
  AssignmentResult run(AssignmentContext context) {
    final result = AssignmentResult();
    final allBlocksById = {for (var block in context.weeklyBlocksSorted) block.id: block};

    // --- MODIFICATION 1: Update pre-population loop ---
    // Pre-populate the result with existing assignments, now creating the
    // new PotentialAssignment object correctly.
    for (final dependent in context.existingDependents.values) {
      final activity = context.allActivities[dependent.principalPar];
      final block = allBlocksById[dependent.blockRef];

      if (activity != null && block != null) {
        for (final camperId in dependent.camperRefs) {
          final camper = context.campers[camperId];
          if (camper != null) {
            result.addSuccess(PotentialAssignment(
              camper: camper,
              dependent: dependent, // Pass the dependent itself
              activity: activity,
              block: block,
            ));
          }
        }
      }
    }

    // --- MODIFICATION 2: Replace the entire assignment generation logic ---
    // Generate all possible assignments based on ACTUAL scheduled dependents.
    final potentialAssignments = <PotentialAssignment>[];
    for (final camper in context.campers.values) {
      for (final block in context.targetBlocks.values) {
        // Skip if this camper already has an assignment in this block from a previous run.
        if (context.isCamperAssignedInBlock(camper.id, block.id)) {
          continue;
        }

        // Find all the dependents scheduled for THIS specific block.
        final dependentsInBlock = context.existingDependents.values.where((dep) => dep.blockRef == block.id);

        // For each actual scheduled activity instance...
        for (final dependent in dependentsInBlock) {
          final principalActivity = context.allActivities[dependent.principalPar];

          // Ensure the activity exists and is assignable (not hidden).
          if (principalActivity != null && context.availableActivities.containsKey(principalActivity.id)) {
            // Create a valid PotentialAssignment.
            potentialAssignments.add(PotentialAssignment(
              camper: camper,
              dependent: dependent,
              activity: principalActivity,
              block: block,
            ));
          }
        }
      }
    }

    final random = Random();

    // Score and sort all potential assignments
    potentialAssignments.sort((a, b) {
      final scoreA = scoringStrategy.score(a, context, result);
      final scoreB = scoringStrategy.score(b, context, result);
      final comparison = scoreB.compareTo(scoreA); // Sort descending

      if (comparison == 0) {
        return random.nextBool() ? 1 : -1;
      }

      return comparison;
    });

    final assignedCampersInBlock = <String, Set<String>>{};
    final stalemateReasons = <String, String>{};

    for (final success in result.successfulAssignments) {
      assignedCampersInBlock.putIfAbsent(success.block.id, () => {}).add(success.camper.id);
    }


    for (final assignment in potentialAssignments) {
      final blockId = assignment.block.id;
      final camperId = assignment.camper.id;
      final stalemateKey = '$camperId-$blockId';

      assignedCampersInBlock.putIfAbsent(blockId, () => {});

      if (assignedCampersInBlock[blockId]!.contains(camperId)) continue;

      bool isPrimaryViolated = false;
      String? violationReason;
      for (final constraint in constraints) {
        if (constraint.isViolated(assignment, context, result)) {
          isPrimaryViolated = true;
          violationReason = constraint.violationMessage;
          break;
        }
      }

      if (isPrimaryViolated) {
          stalemateReasons.putIfAbsent(stalemateKey, () => violationReason!);
          continue;
      }

      result.addSuccess(assignment);
      assignedCampersInBlock[blockId]!.add(camperId);
      stalemateReasons.remove(stalemateKey);

      // --- MODIFICATION 3: Update Double Schedule Logic ---
      // This logic now finds the correct dependent in the next block.
        if (assignment.activity.doubleSchedule) {
          final nextBlock = context.getNextBlock(blockId);
        if (nextBlock != null && !(assignedCampersInBlock[nextBlock.id]?.contains(camperId) ?? false)) {
          // Use our new helper to find the corresponding dependent
          final linkedDependent = context.getDependentInBlock(assignment.activity.id, nextBlock.id);

          // If a dependent for the same activity exists in the next block...
          if (linkedDependent != null) {
          final linkedAssignment = PotentialAssignment(
              camper: assignment.camper,
                dependent: linkedDependent,
              activity: assignment.activity,
              block: nextBlock,
            );

          bool isLinkedViolated = false;
            for (final constraint in constraints) {
              if (constraint.isViolated(linkedAssignment, context, result)) {
              isLinkedViolated = true;
                break;
              }
            }

          if (!isLinkedViolated) {
            result.addSuccess(linkedAssignment);
          assignedCampersInBlock.putIfAbsent(linkedAssignment.block.id, () => {}).add(camperId);
        }
        }
      }
    }
    }

    // Handle Stalemates
    for (final camper in context.campers.values) {
      for (final block in context.targetBlocks.values) {
        if (!(assignedCampersInBlock[block.id]?.contains(camper.id) ?? false) &&
            !context.isCamperAssignedInBlock(camper.id, block.id)) {
          final key = '${camper.id}-${block.id}';
          final reason = stalemateReasons[key] ?? 'No available activities met the constraints.';
          result.addStalemate(camper.id, block.id, reason);
        }
      }
    }

    if (!continueOnStalemate && result.stalemates.isNotEmpty) {
      throw Exception('Assignment failed due to stalemates.');
    }

    return result;
  }
}
