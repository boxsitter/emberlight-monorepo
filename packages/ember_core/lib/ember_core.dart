import 'package:ember_core/ember_core_backend.dart';
import 'package:ember_core/ember_core_frontend.dart';
import 'package:ember_core/ember_core_models.dart';
import 'package:ember_core/ember_core_services.dart';
import 'package:ember_core/src/hard_coded_objects.dart';
import 'package:ember_core/src/models/core_objects/schedule_day.dart';
import 'package:get/get.dart';

/// Ember Core - The core logic and business layer for Emberlight software
///
/// This package contains the core business logic, models models, and service interfaces
/// for Emberlight software. It is completely platform-agnostic and does not directly
/// depend on any frontend or backend specific code. All backend operations are
/// abstracted within the backend repository layer.
///
/// Usage:
/// Import this package in your UI layer to access business logic and service methods.

class EmberCore {
  static void initializeComponents(CoreBackend backendInterface, CoreFrontend frontendInterface) {
    BackendManager.setBackend(backendInterface);
    FrontendManager.setFrontend(frontendInterface);
  }

  static void initializeEmberCore () {
    CoreBackend backend = BackendManager.instance;
    Get.put(CommitService(), permanent: true);
    Get.put( ClientContext());
    backend.init();
    ClientContextService clientContextService = Get.put(ClientContextService());
    clientContextService.setDefaultContext();
    backend.initLate();
    Get.put(CabinService(), permanent: true);
    Get.put(SessionRosterService(), permanent: true);
    Get.put(ActivityPreferenceService(), permanent: true);
    Get.put(ConsoleService(), permanent: true);
    Get.put(ScheduleService(), permanent: true);
    Get.put(FrontendCommitService(), permanent: true);
  }

  static Future<void> recoverEmberCore () async {
    CoreBackend backend = BackendManager.instance;
    Get.put(CommitService(), permanent: true);
    Get.put( ClientContext());
    backend.init();
    await backend.dumbDomainSetup(HardcodedObjects.ygs, HardcodedObjects.colman, HardcodedObjects.season, HardcodedObjects.session);
    ClientContextService clientContextService = Get.put(ClientContextService());
    clientContextService.setDefaultContext();
    backend.initLate();
    Get.put(CabinService(), permanent: true);
    Get.put(SessionRosterService(), permanent: true);
    Get.put(ActivityPreferenceService(), permanent: true);
    Get.put(ConsoleService(), permanent: true);
    Get.put(ScheduleService(), permanent: true);
    Get.put(FrontendCommitService(), permanent: true);
    await repairHardcodedObjects();
    await initializeTestSchedule();
  }

  static Future<void> repairHardcodedObjects() async {
    CoreBackend backend = BackendManager.instance;
    Commit commit = Commit(disarmRequirementsLevel: 0);
    await backend.mergeObjectsWithDatabase(
      commit: commit,
      objects: HardcodedObjects.hardcodedObjects,
      prioritizeAFields: true,
      prioritizeAValues: true,
      overwriteWithEmptyAValues: false,
      aFieldsToIgnore: {'createdAt'},
    );
    await backend.commit(commit);
  }

  static Future<void> initializeTestSchedule() async {
    CoreBackend backend = BackendManager.instance;
    Commit commit = Commit(disarmRequirementsLevel: 0);
    ScheduleDay day1 = HardcodedObjects.day1;
    ScheduleService scheduleService = Get.find<ScheduleService>();
    ClientContextService clientContextService = Get.find<
        ClientContextService>();
    Schedule schedule = await clientContextService.schedule;
    schedule.scheduleDayCmps.add(day1.id);
    day1.blockCmps.add(day1.id);
    commit.addObjectToPush(day1);
    commit.addObjectToPush(schedule);
    scheduleService.addBlockToDay(
        commit, commit.getObjectOfType<ScheduleDay>()!.id, HardcodedObjects.choiceActivity);
    scheduleService.scheduleActivity(
        commit, HardcodedObjects.gagaBall.id, commit.getObjectOfType<ScheduleBlock>()!.id);
    scheduleService.scheduleActivity(
        commit, HardcodedObjects.boating.id, commit.getObjectOfType<ScheduleBlock>()!.id);
    scheduleService.scheduleActivity(
        commit, HardcodedObjects.climbing.id, commit.getObjectOfType<ScheduleBlock>()!.id);
    scheduleService.scheduleActivity(
        commit, HardcodedObjects.artsAndCrafts.id, commit.getObjectOfType<ScheduleBlock>()!.id);
    scheduleService.scheduleActivity(
        commit, HardcodedObjects.tieDye.id, commit.getObjectOfType<ScheduleBlock>()!.id);
    scheduleService.scheduleActivity(
        commit, HardcodedObjects.archery.id, commit.getObjectOfType<ScheduleBlock>()!.id);

    await backend.mergeObjectsWithDatabase(
      commit: commit,
      objects: commit.objectsToPush.values.toSet(),
      prioritizeAFields: true,
      prioritizeAValues: true,
      overwriteWithEmptyAValues: false,
      aFieldsToIgnore: {'createdAt'},
    );
    await backend.commit(commit);
  }
}