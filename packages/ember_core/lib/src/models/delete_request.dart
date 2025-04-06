import 'package:ember_core/ember_core_models.dart';

class DeleteRequest {
  bool _armed;
  final int disarmRequirementsLevel;
  Set<CoreObject> objectsToDelete;
  Set<CoreObject> objectsToPurge;
  String confirmationMessage;

  bool get armed => _armed;

  void disarm() {
    if (disarmRequirementsLevel > 2) {
      _armed = false;
    } else {
      throw Exception('This operation cannot be completed.'); // TODO: make a better error system please
    }
  }

  // Constructor for initialization
  DeleteRequest({
    required this.disarmRequirementsLevel,
    Set<CoreObject>? objectsToDelete,
    Set<CoreObject>? objectsToPurge,
    this.confirmationMessage = '',
    Set<CoreObject>? objectsToPush,
  })  : _armed = disarmRequirementsLevel > 0,
        objectsToDelete = objectsToDelete ?? {},
        objectsToPurge = objectsToPurge ?? {};
}