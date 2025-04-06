import 'package:ember_core/ember_core_backend.dart';
import 'package:ember_core/ember_core_models.dart';
import 'package:ember_core/src/hard_coded_objects.dart';

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
  static void initializeEmberCore (BackendInterface backendInterface) {
    BackendManager.setBackend(backendInterface);
    if (EmberCoreConfig.repairHardcodedObjects) {
      repairHardcodedObjects();
    }
  }

  static Future<void> repairHardcodedObjects() async {
    PushRequest pushRequest = await BackendManager.instance.mergeObjectsWithDatabase(
      objects: HardcodedObjects.hardcodedObjects,
      prioritizeAFields: true,
      prioritizeAValues: true,
      overwriteWithEmptyAValues: false,
      aFieldsToIgnore: {'createdAt'},
    );
  }
}

class EmberCoreConfig {
  static bool repairHardcodedObjects = true;
}