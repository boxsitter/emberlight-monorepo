import 'package:collection/collection.dart';
import 'package:ember_core/src/assignment_algo/data_models/potential_assignment.dart';
import 'package:get/get.dart';

import '../../ember_core.dart';
import '../assignment_algo/assignment_helpers.dart';
import '../assignment_algo/constraints.dart';
import '../assignment_algo/data_models/assignment_context .dart';
import '../assignment_algo/data_models/assignment_result.dart';
import '../assignment_algo/evaluation/satisfaction_calculator.dart';
import '../assignment_algo/interfaces.dart';
import '../assignment_algo/strategies/default_assignment_algorithm.dart';
import '../assignment_algo/strategies/tiered_scoring_strategy.dart';

class AssignmentService extends GetxService {
  // --- DEPENDENCIES ---
  // Services needed to fetch data from your backend.
  final ScheduleService scheduleService = Get.find<ScheduleService>();
  final RosterService rosterService = Get.find<RosterService>();
  final PullRepository pullRepo = Get.find<PullRepository>();
  final CommitRepository commitRepo = Get.find<CommitRepository>();

  /// Runs the assignment algorithm for a given set of campers and time blocks.
  Future<void> runAlgorithm(Commit commit, Set<CamperId> camperIds, Set<AMABlockId> blockIds, bool continueOnStalemate) async {
    // --- 1. CONFIGURE ALGORITHM ---
    // This setup remains the same, defining the modular components for the run.
    final helpers = DefaultAssignmentHelpers();
    final scoringStrategy = TieredScoringStrategy(helpers: helpers);
    final constraints = <Constraint>[
      CapacityConstraint(),
      ReassignmentConstraint(),
      DoubleScheduleConstraint(),
      AdjacentRepetitionConstraint(helpers: helpers),
    ];
    final algorithm = DefaultAssignmentAlgorithm(
      scoringStrategy: scoringStrategy,
      constraints: constraints,
      continueOnStalemate: continueOnStalemate,
    );

    // --- 2. FETCH DATA ---
    // Fetch all data concurrently for efficiency.
    final results = await Future.wait([
      pullRepo.getObjects<Camper>(camperIds),
      scheduleService.getScheduleBlocks(),
      scheduleService.principalActivities,
      scheduleService.activityDependents,
    ]);

    // --- 3. PREPARE CONTEXT ---
    // Refined data processing for clarity and efficiency.
    final fetchedCampers = results[0] as Set<Camper>;
    final allScheduleBlocks = results[1] as Map<String, ScheduleBlock>;
    final allActivities = results[2] as Map<String, PrincipalActivity>;
    final fetchedDependents = results[3] as Set<ActivityDependent>;

    final campers = {for (var c in fetchedCampers) c.id: c};
    final camperPreferences = {
      for (var c in fetchedCampers) c.id: Map<String, double>.from(c.preferenceRefs)
        ..removeWhere((key, value) => value == null)
    };
    final allAmaBlocks = Map.fromEntries(allScheduleBlocks.entries.where((entry) => entry.value is AMABlock)).cast<
        String,
        AMABlock>();
    final weeklyBlocksSorted = allAmaBlocks.values.toList()
      ..sort((a, b) => a.start.compareTo(b.start));

    final context = AssignmentContext(
      campers: campers,
      camperPreferences: camperPreferences,
      targetBlocks: {for (var id in blockIds) id: allAmaBlocks[id]!},
      allActivities: allActivities,
      existingDependents: {for (var dep in fetchedDependents) dep.id: dep},
      weeklyBlocksSorted: weeklyBlocksSorted,
    );

    // --- 4. RUN ALGORITHM ---
    final AssignmentResult result = algorithm.run(context);

    // --- 5. PROCESS & COMMIT RESULTS ---
    // Filter out assignments that already existed before this run.
    final newAssignments = result.successfulAssignments.where((a) => !context.isCamperAssignedInBlock(a.camper.id, a.block.id));

    // Log results for debugging and transparency.
    if (newAssignments.isEmpty) {
      print('No new assignments were made.');
    } else {
      print('  ${newAssignments.length} new assignments were made.');
    }

    if (result.stalemates.isNotEmpty) {
      print('  WARNING: ${result.stalemates.length} stalemates occurred.');
      result.stalemates.forEach((key, reason) {
        final ids = key.split('-');
        print('    - Camper ${ids[0]}: $reason');
      });
    }

    // *** NEW: CALCULATE AND SET CAMPER SATISFACTION ***
    final satisfactionCalculator = SatisfactionCalculator();
    for (final camper in context.campers.values) {
      // Calculate the satisfaction score using the results of the algorithm run.
      final satisfactionScore = satisfactionCalculator.calculate(
        camperId: camper.id,
        context: context,
        result: result,
      );

      // Set the new score on the camper object.
      camper.activitySatisfactionIndex = satisfactionScore; //

      // Add the updated camper to the commit to ensure the change is saved.
      commit.addObjectToPush(camper);
    }

    // Commit the new assignment references to the database.
    for (final PotentialAssignment assignment in newAssignments) {
      rosterService.assignCamperToActivityEfficient(commit, assignment.camper, assignment.dependent, fetchedDependents, true);
    }
  }
}