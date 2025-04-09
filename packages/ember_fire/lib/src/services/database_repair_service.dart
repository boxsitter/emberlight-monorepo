
// ignore_for_file: unnecessary_null_comparison

import 'package:ember_core/ember_core_models.dart';
import 'package:ember_core/ember_core_utils.dart';
import 'package:ember_fire/src/repositories/dumb_push_repository.dart';
import 'package:get/get.dart';

import '../repositories/pull_repository.dart';

class DatabaseRepairService extends GetxService{
  static const double matchThreshold = 0.75;
  static const double fieldPresenceWeight = 0.20;
  static const double valueEqualityWeight = 0.25;
  static const Set<String> specialFields = {'name', 'firstName'};
  static const double specialFieldPresenceWeight = 0.15;
  static const double specialValueEqualityWeight = 0.40;
  static const Set<String> alwaysIgnore = {'id', 'createdAt', 'updatedAt'};


  PullRepository pullRepo = Get.find<PullRepository>();
  DumbPushRepository dumbRepo = Get.find<DumbPushRepository>();

  // TODO: Implement
  // void cleanOrphanedDependants() {
  //   // the reference tracker tracks all ids that reference the master
  // }

  // TODO: Do something better to solve this please
  Future<void> dumbDomainSetup (Organization org, Branch branch, Season season, Session session) async {
    String orgId = org.id;
    String branchId = branch.id;
    String seasonId = season.id;
    String sessionId = session.id;

    await dumbRepo.dumbPush('organization/$orgId', org);
    await dumbRepo.dumbPush('organization/$orgId/branch/$branchId', branch);
    await dumbRepo.dumbPush('organization/$orgId/branch/$branchId/season/$seasonId', season);
    await dumbRepo.dumbPush('organization/$orgId/branch/$branchId/season/$seasonId/session/$sessionId', session);
  }

  Future<PushRequest> mergeObjectsWithDatabase({
    required Set<CoreObject> objects,
    required bool prioritizeAFields,
    required bool prioritizeAValues,
    required bool overwriteWithEmptyAValues,
    Set<String>? aFieldsToIgnore,
  }) async {
    PushRequest pushRequest = PushRequest(disarmRequirementsLevel: 0);
    for (CoreObject object in objects) {
      pushRequest.add(await mergeObjectWithDatabase(
        objectToMerge: object,
        prioritizeAFields: prioritizeAFields,
        prioritizeAValues: prioritizeAValues,
        overwriteWithEmptyAValues: overwriteWithEmptyAValues,
        aFieldsToIgnore: aFieldsToIgnore,
      ));
    }
    return pushRequest;
  }

  Future<PushRequest> mergeObjectWithDatabase({
    required CoreObject objectToMerge,
    required bool prioritizeAFields,
    required bool prioritizeAValues,
    required bool overwriteWithEmptyAValues,
    Set<String>? aFieldsToIgnore,
  }) async {
    String idA = objectToMerge.id;
    Map<String, dynamic> jsonA = objectToMerge.toJson();
    Map<String, dynamic>? jsonB;

    if (await pullRepo.docExists(idA)) {
      jsonB = await pullRepo.getDoc(idA);
    } else {
      String jsonACollection = IdFunctions.getIdPart(idA, 1);
      String jsonADomain = IdFunctions.getIdPart(idA, 0);
      Map<String, dynamic>? likelyMatch = await getLikelyMatchFromCollection(jsonA: jsonA, collectionName: jsonACollection, domain: jsonADomain);
      if (likelyMatch != null) {
        jsonB = likelyMatch;
      }
    }

    if (jsonB == null) {
      return PushRequest(disarmRequirementsLevel: 0, objectsToPush: {CoreObject.fromJson(jsonA)});
    }

    // Start with B's data as our base
    final mergedJson = {...jsonB};

    // Iterate over each field in A
    jsonA.forEach((key, valueA) {
      // If this field is ignored, skip it
      if ((aFieldsToIgnore != null && aFieldsToIgnore.contains(key)) || key == 'id') {
        return;
      }

      // If B doesn't have this field
      if (!jsonB!.containsKey(key)) {
        // Only add the field if prioritizeAFields is true
        if (prioritizeAFields) {
          mergedJson[key] = valueA;
        }
      } else {
        // B does have this field
        final valueB = jsonB[key];

        // If B’s value is null but A’s is not, use A’s value
        if (jsonB[key] == null && valueA != null) {
          mergedJson[key] = valueA;
        }
        // If both values are non-null and differ
        else if (valueB != null && valueA != null && valueB != valueA) {
          if (prioritizeAValues) {
            // If A is empty but overwriteWithEmptyAValues is false, skip overwriting
            if (!_isEmptyValue(valueA) || overwriteWithEmptyAValues) {
              mergedJson[key] = valueA;
            }
            // else keep B's value
          }
          // else if not prioritizeAValues, do nothing here (keep B)
        }
      }
    });

    // If we are NOT prioritizing A’s fields, keep any extra fields that only exist in B
    if (!prioritizeAFields) {
      jsonB.forEach((key, valueB) {
        // If A doesn't have this key
        if (!jsonA.containsKey(key)) {
          // Also skip if it's in the ignore list
          if (aFieldsToIgnore != null && aFieldsToIgnore.contains(key)) {
            return;
          }
          mergedJson[key] = valueB;
        }
      });
    }

    // If there's a known doc ID from B, we keep that. Otherwise, fallback to A's ID.
    mergedJson['id'] = (jsonB != null && jsonB.containsKey('id')) ? jsonB['id'] : idA;

    CoreObject mergedObject = CoreObject.fromJson(mergedJson);
    return PushRequest(
      disarmRequirementsLevel: 0,
      objectsToPush: {mergedObject},
    );
  }

  bool _isEmptyValue(dynamic value) {
    if (value == null) return true;
    if (value is String && value.isEmpty) return true;
    if (value is Iterable && value.isEmpty) return true;
    if (value is Map && value.isEmpty) return true;
    return false;
  }

  Future<Map<String, dynamic>?> getLikelyMatchFromCollection({
    required Map <String, dynamic> jsonA,
    required  String collectionName,
    required String domain,
  }) async {
    Set<Map <String, dynamic>> jsons = (await pullRepo.getDocsInCollection(collectionName, domain)).values.toSet();
    for (var jsonB in jsons) {
      if (computeJsonSimilarity(jsonA, jsonB) >= matchThreshold) {
        print('MATCHING DOC FOUND!');
        return jsonB;
      }
    }
    return null;
  }

  /// Compares two JSON maps and returns a similarity score in [0..1].
  ///
  /// By default, this method:
  /// - Weighs "field presence" more heavily than "exact matching values."
  /// - Performs a recursive equality check on nested values
  /// - Treats numeric fields as equal only if they have the same value.
  /// - Id is excluded
  ///
  /// The sum of all weights MUST equal 1.0 or an error will be thrown
  /// specialFields is not required to be set, however if it is,
  /// specialFieldPresenceWeight and specialValueEqualityWeight
  /// must not be null

  double computeJsonSimilarity(Map<String, dynamic> jsonA, Map<String, dynamic> jsonB) {
    // --- Weight Validation ---
    if (specialFields == null && fieldPresenceWeight + valueEqualityWeight != 1.0) {
      throw ArgumentError('The sum of fieldPresenceWeight and valueEqualityWeight must be 1.0');
    } else if (specialFields != null && (specialFieldPresenceWeight == null || specialValueEqualityWeight == null)) {
      throw ArgumentError('specialFieldPresenceWeight and specialValueEqualityWeight cannot be null if specialFields is not null');
    } else if (specialFields != null && fieldPresenceWeight + valueEqualityWeight + specialFieldPresenceWeight! + specialValueEqualityWeight! != 1.0) {
      throw ArgumentError('The sum of all weights must be 1.0');
    }
    // --- End Weight Validation ---

    bool specialFieldsPresent = specialFields != null && specialFields.any((field) => jsonA.containsKey(field) || jsonB.containsKey(field));

    double effectiveFieldPresenceWeight;
    double effectiveValueEqualityWeight;
    double effectiveSpecialFieldPresenceWeight = 0;
    double effectiveSpecialValueEqualityWeight = 0;

    if (specialFieldsPresent && specialFields != null && specialFieldPresenceWeight != null && specialValueEqualityWeight != null) {
      effectiveFieldPresenceWeight = fieldPresenceWeight;
      effectiveValueEqualityWeight = valueEqualityWeight;
      effectiveSpecialFieldPresenceWeight = specialFieldPresenceWeight!;
      effectiveSpecialValueEqualityWeight = specialValueEqualityWeight!;
    } else {
      double originalRegularWeightSum = fieldPresenceWeight + valueEqualityWeight;
      if (originalRegularWeightSum <= 0) {
        effectiveFieldPresenceWeight = 0.5; // Default split if original weights are zero
        effectiveValueEqualityWeight = 0.5;
      } else {
        effectiveFieldPresenceWeight = fieldPresenceWeight / originalRegularWeightSum;
        effectiveValueEqualityWeight = valueEqualityWeight / originalRegularWeightSum;
      }
    }

    final Set<String> regularExclude = {...?specialFields, ...alwaysIgnore};
    double fieldPresenceIndex = compareFieldPresence(jsonA: jsonA, jsonB: jsonB, exclude: regularExclude);
    double valueEqualityIndex = compareValueEquality(jsonA: jsonA, jsonB: jsonB, exclude: regularExclude);

    double sum = fieldPresenceIndex * effectiveFieldPresenceWeight + valueEqualityIndex * effectiveValueEqualityWeight;

    double specialFieldPresenceIndex = 0;
    double specialValueEqualityIndex = 0;

    if (specialFieldsPresent && specialFields != null) {
      double specialFieldPresenceIndex = compareFieldPresence(jsonA: jsonA, jsonB: jsonB, limitedTo: specialFields, exclude: alwaysIgnore);
      double specialValueEqualityIndex = compareValueEquality(jsonA: jsonA, jsonB: jsonB, limitedTo: specialFields, exclude: alwaysIgnore);
      sum += specialFieldPresenceIndex * effectiveSpecialFieldPresenceWeight + specialValueEqualityIndex * effectiveSpecialValueEqualityWeight;

      // --- Add this print statement ---
      print(
          "Similarity (${jsonA['id']} vs ${jsonB['id']}): "
              "RegFP(${fieldPresenceIndex.toStringAsFixed(3)}*${effectiveFieldPresenceWeight.toStringAsFixed(3)}) + "
              "RegVE(${valueEqualityIndex.toStringAsFixed(3)}*${effectiveValueEqualityWeight.toStringAsFixed(3)}) + "
              "SpcFP(${specialFieldPresenceIndex.toStringAsFixed(3)}*${effectiveSpecialFieldPresenceWeight.toStringAsFixed(3)}) + "
              "SpcVE(${specialValueEqualityIndex.toStringAsFixed(3)}*${effectiveSpecialValueEqualityWeight.toStringAsFixed(3)}) = "
              "${sum.toStringAsFixed(3)}"
      );
      // --- End print statement ---

    }

    return sum;
  }

  /// Computes how similar two JSONs are in terms of field presence.
  ///
  /// - Returns 1.0 if `jsonA` and `jsonB` have exactly the same fields (after
  ///   filtering), 0.0 if they share none.
  /// - If `limitedTo` is non-null, only consider fields within that set.
  /// - If `exclude` is non-null, exclude fields in that set.
  /// - If both `limitedTo` and `exclude` are null, consider all fields.
  ///
  /// This uses the Jaccard index (|A ∩ B| / |A ∪ B|) for the relevant fields.
  double compareFieldPresence({
    required Map<String, dynamic> jsonA,
    required Map<String, dynamic> jsonB,
    Set<String>? limitedTo,
    Set<String>? exclude,
  }) {
    Set<String> fieldsA = jsonA.keys.toSet();
    Set<String> fieldsB = jsonB.keys.toSet();

    // Apply `limitedTo` if present.
    if (limitedTo != null) {
      fieldsA = fieldsA.intersection(limitedTo);
      fieldsB = fieldsB.intersection(limitedTo);
    }

    // Apply `exclude` if present.
    if (exclude != null) {
      fieldsA = fieldsA.difference(exclude);
      fieldsB = fieldsB.difference(exclude);
    }

    // Compute intersection and union for the filtered sets.
    final intersection = fieldsA.intersection(fieldsB);
    final union = fieldsA.union(fieldsB);

    // If both sets are empty after filtering, we'll treat them as "same," i.e. score = 1.0.
    if (union.isEmpty) {
      return 1.0;
    }

    // Use Jaccard index: intersectionSize / unionSize.
    return intersection.length / union.length;
  }

  /// Compares values for all matching fields in [jsonA] and [jsonB], returning
  /// a score in [0..1].
  ///
  /// - Only considers fields that exist in both JSONs (the intersection).
  /// - If [limitedTo] is non-null, only consider fields in that set.
  /// - If [exclude] is non-null, skip fields in that set.
  /// - If there are no fields left after filtering, we return 1.0 by convention
  ///   (i.e., "no mismatches" among nonexistent fields).
  /// - Comparison is done with a simple `==` (top-layer).
  double compareValueEquality({
    required Map<String, dynamic> jsonA,
    required Map<String, dynamic> jsonB,
    Set<String>? limitedTo,
    Set<String>? exclude,
  }) {
    // Gather field names from each JSON as sets.
    var fieldsA = jsonA.keys.toSet();
    var fieldsB = jsonB.keys.toSet();

    // Apply `limitedTo` if present.
    if (limitedTo != null) {
      fieldsA = fieldsA.intersection(limitedTo);
      fieldsB = fieldsB.intersection(limitedTo);
    }

    // Apply `exclude` if present.
    if (exclude != null) {
      fieldsA = fieldsA.difference(exclude);
      fieldsB = fieldsB.difference(exclude);
    }

    // Only compare fields that exist in both JSONs.
    final commonFields = fieldsA.intersection(fieldsB);

    if (commonFields.isEmpty) {
      // If *neither* JSON had any relevant fields after filtering,
      // then they are "equally empty" - score 1.0.
      if (fieldsA.isEmpty && fieldsB.isEmpty) {
        return 1.0;
      } else {
        // Otherwise, at least one JSON had relevant fields, but
        // none were shared. Value equality for the considered
        // set is 0.0 because no values could be compared.
        return 0.0;
      }
    }

    int matchCount = 0;
    for (var key in commonFields) {
      if (_valuesAreEqual(jsonA[key], jsonB[key])) {
        matchCount++;
      }
    }

    // Return fraction of how many matched out of total in the intersection.
    // commonFields length is guaranteed to be > 0 here.
    return matchCount / commonFields.length;
  }

  bool _valuesAreEqual(dynamic a, dynamic b) {
    if (a is DateTime && b is DateTime) {
      // Convert both to UTC before comparing their equality
      return a.toUtc() == b.toUtc();
    }

    // If both are Lists, do a listEquality check
    if (a is List && b is List) {
      if (a.length != b.length) return false;
      for (int i = 0; i < a.length; i++) {
        if (!_valuesAreEqual(a[i], b[i])) return false;
      }
      return true;
    }

    // If both are Maps, do a mapEquality check
    if (a is Map && b is Map) {
      if (a.length != b.length) return false;
      for (var k in a.keys) {
        if (!b.containsKey(k) || !_valuesAreEqual(a[k], b[k])) {
          return false;
        }
      }
      return true;
    }

    // Otherwise, fall back to `==`
    return a == b;
  }

}
