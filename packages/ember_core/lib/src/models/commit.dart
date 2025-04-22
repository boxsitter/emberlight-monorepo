import 'dart:math';

import 'package:ember_core/ember_core_models.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';

class Commit {
  bool _armed;
  final int _disarmRequirementsLevel;
  final Map<String, CoreObject> objectsToPush = {};
  final Map<String, CoreObject> objectsToDelete = {};
  String confirmationMessage;

  bool get armed => _armed;
  int get disarmRequirementsLevel => _disarmRequirementsLevel;

  void disarm() {
    if (disarmRequirementsLevel < 2) {
      _armed = false;
    } else {
      throw Exception('This operation cannot be completed.'); // TODO: make a better error system please
    }
  }

  // Constructor for initialization
  Commit({
    required int disarmRequirementsLevel,
    this.confirmationMessage = '',
  })  : _armed = disarmRequirementsLevel > 0,
        _disarmRequirementsLevel = disarmRequirementsLevel;

  void addObjectToPush(CoreObject object) {
    objectsToPush[object.id] = object;
  }

  void addObjectsToPush(Set<CoreObject> objects) {
    for (CoreObject object in objects) {
      addObjectToPush(object);
    }
  }

  void addObjectToDelete(CoreObject object) {
    objectsToDelete[object.id] = object;
  }

  void addObjectsToDelete(Set<CoreObject> objects) {
    for (CoreObject object in objects) {
      addObjectToDelete(object);
    }
  }

  T? getObject<T>(dynamic objectOrId) {
    if (objectOrId is CoreObject) {
      CoreObject? objectToReturn = objectsToPush[objectOrId.id];
      if (objectToReturn != null && objectToReturn is T) {
        return objectToReturn as T;
      } else {
        return null;
      }
    } else if (objectOrId is String) {
      CoreObject? objectToReturn = objectsToPush[objectOrId];
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

  String? queryFieldByType(Type targetType, String field, dynamic value) {
    // Iterate through the values (CoreObject instances) in your map
    for (CoreObject object in objectsToPush.values) {
      // 1. Check if the current object's runtime type matches the targetType
      if (object.runtimeType == targetType) {
        // 2. If the type matches, convert the object to JSON
        Map<String, dynamic> json = object.toJson();

        // 3. Check if the field exists in the JSON and if its value matches the provided value
        if (json.containsKey(field) && json[field] == value) {
          // 4. If both conditions are met, return the object's ID
          return object.id;
        }
      }
    }
    // 5. If the loop completes without finding a match, return null
    return null;
  }
}