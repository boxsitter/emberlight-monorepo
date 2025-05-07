
import 'package:ember_core/ember_core_debug.dart';
import 'package:ember_core/ember_core_models.dart';

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
      throw CoreUnsupportedError('Attempted to disarm commit with disarmRequirementsLevel: $disarmRequirementsLevel, levels greater than 1 are not supported yet');
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
    Debug.logInfo('Object $object staged for push in commit', verbosity: Verbosity.excessive);
  }

  void addObjectsToPush(Set<CoreObject> objects) {
    for (CoreObject object in objects) {
      addObjectToPush(object);
    }
  }

  void addObjectToDelete(CoreObject object) {
    objectsToDelete[object.id] = object;
    Debug.logInfo('Object $object staged for delete in commit', verbosity: Verbosity.excessive);
  }

  void addObjectsToDelete(Set<CoreObject> objects) {
    for (CoreObject object in objects) {
      addObjectToDelete(object);
    }
  }

  T? getObject<T>(dynamic objectOrId) {
    if (objectOrId is CoreObject) {
      Debug.logInfo('Fetching CoreObject: $objectOrId from commit', verbosity: Verbosity.excessive);
      CoreObject? objectToReturn = objectsToPush[objectOrId.id];
      if (objectToReturn != null && objectToReturn is T) {
        Debug.logSuccess('Successfully fetched $objectOrId from commit', verbosity: Verbosity.excessive);
        return objectToReturn as T;
      } else {
        Debug.logWarning('Object $objectOrId could not be found in commit cache, returning null', verbosity: Verbosity.verbose);
        return null;
      }
    } else if (objectOrId is String) {
      Debug.logInfo('Fetching CoreObject with id: $objectOrId from commit', verbosity: Verbosity.excessive);
      CoreObject? objectToReturn = objectsToPush[objectOrId];
      if (objectToReturn != null && objectToReturn is T) {
        Debug.logSuccess('Successfully fetched object with id: $objectOrId from commit', verbosity: Verbosity.excessive);
        return objectToReturn as T;
      } else {
        Debug.logWarning('Object with id: $objectOrId could not be found in commit cache, returning null', verbosity: Verbosity.verbose);
        return null;
      }
    } else {
      return null;
    }
  }

  // Returns the first object of type T
  T? getObjectOfType<T>() {
    Debug.logInfo('Fetching first object of type $T from commit', verbosity: Verbosity.excessive);
    for (var value in objectsToPush.values) {
      if (value is T) {
        Debug.logSuccess('Successfully fetched object of type $T from commit', verbosity: Verbosity.excessive);
        return value as T;
      }
    }
    Debug.logWarning('No object of type $T found in commit, returning null', verbosity: Verbosity.verbose);
    return null;
  }

  Set<T> getObjectsOfType<T>() {
    Debug.logInfo('Fetching all objects of type $T from commit', verbosity: Verbosity.excessive);
    Set<T> returnSet = {};
    objectsToPush.forEach((key, value) {
      if (value is T) {
        returnSet.add(value as T);
      }
    });
    if (returnSet.isEmpty) {
      Debug.logWarning('No objects of type $T found in commit, returning empty set', verbosity: Verbosity.verbose);
    } else {
      Debug.logSuccess('Successfully fetched all objects of type $T from commit', verbosity: Verbosity.excessive);
    }
    return returnSet;
  }

  String? queryFieldByType(Type targetType, String field, dynamic value) {
    Debug.logInfo('Fetching ID of first object in commit with field: $field set to $value', verbosity: Verbosity.excessive);
    // Iterate through the values (CoreObject instances) in your map
    for (CoreObject object in objectsToPush.values) {
      // 1. Check if the current object's runtime type matches the targetType
      if (object.runtimeType == targetType) {
        // 2. If the type matches, convert the object to JSON
        Map<String, dynamic> json = object.toJson();

        // 3. Check if the field exists in the JSON and if its value matches the provided value
        if (json.containsKey(field) && json[field] == value) {
          // 4. If both conditions are met, return the object's ID
          Debug.logSuccess('Successfully fetched ID of object with field: $field set to $value', verbosity: Verbosity.excessive);
          return object.id;
        }
      }
    }
    // 5. If the loop completes without finding a match, return null
    Debug.logWarning('No object found with field: $field set to $value. Returning null', verbosity: Verbosity.verbose);
    return null;
  }
}