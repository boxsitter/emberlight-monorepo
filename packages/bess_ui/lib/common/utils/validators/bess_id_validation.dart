import '../helpers/bess_id_functions.dart';

class BessIdValidation {
  static const String validCharacters = 'abcdefghijklmnopqrstuvwxyz0123456789_.~';
  static const Set<String> validIdTypes = {'obj', 'cmp', 'ref'};
  static const Set<String> validDomains = {'rot', 'org', 'brn', 'sea', 'ses'};
  static final RegExp potentialIdPattern = RegExp(r'^(obj|cmp|ref)-');

  static bool isValidType(String idType) => validIdTypes.contains(idType);
  static bool isValidDomain(String domain) => validDomains.contains(domain);

  static void validateIdsShareCollection(Set<String> ids) {
    if (ids.isEmpty) return;

    final List<String> firstParts = BessIdFunctions.getIdParts(ids.first);
    final String expectedDomain = firstParts[1];
    final String expectedType = firstParts[2];

    for (final id in ids.skip(1)) {
      final parts = BessIdFunctions.getIdParts(id);
      if (parts[1] != expectedDomain) {
        throw ArgumentError("Not all objects are of the same domain");
      }
      if (parts[2] != expectedType) {
        throw ArgumentError("Not all objects are of the same type");
      }
    }
  }

  /// Checks if [value] appears to be a Bess ID by ensuring it has exactly 5 parts and starts with a valid idType.
  static bool isPotentialId(String value) {
    return potentialIdPattern.hasMatch(value) && value.split('-').length == 5;
  }

  /// Performs a simple full check on the Bess ID format.
  /// Throws an error describing the failure if the format is invalid.
  static void simpleValidate(String id) {
    final List<String> idParts = BessIdFunctions.getIdParts(id);
    if (idParts.length != 5) {
      throw ArgumentError("ID '$id' does not have exactly 5 parts (found ${idParts.length}).");
    }
    if (!validIdTypes.contains(idParts[0])) {
      throw ArgumentError("ID '$id' has an invalid idType '${idParts[0]}'.");
    }
    if (!validDomains.contains(idParts[1])) {
      throw ArgumentError("ID '$id' has an invalid domain '${idParts[1]}'.");
    }
    if (idParts.last.length != 5) {
      throw ArgumentError("ID '$id' has a random part of length ${idParts.last.length}, expected 5.");
    }
  }

  static bool validateIdType(String id, String expectedType) {
    if (BessIdFunctions.getIdPart(id, 0) == expectedType) {
      return true;
    }
    return false;
  }

  static bool validateIdTypes(Set<String> ids, String expectedType) {
    for (String id in ids) {
      if (BessIdFunctions.getIdPart(id, 0) != expectedType) {
        return false;
      }
    }
    return true;
  }

  static bool validateObjectType(String id, String expectedObjectType) {
    if (BessIdFunctions.getIdPart(id, 2) == expectedObjectType) {
      return true;
    }
    return false;
  }

  /// Validates a single scalar Bess ID.
  /// [mustBeObj] forces the ID to be of type "obj" (used for the top-level "id" field).
  /// [expectedDomain] enforces that the ID's domain matches.
  /// [expectedObjectType] optionally enforces the object type.
  /// Throws an error with a descriptive message on failure.
  static void validateScalarId(String id, {required bool mustBeObj, required String expectedDomain, String? expectedObjectType}) {
    simpleValidate(id); // Throws error if invalid format.
    final List<String> idParts = BessIdFunctions.getIdParts(id);
    String idType = idParts[0];
    if (mustBeObj && idType != 'obj') {
      throw ArgumentError("Expected idType 'obj' but got '$idType' for id '$id'.");
    }
    if (!mustBeObj && idType == 'obj') {
      throw ArgumentError("Reference IDs must not be of type 'obj'. Found in '$id'.");
    }
    if (idParts[1] != expectedDomain) {
      throw ArgumentError("ID '$id' has domain '${idParts[1]}', expected '$expectedDomain'.");
    }
    if (expectedObjectType != null && idParts[2] != expectedObjectType) {
      throw ArgumentError("ID '$id' has object type '${idParts[2]}', expected '$expectedObjectType'.");
    }
  }

  /// Validates a collection (List) of potential Bess IDs.
  /// Ensures that if any item is a potential ID, then each item is valid and all items have the same idType and objectType.
  /// Throws an error with a descriptive message on failure.
  static void validateIdCollection(Iterable collection, String expectedDomain) {
    String? commonIdType;
    String? commonObjectType;
    int index = 0;
    for (var item in collection) {
      if (item is String && isPotentialId(item)) {
        try {
          validateScalarId(item, mustBeObj: false, expectedDomain: expectedDomain);
        } catch (e) {
          throw ArgumentError("In collection at index $index: $e");
        }
        final parts = BessIdFunctions.getIdParts(item);
        String currentIdType = parts[0];
        String currentObjectType = parts[2];
        if (commonIdType == null) {
          commonIdType = currentIdType;
          commonObjectType = currentObjectType;
        } else {
          if (commonIdType != currentIdType) {
            throw ArgumentError("Inconsistent idType in collection at index $index: expected '$commonIdType' but found '$currentIdType'.");
          }
          if (commonObjectType != currentObjectType) {
            throw ArgumentError("Inconsistent object type in collection at index $index: expected '$commonObjectType' but found '$currentObjectType'.");
          }
        }
      }
      index++;
    }
  }

  /// Validates the structure of a flat BessObject JSON.
  /// Requirements:
  ///   • The JSON must have an "id" field that is a valid obj ID.
  ///   • All other top-level string fields that look like IDs must not be of type "obj"
  ///     and must have the same domain as the top-level ID.
  ///   • In any collection of IDs, all items must have the same idType and objectType.
  /// Throws an error with a descriptive message on failure.
  static void validateDocument(Map<String, dynamic> json) {
    // Validate top-level "id" field.
    if (!json.containsKey('objId')) {
      throw ArgumentError("Missing required 'objId' field.");
    }
    dynamic objIdValue = json['objId'];
    if (objIdValue is! String) {
      throw ArgumentError("The 'id' field must be a string.");
    }
    try {
      simpleValidate(objIdValue);
    } catch (e) {
      throw ArgumentError("Top-level 'objId' field error: $e");
    }
    if (BessIdFunctions.getIdPart(objIdValue, 0) != 'obj') {
      throw ArgumentError("Top-level 'objId' field must be of type 'obj', but got '${BessIdFunctions.getIdPart(objIdValue, 0)}'.");
    }
    String expectedDomain = BessIdFunctions.getIdPart(objIdValue, 1);
    String expectedObjectType = BessIdFunctions.getIdPart(objIdValue, 2);

    // Validate every other top-level field.
    json.forEach((key, value) {
      if (key == 'objId') return; // Already validated.
      if (value is String) {
        if (isPotentialId(value)) {
          try {
            validateScalarId(value, mustBeObj: false, expectedDomain: expectedDomain, expectedObjectType: expectedObjectType);
          } catch (e) {
            throw ArgumentError("Field '$key' error: $e");
          }
        }
      } else if (value is List) {
        try {
          validateIdCollection(value, expectedDomain);
        } catch (e) {
          throw ArgumentError("Field '$key' collection error: $e");
        }
      }
      // Other types are ignored.
    });
  }
}