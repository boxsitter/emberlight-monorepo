import 'package:ember_core/ember_core_backend.dart';
import 'package:ember_core/ember_core_models.dart';
import 'package:ember_core/ember_core_services.dart';
import 'package:ember_core/src/hard_coded_objects.dart';
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
  static Future<void> initializeEmberCore (BackendInterface backendInterface) async {
    BackendManager.setBackend(backendInterface);
    BackendInterface backend = BackendManager.instance;
    Get.put(ClientContext());
    Get.put(RequestService());
    await backend.init();
    if (EmberCoreConfig.doDumbDomainSetup) {
      await backend.dumbDomainSetup(HardcodedObjects.ygs, HardcodedObjects.colman, HardcodedObjects.season, HardcodedObjects.session);
    }
    ClientContextService clientContextService = ClientContextService();
    await clientContextService.setDefaultContext();
    Get.put( clientContextService);
    backend.initLate();
    if (EmberCoreConfig.repairHardcodedObjects) {
      await repairHardcodedObjects();
    }
    Get.put(CabinService());
    Get.put(SessionRosterService());
    Get.put(ConsoleService());
    Get.put(ScheduleService());
    Get.put(FrontendCommitService());
  }

  static Future<void> repairHardcodedObjects() async {
    BackendInterface backend = BackendManager.instance;
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
}

class EmberCoreConfig {
  static bool repairHardcodedObjects = false;
  static bool doDumbDomainSetup = false;
}