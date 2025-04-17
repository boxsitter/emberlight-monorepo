import 'package:ember_core/ember_core_models.dart';

class DeleteRequest {
  bool _armed;
  final int _disarmRequirementsLevel;
  Map<String, CoreObject> objectsToDelete = {};
  Map<String, CoreObject> objectsToPush = {};
  String confirmationMessage;

  bool get armed => _armed;
  int get disarmRequirementsLevel => _disarmRequirementsLevel;

  void disarm() {
    if (disarmRequirementsLevel > 2) {
      _armed = false;
    } else {
      throw Exception('This operation cannot be completed.'); // TODO: make a better error system please
    }
  }

  // Constructor for initialization
  DeleteRequest({
    required int disarmRequirementsLevel,
    this.confirmationMessage = '',
  })  : _armed = disarmRequirementsLevel > 0,
        _disarmRequirementsLevel = disarmRequirementsLevel;


  void addObjectToDelete(CoreObject object) {
    objectsToDelete[object.id] = object;
  }

  void addObjectToPurge(CoreObject object) {
    objectsToDelete[object.id] = object;
  }

  T? getObject<T>({CoreObject? object, String? id}) {
    if (object != null) {
      CoreObject? objectToReturn = objectsToDelete[object.id];
      objectToReturn = objectsToPush[object.id];
      if (objectToReturn != null && objectToReturn is T) {
        return objectToReturn as T;
      } else {
        return null;
      }
    } else if (id != null) {
      CoreObject? objectToReturn = objectsToDelete[id];
      objectToReturn = objectsToPush[id];
      if (objectToReturn != null && objectToReturn is T) {
        return objectToReturn as T;
      } else {
        return null;
      }
    } else {
      return null;
    }
  }

  T? getObjectOfType<T>() {
    for (var value in objectsToPush.values) {
      if (value is T) {
        return value as T;
      }
    }

    for (var value in objectsToDelete.values) {
      if (value is T) {
        return value as T;
      }
    }
    return null;
  }
}