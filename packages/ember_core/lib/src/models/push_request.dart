import 'dart:math';

import 'package:ember_core/ember_core_models.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';

class PushRequest {
  bool _armed;
  final int _disarmRequirementsLevel;
  final Map<String, CoreObject> objectsToPush = {};
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
  PushRequest({
    required int disarmRequirementsLevel,
    this.confirmationMessage = '',
    Set<CoreObject>? initialObjects,
  })  : _armed = disarmRequirementsLevel > 0,
        _disarmRequirementsLevel = disarmRequirementsLevel {
    if (initialObjects != null) {
      addInitialObjects(initialObjects);
    }
  }

  void addInitialObjects(Set<CoreObject> initialObjects) {
    for (CoreObject object in initialObjects) {
      addObject(object);
    }
  }

  void addObject(CoreObject object) {
    objectsToPush[object.id] = object;
  }

  T? getObject<T>({CoreObject? object, String? id}) {
    if (object != null) {
      CoreObject? objectToReturn = objectsToPush[object.id];
      if (objectToReturn != null && objectToReturn is T) {
        return objectToReturn as T;
      } else {
        return null;
      }
    } else if (id != null) {
      CoreObject? objectToReturn = objectsToPush[id];
      if (objectToReturn != null && objectToReturn is T) {
        return objectToReturn as T;
      } else {
        return null;
      }
    } else {
      return null;
    }
  }

  // Returns the first object of type T
  T? getObjectOfType<T>() {
    for (var value in objectsToPush.values) {
      if (value is T) {
        return value as T;
      }
    }
    return null;
  }

  Set<T> getObjectsOfType<T>() {
    Set<T> returnSet = {};
    objectsToPush.forEach((key, value) {
      if (value is T) {
        returnSet.add(value as T);
      }
    });
    return returnSet;
  }
}