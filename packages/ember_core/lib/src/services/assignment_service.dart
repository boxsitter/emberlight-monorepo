import 'package:ember_core/src/assignment_algorithms/strategies/greedy_scoring_algorithm/greedy_scoring_algorithm.dart';
import 'package:get/get.dart';

import '../../ember_core.dart';
import '../assignment_algorithms/data_models/analogs/algo_period.dart';
import '../assignment_algorithms/data_models/analogs/algo_scheduled_activity.dart';
import '../assignment_algorithms/data_models/assignment_result.dart';
import '../assignment_algorithms/data_models/analogs/algo_activity.dart';
import '../assignment_algorithms/data_models/analogs/algo_participant.dart';
import '../assignment_algorithms/data_models/assignment_context.dart';
import '../assignment_algorithms/algorithm_pipeline.dart';
import '../assignment_algorithms/evaluation/satisfaction_calculator.dart';

class AssignmentService extends GetxService {
  // --- DEPENDENCIES ---
  // Services needed to fetch data from your backend.
  final ScheduleService scheduleService = Get.find<ScheduleService>();
  final RosterService rosterService = Get.find<RosterService>();
  final PullRepository pullRepo = Get.find<PullRepository>();

  /// Runs the assignment algorithm for a given set of campers and time blocks.
  Future<void> runAlgorithm(Commit commit, Set<CamperId> camperIds, Set<AMABlockId> blockIds) async {
    // 1. CONFIGURE ALGORITHM
    // The pipeline is now composed of the modular steps.
    final AlgorithmPipeline pipeline = AlgorithmPipeline(GreedyScoringAlgorithm().steps);

    // 2. FETCH DATA
    // Fetch all raw data concurrently for efficiency.
    final fetchedData = await Future.wait([
      pullRepo.getObjects<Camper>(camperIds),
      scheduleService.getScheduleBlocks(),
      scheduleService.principalActivities,
      scheduleService.activityDependents,
    ]);

    final fetchedCampers = fetchedData[0] as Set<Camper>;
    final allScheduleBlocks = fetchedData[1] as Map<String, ScheduleBlock>;
    final principalActivities = fetchedData[2] as Map<String, PrincipalActivity>;
    final activityDependents = fetchedData[3] as Set<ActivityDependent>;

    final allActivities = Map.fromEntries(
      principalActivities.entries.map(
        (entry) => MapEntry(
          entry.key,
          AlgoActivity(
            id: entry.value.id,
            capacity: entry.value.capacity,
            maxAssignments: entry.value.maxAssignments,
            doubleSchedule: entry.value.doubleSchedule,
          ),
        ),
      ),
    );

    // The context expects a Map<String, AlgoScheduledActivity>.
    final allScheduledActivities = {
      for (var dep in activityDependents)
        dep.id: AlgoScheduledActivity(id: dep.id, activityId: dep.principalPar, periodId: dep.blockRef),
    };

    // CORRECTED: Manually map AMABlock to AlgoPeriod.
    final allAmaBlocks = Map.fromEntries(
      allScheduleBlocks.entries
          .where((e) => e.value is AMABlock)
          .map((entry) => MapEntry(entry.key, AlgoPeriod(id: entry.value.id, start: entry.value.start))),
    );

    final participants = {for (var c in fetchedCampers) c.id: AlgoParticipant(id: c.id, birthdate: c.birthdate)};

    final context = AssignmentContext(
      participants: participants,
      participantPreferences: {
        for (var c in fetchedCampers)
          c.id: Map<String, double>.from(c.preferenceRefs),
      },
      targetPeriods: {for (var id in blockIds) id: allAmaBlocks[id]!},
      allActivities: allActivities,
      allScheduledActivities: allScheduledActivities,
      existingAssignments: {for (var c in fetchedCampers) c.id: c.activityAssignmentRefs.keys.toList()},
      weeklyPeriodsSorted: allAmaBlocks.values.toList()..sort((a, b) => a.start.toUtc().compareTo(b.start.toUtc())),
    );

    // 4. RUN ALGORITHM
    // CORRECTED: The pipeline's 'run' method returns an AssignmentResult.
    final AssignmentResult result = pipeline.run(context);

    // 5. PROCESS & COMMIT RESULTS (Restored Logic)
    final satisfactionCalculator = SatisfactionCalculator();
    for (final camperId in context.participants.keys) {
      final score = satisfactionCalculator.calculate(participantId: camperId, context: context, result: result);
      final camper = await pullRepo.getObject<Camper>(camperId);
      if (score != null) {
        camper.activitySatisfactionIndex = score;
        commit.addObjectToPush(camper);
      }
    }
  }
}
