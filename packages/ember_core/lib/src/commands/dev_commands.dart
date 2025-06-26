import 'package:ember_cli_utils/ember_cli_utils.dart';
import 'package:ember_core/src/hardcode/hardcoded_principal_activites.dart';
import 'package:ember_core/src/hardcode/hardcoded_principal_cabins.dart';
import 'package:ember_core/src/hardcode/hardcoded_schedule.dart';
import 'package:ember_core/src/repositories/commit_repository.dart';
import 'package:get/get.dart';

import '../../ember_core.dart';
import '../models/core_objects/schedule_day.dart';

class DevCommands {
  static Map<String, EmberCommand> list = {
    'rephc': RepairHardCode(
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

  RepairHardCode({
    required super.userInput,
    required super.userOutput,
  });

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
      ScheduleDay day1 = HardcodedSchedule.day1;
      ScheduleService scheduleService = Get.find<ScheduleService>();
      ContextService clientContextService = Get.find<ContextService>();
      Schedule schedule = await clientContextService.schedule;
      if (schedule.scheduleDayCmps.isEmpty) {
        schedule.scheduleDayCmps.add(day1.id);
        day1.blockCmps.add(day1.id);
        commit.addObjectToPush(day1);
      }
      commit.addObjectToPush(schedule);
      scheduleService.addBlockToDay(
          commit, commit.getObjectOfType<ScheduleDay>()!.id, HardcodedSchedule.choiceActivity);
      scheduleService.scheduleActivity(
          commit, HardcodedPrincipalActivities.gagaBall.id, commit.getObjectOfType<ScheduleBlock>()!.id);
      scheduleService.scheduleActivity(
          commit, HardcodedPrincipalActivities.boating.id, commit.getObjectOfType<ScheduleBlock>()!.id);
      scheduleService.scheduleActivity(
          commit, HardcodedPrincipalActivities.climbing.id, commit.getObjectOfType<ScheduleBlock>()!.id);
      scheduleService.scheduleActivity(
          commit, HardcodedPrincipalActivities.artsAndCrafts.id, commit.getObjectOfType<ScheduleBlock>()!.id);
      scheduleService.scheduleActivity(
          commit, HardcodedPrincipalActivities.tieDye.id, commit.getObjectOfType<ScheduleBlock>()!.id);
      scheduleService.scheduleActivity(
          commit, HardcodedPrincipalActivities.archery.id, commit.getObjectOfType<ScheduleBlock>()!.id);
      scheduleService.scheduleActivity(
          commit, HardcodedPrincipalActivities.cardGames.id, commit.getObjectOfType<ScheduleBlock>()!.id);
      scheduleService.scheduleActivity(
          commit, HardcodedPrincipalActivities.soccer.id, commit.getObjectOfType<ScheduleBlock>()!.id);
    }

    if (commit.objectsToPush.isNotEmpty) {
      await commitRepo.commit(commit);
      userOutput.log('Repair process completed!');
    }
  }
}