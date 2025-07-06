import 'package:ember_cli_utils/ember_cli_utils.dart';
import 'package:ember_core/src/hardcode/hardcoded_principal_activites.dart';
import 'package:ember_core/src/hardcode/hardcoded_principal_cabins.dart';
import 'package:ember_core/src/hardcode/hardcoded_test_schedule.dart';
import 'package:ember_core/src/hardcode/session_a/hardcoded_session_a.dart';
import 'package:ember_core/src/services/database_repair_service.dart';
import 'package:get/get.dart';

import '../../ember_core.dart';
import '../models/core_objects/schedule_day.dart';

class DevCommands {
  static Map<String, EmberCommand> list = {
    'rephc': RepairHardCode(
      userInput: FrontendManager.instance.getUserInputImplementation(),
      userOutput: FrontendManager.instance.getUserOutputImplementation(),
    ),
    'initsesha': InitSessionA(
      userInput: FrontendManager.instance.getUserInputImplementation(),
      userOutput: FrontendManager.instance.getUserOutputImplementation(),
    ),
    'rstact': ResetActivityAssignments(
      userInput: FrontendManager.instance.getUserInputImplementation(),
      userOutput: FrontendManager.instance.getUserOutputImplementation(),
    ),
  };
}

class RepairHardCode extends EmberCommand {
  final UserService userService = Get.find<UserService>();
  final ClientContext clientContext = Get.find<ClientContext>();
  final CommitRepository commitRepo = Get.find<CommitRepository>();

  @override
  final String name = 'rephc';
  @override
  final String description = 'Initializes / repairs hardcoded objects';
  @override
  String get invocationDetails => 'rephc';
  @override
  List<String> get examples => ['rephc'];

  RepairHardCode({required super.userInput, required super.userOutput});

  @override
  Future<dynamic> run() async {
    final List<FormFieldDescriptor> formFieldDescriptors = [
      BooleanFormFieldDescriptor(label: 'Repair principal activities?'),
      BooleanFormFieldDescriptor(label: 'Repair principal cabins?'),
      BooleanFormFieldDescriptor(label: 'Repair schedule?'),
    ];
    final promptOutput = await userInput.promptForm('Options', formFieldDescriptors);

    Commit commit = Commit(disarmRequirementsLevel: 0);
    commit.merge = true;

    if (promptOutput != null && promptOutput[0] is bool && promptOutput[0]) {
      commit.addObjectsToPush(HardcodedPrincipalActivities.list);
    }
    if (promptOutput != null && promptOutput[1] is bool && promptOutput[1]) {
      commit.addObjectsToPush(HardcodedPrincipalCabins.list);
    }
    if (promptOutput != null && promptOutput[2] is bool && promptOutput[2]) {
      ScheduleDay day1 = HardcodedTestSchedule.day1;
      ScheduleService scheduleService = Get.find<ScheduleService>();
      ContextService clientContextService = Get.find<ContextService>();
      Schedule schedule = await clientContextService.schedule;
      if (schedule.scheduleDayCmps.isEmpty) {
        schedule.scheduleDayCmps.add(day1.id);
        commit.addObjectToPush(day1);
      }
      commit.addObjectToPush(schedule);
      scheduleService.addBlockToDay(commit, commit.getObjectOfType<ScheduleDay>()!.id, HardcodedTestSchedule.choiceActivity);
      scheduleService.scheduleActivity(
        commit,
        HardcodedPrincipalActivities.gagaBall.id,
        commit.getObjectOfType<ScheduleBlock>()!.id,
      );
      scheduleService.scheduleActivity(
        commit,
        HardcodedPrincipalActivities.boating.id,
        commit.getObjectOfType<ScheduleBlock>()!.id,
      );
      scheduleService.scheduleActivity(
        commit,
        HardcodedPrincipalActivities.climbing.id,
        commit.getObjectOfType<ScheduleBlock>()!.id,
      );
      scheduleService.scheduleActivity(
        commit,
        HardcodedPrincipalActivities.artsAndCrafts.id,
        commit.getObjectOfType<ScheduleBlock>()!.id,
      );
      scheduleService.scheduleActivity(
        commit,
        HardcodedPrincipalActivities.tieDye.id,
        commit.getObjectOfType<ScheduleBlock>()!.id,
      );
      scheduleService.scheduleActivity(
        commit,
        HardcodedPrincipalActivities.archery.id,
        commit.getObjectOfType<ScheduleBlock>()!.id,
      );
      scheduleService.scheduleActivity(
        commit,
        HardcodedPrincipalActivities.cardGames.id,
        commit.getObjectOfType<ScheduleBlock>()!.id,
      );
      scheduleService.scheduleActivity(
        commit,
        HardcodedPrincipalActivities.soccer.id,
        commit.getObjectOfType<ScheduleBlock>()!.id,
      );
    }

    if (commit.objectsToPush.isNotEmpty) {
      await commitRepo.commit(commit);
      userOutput.log('Repair process completed!');
    }
  }
}

class InitSessionA extends EmberCommand {
  final UserService userService = Get.find<UserService>();
  final ClientContext clientContext = Get.find<ClientContext>();
  final CommitRepository commitRepo = Get.find<CommitRepository>();

  @override
  final String name = 'initsesha';
  @override
  final String description = 'Initializes session A';
  @override
  String get invocationDetails => 'initsesha';
  @override
  List<String> get examples => ['initsesha'];

  InitSessionA({required super.userInput, required super.userOutput});

  @override
  Future<dynamic> run() async {
    final List<FormFieldDescriptor> formFieldDescriptors = [
      BooleanFormFieldDescriptor(label: 'Initial Domain Setup'),
    ];
    final promptOutput = await userInput.promptForm('Options', formFieldDescriptors);

    Commit commit = Commit(disarmRequirementsLevel: 0);

    if (promptOutput != null && promptOutput[0] is bool && promptOutput[0] == true) {
      commit.addObjectToPush(HardcodedSessionA.sessionA);
      await commitRepo.commit(commit);
      userOutput.log('Init process completed!');
      return;
    }

    ScheduleService scheduleService = Get.find<ScheduleService>();
    Schedule schedule = HardcodedSessionA.sessionASchedule;

    commit.addObjectToPush(HardcodedSessionA.monday);
    commit.addObjectToPush(HardcodedSessionA.tuesday);
    commit.addObjectToPush(HardcodedSessionA.wednesday);
    commit.addObjectToPush(HardcodedSessionA.thursday);
    commit.addObjectToPush(HardcodedSessionA.friday);

    schedule.scheduleDayCmps.add(HardcodedSessionA.monday.id);
    schedule.scheduleDayCmps.add(HardcodedSessionA.tuesday.id);
    schedule.scheduleDayCmps.add(HardcodedSessionA.wednesday.id);
    schedule.scheduleDayCmps.add(HardcodedSessionA.thursday.id);
    schedule.scheduleDayCmps.add(HardcodedSessionA.friday.id);

    scheduleService.addBlockToDay(commit, HardcodedSessionA.monday.id, HardcodedSessionA.choiceActivity1Mon);
    scheduleService.addBlockToDay(commit, HardcodedSessionA.monday.id, HardcodedSessionA.choiceActivity2Mon);

    scheduleService.addBlockToDay(commit, HardcodedSessionA.tuesday.id, HardcodedSessionA.skillsRec);
    scheduleService.addBlockToDay(commit, HardcodedSessionA.tuesday.id, HardcodedSessionA.choiceActivity1Tue);
    scheduleService.addBlockToDay(commit, HardcodedSessionA.tuesday.id, HardcodedSessionA.choiceActivity2Tue);

    scheduleService.addBlockToDay(commit, HardcodedSessionA.wednesday.id, HardcodedSessionA.choiceActivity1Wed);
    scheduleService.addBlockToDay(commit, HardcodedSessionA.wednesday.id, HardcodedSessionA.choiceActivity2Wed);

    scheduleService.addBlockToDay(commit, HardcodedSessionA.thursday.id, HardcodedSessionA.choiceActivity1Thu);
    scheduleService.addBlockToDay(commit, HardcodedSessionA.thursday.id, HardcodedSessionA.choiceActivity2Thu);

    scheduleService.addBlockToDay(commit, HardcodedSessionA.friday.id, HardcodedSessionA.choiceActivityFri);

    commit.addObjectToPush(schedule);

    scheduleService.scheduleActivity(
      commit,
      HardcodedPrincipalActivities.friendshipBracelets.id,
      HardcodedSessionA.choiceActivity1Mon.id,
    );
    scheduleService.scheduleActivity(commit, HardcodedPrincipalActivities.archery.id, HardcodedSessionA.choiceActivity1Mon.id);
    scheduleService.scheduleActivity(commit, HardcodedPrincipalActivities.nineSquare.id, HardcodedSessionA.choiceActivity1Mon.id);
    scheduleService.scheduleActivity(commit, HardcodedPrincipalActivities.climbing.id, HardcodedSessionA.choiceActivity1Mon.id);
    scheduleService.scheduleActivity(commit, HardcodedPrincipalActivities.beachWalk.id, HardcodedSessionA.choiceActivity1Mon.id);
    scheduleService.scheduleActivity(
      commit,
      HardcodedPrincipalActivities.shelterBuilding.id,
      HardcodedSessionA.choiceActivity1Mon.id,
    );
    scheduleService.scheduleActivity(commit, HardcodedPrincipalActivities.basketball.id, HardcodedSessionA.choiceActivity1Mon.id);

    scheduleService.scheduleActivity(commit, HardcodedPrincipalActivities.climbing.id, HardcodedSessionA.choiceActivity2Mon.id);
    scheduleService.scheduleActivity(commit, HardcodedPrincipalActivities.lowRopes.id, HardcodedSessionA.choiceActivity2Mon.id);
    scheduleService.scheduleActivity(commit, HardcodedPrincipalActivities.archery.id, HardcodedSessionA.choiceActivity2Mon.id);
    scheduleService.scheduleActivity(commit, HardcodedPrincipalActivities.soccer.id, HardcodedSessionA.choiceActivity2Mon.id);
    scheduleService.scheduleActivity(commit, HardcodedPrincipalActivities.rockArt.id, HardcodedSessionA.choiceActivity2Mon.id);
    scheduleService.scheduleActivity(
      commit,
      HardcodedPrincipalActivities.parachuteGames.id,
      HardcodedSessionA.choiceActivity2Mon.id,
    );
    scheduleService.scheduleActivity(commit, HardcodedPrincipalActivities.beachWalk.id, HardcodedSessionA.choiceActivity2Mon.id);

    scheduleService.scheduleActivity(commit, HardcodedPrincipalActivities.artsAndCrafts.id, HardcodedSessionA.skillsRec.id);
    scheduleService.scheduleActivity(commit, HardcodedPrincipalActivities.yogaAndMindfulness.id, HardcodedSessionA.skillsRec.id);
    scheduleService.scheduleActivity(commit, HardcodedPrincipalActivities.archerySkillsRec.id, HardcodedSessionA.skillsRec.id);
    scheduleService.scheduleActivity(commit, HardcodedPrincipalActivities.creativeWriting.id, HardcodedSessionA.skillsRec.id);
    scheduleService.scheduleActivity(commit, HardcodedPrincipalActivities.soccer.id, HardcodedSessionA.skillsRec.id);
    scheduleService.scheduleActivity(commit, HardcodedPrincipalActivities.music.id, HardcodedSessionA.skillsRec.id);
    scheduleService.scheduleActivity(commit, HardcodedPrincipalActivities.cricket.id, HardcodedSessionA.skillsRec.id);

    scheduleService.scheduleActivity(commit, HardcodedPrincipalActivities.canoeing.id, HardcodedSessionA.choiceActivity1Tue.id);
    scheduleService.scheduleActivity(commit, HardcodedPrincipalActivities.archery.id, HardcodedSessionA.choiceActivity1Tue.id);
    scheduleService.scheduleActivity(commit, HardcodedPrincipalActivities.pickleball.id, HardcodedSessionA.choiceActivity1Tue.id);
    scheduleService.scheduleActivity(commit, HardcodedPrincipalActivities.beachWalk.id, HardcodedSessionA.choiceActivity1Tue.id);
    scheduleService.scheduleActivity(commit, HardcodedPrincipalActivities.tieDye.id, HardcodedSessionA.choiceActivity1Tue.id);
    scheduleService.scheduleActivity(commit, HardcodedPrincipalActivities.volleyball.id, HardcodedSessionA.choiceActivity1Tue.id);
    scheduleService.scheduleActivity(
      commit,
      HardcodedPrincipalActivities.hammockTime.id,
      HardcodedSessionA.choiceActivity1Tue.id,
    );

    scheduleService.scheduleActivity(commit, HardcodedPrincipalActivities.climbing.id, HardcodedSessionA.choiceActivity2Tue.id);
    scheduleService.scheduleActivity(commit, HardcodedPrincipalActivities.canoeing.id, HardcodedSessionA.choiceActivity2Tue.id);
    scheduleService.scheduleActivity(commit, HardcodedPrincipalActivities.archery.id, HardcodedSessionA.choiceActivity2Tue.id);
    scheduleService.scheduleActivity(commit, HardcodedPrincipalActivities.painting.id, HardcodedSessionA.choiceActivity2Tue.id);
    scheduleService.scheduleActivity(commit, HardcodedPrincipalActivities.bingo.id, HardcodedSessionA.choiceActivity2Tue.id);
    scheduleService.scheduleActivity(commit, HardcodedPrincipalActivities.natureHike.id, HardcodedSessionA.choiceActivity2Tue.id);
    scheduleService.scheduleActivity(commit, HardcodedPrincipalActivities.tieDye.id, HardcodedSessionA.choiceActivity2Tue.id);

    scheduleService.scheduleActivity(commit, HardcodedPrincipalActivities.canoeing.id, HardcodedSessionA.choiceActivity1Wed.id);
    scheduleService.scheduleActivity(commit, HardcodedPrincipalActivities.archery.id, HardcodedSessionA.choiceActivity1Wed.id);
    scheduleService.scheduleActivity(
      commit,
      HardcodedPrincipalActivities.shelterBuilding.id,
      HardcodedSessionA.choiceActivity1Wed.id,
    );
    scheduleService.scheduleActivity(commit, HardcodedPrincipalActivities.beachWalk.id, HardcodedSessionA.choiceActivity1Wed.id);
    scheduleService.scheduleActivity(commit, HardcodedPrincipalActivities.tieDye.id, HardcodedSessionA.choiceActivity1Wed.id);
    scheduleService.scheduleActivity(
      commit,
      HardcodedPrincipalActivities.hammockTime.id,
      HardcodedSessionA.choiceActivity1Wed.id,
    );
    scheduleService.scheduleActivity(commit, HardcodedPrincipalActivities.lowRopes.id, HardcodedSessionA.choiceActivity1Wed.id);

    scheduleService.scheduleActivity(commit, HardcodedPrincipalActivities.climbing.id, HardcodedSessionA.choiceActivity2Wed.id);
    scheduleService.scheduleActivity(commit, HardcodedPrincipalActivities.canoeing.id, HardcodedSessionA.choiceActivity2Wed.id);
    scheduleService.scheduleActivity(commit, HardcodedPrincipalActivities.archery.id, HardcodedSessionA.choiceActivity2Wed.id);
    scheduleService.scheduleActivity(commit, HardcodedPrincipalActivities.fieldGames.id, HardcodedSessionA.choiceActivity2Wed.id);
    scheduleService.scheduleActivity(
      commit,
      HardcodedPrincipalActivities.hidingFromAuthority.id,
      HardcodedSessionA.choiceActivity2Wed.id,
    );
    scheduleService.scheduleActivity(commit, HardcodedPrincipalActivities.soccer.id, HardcodedSessionA.choiceActivity2Wed.id);
    scheduleService.scheduleActivity(commit, HardcodedPrincipalActivities.tieDye.id, HardcodedSessionA.choiceActivity2Wed.id);

    scheduleService.scheduleActivity(commit, HardcodedPrincipalActivities.canoeing.id, HardcodedSessionA.choiceActivity1Thu.id);
    scheduleService.scheduleActivity(commit, HardcodedPrincipalActivities.archery.id, HardcodedSessionA.choiceActivity1Thu.id);
    scheduleService.scheduleActivity(
      commit,
      HardcodedPrincipalActivities.birdWatching.id,
      HardcodedSessionA.choiceActivity1Thu.id,
    );
    scheduleService.scheduleActivity(commit, HardcodedPrincipalActivities.beachWalk.id, HardcodedSessionA.choiceActivity1Thu.id);
    scheduleService.scheduleActivity(commit, HardcodedPrincipalActivities.tieDye.id, HardcodedSessionA.choiceActivity1Thu.id);
    scheduleService.scheduleActivity(commit, HardcodedPrincipalActivities.volleyball.id, HardcodedSessionA.choiceActivity1Thu.id);
    scheduleService.scheduleActivity(commit, HardcodedPrincipalActivities.gagaBall.id, HardcodedSessionA.choiceActivity1Thu.id);

    scheduleService.scheduleActivity(commit, HardcodedPrincipalActivities.climbing.id, HardcodedSessionA.choiceActivity2Thu.id);
    scheduleService.scheduleActivity(commit, HardcodedPrincipalActivities.canoeing.id, HardcodedSessionA.choiceActivity2Thu.id);
    scheduleService.scheduleActivity(commit, HardcodedPrincipalActivities.archery.id, HardcodedSessionA.choiceActivity2Thu.id);
    scheduleService.scheduleActivity(commit, HardcodedPrincipalActivities.volleyball.id, HardcodedSessionA.choiceActivity2Thu.id);
    scheduleService.scheduleActivity(commit, HardcodedPrincipalActivities.cardGames.id, HardcodedSessionA.choiceActivity2Thu.id);
    scheduleService.scheduleActivity(commit, HardcodedPrincipalActivities.natureHike.id, HardcodedSessionA.choiceActivity2Thu.id);
    scheduleService.scheduleActivity(commit, HardcodedPrincipalActivities.tieDye.id, HardcodedSessionA.choiceActivity2Thu.id);

    scheduleService.scheduleActivity(commit, HardcodedPrincipalActivities.aggressiveCompliments.id, HardcodedSessionA.choiceActivityFri.id);
    scheduleService.scheduleActivity(commit, HardcodedPrincipalActivities.hidingFromAuthority.id, HardcodedSessionA.choiceActivityFri.id);
    scheduleService.scheduleActivity(
      commit,
      HardcodedPrincipalActivities.archery.id,
      HardcodedSessionA.choiceActivityFri.id,
    );
    scheduleService.scheduleActivity(commit, HardcodedPrincipalActivities.fairyHouses.id, HardcodedSessionA.choiceActivityFri.id);
    scheduleService.scheduleActivity(commit, HardcodedPrincipalActivities.tieDye.id, HardcodedSessionA.choiceActivityFri.id);
    scheduleService.scheduleActivity(commit, HardcodedPrincipalActivities.volleyball.id, HardcodedSessionA.choiceActivityFri.id);
    scheduleService.scheduleActivity(commit, HardcodedPrincipalActivities.climbing.id, HardcodedSessionA.choiceActivityFri.id);
    scheduleService.scheduleActivity(commit, HardcodedPrincipalActivities.planes.id, HardcodedSessionA.choiceActivityFri.id);

    await commitRepo.commit(commit);
    userOutput.log('Init process completed!');
  }
}

class ResetActivityAssignments extends EmberCommand {
  final DatabaseRepairService repairService = Get.find<DatabaseRepairService>();
  final CommitRepository commitRepo = Get.find<CommitRepository>();

  @override
  final String name = 'rstact';
  @override
  final String description = 'Resets all activity assignments';
  @override
  String get invocationDetails => 'rstact';
  @override
  List<String> get examples => ['rstact'];

  ResetActivityAssignments({required super.userInput, required super.userOutput});

  @override
  Future<dynamic> run() async {
    Commit commit = Commit(disarmRequirementsLevel: 0);
    try {
      await repairService.resetAllAssignmentsAndPreferences(commit: commit);
      await commitRepo.commit(commit);
    } on Exception catch (e, st) {
      Error.throwWithStackTrace(Debug.parseException(e), st);
    }
    userOutput.log('Activity assignments have been reset!');
  }
}
