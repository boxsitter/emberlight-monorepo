import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ember_core/ember_core_models.dart';
import 'package:ember_core/ember_core_utils.dart';
import 'package:ember_core/ember_core_validators.dart';
import 'package:get/get.dart';

import '../services/path_service.dart';

class PullRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final PathService pathService = Get.find<PathService>();

  FirebaseFirestore get db => _db;

  Future<bool> docExists(String id) async {
    final resolvedPath = pathService.getDocPathFromId(id);
    print('Getting doc: $id');

    try {
      final docSnapshot = await _db.doc(resolvedPath).get();
      // If doc doesn't exist or doc.data() is null, return empty map
      if (!docSnapshot.exists || docSnapshot.data() == null) {
        return false;
      } else {
        return true;
      }
    } on FirebaseException catch (e) {
      print('Error fetching document at $resolvedPath: ${e.message}');
      rethrow;
    } catch (e) {
      // Handle all other errors
      print('Error fetching document at $resolvedPath: $e');
      rethrow;
    }
  }

  /// Retrieves a document from Firestore for the given [id] using the resolved document path.
  /// Returns a map of the document data if it exists, or null if it doesn't.
  /// Throws an error if there is an issue during retrieval.
  Future<Map<String, dynamic>> getDoc(String id) async {
    final resolvedPath = pathService.getDocPathFromId(id);
    print('Getting doc: $id');

    try {
      final docSnapshot = await _db.doc(resolvedPath).get();

      // If doc doesn't exist or doc.data() is null, return empty map
      if (!docSnapshot.exists || docSnapshot.data() == null) {
        return {};
      }

      // Convert timestamps in the final data map
      final data = docSnapshot.data()!;
      convertToDateTime(data);
      return data;
    } on FirebaseException catch (e) {
      print('Error fetching document at $resolvedPath: ${e.message}');
      rethrow;
    } catch (e) {
      // Handle all other errors
      print('Error fetching document at $resolvedPath: $e');
      rethrow;
    }
  }


  /// Retrieves multiple documents from Firestore for the given set of [ids].
  /// Validates that all IDs share the same collection and batches the queries according to Firestore’s whereIn limit.
  /// Returns a map where each key is a document ID and the value is its data.
  Future<Map<String, Map<String, dynamic>>> getDocs(Set<String> ids) async {
    if (ids.isEmpty) {
      return {};
    }

    // Validate that all IDs share the same collection path
    CoreIdValidation.validateIdsShareCollection(ids);
    final collection = pathService.getCollectionPathFromId(ids.first);
    final idList = ids.toList();

    print('Getting docs: [${ids.join('\n')}]');

    // Create batches of at most 10 IDs each
    final batches = <List<String>>[];
    for (int i = 0; i < idList.length; i += 10) {
      final end = (i + 10 <= idList.length) ? i + 10 : idList.length;
      batches.add(idList.sublist(i, end));
    }

    final results = <String, Map<String, dynamic>>{};

    try {
      // Execute each batch query concurrently
      final batchResults = await Future.wait(batches.map((batch) async {
        final querySnapshot = await _db
            .collection(collection)
            .where(FieldPath.documentId, whereIn: batch)
            .get();

        final batchMap = <String, Map<String, dynamic>>{};
        for (final doc in querySnapshot.docs) {
          final data = doc.data();
          convertToDateTime(data);
          batchMap[doc.id] = data;
        }
        return batchMap;
      }));

      // Merge the maps from all batches
      for (final map in batchResults) {
        results.addAll(map);
      }
    } on FirebaseException catch (e) {
      print('Error fetching documents: ${e.message}');
      rethrow;
    } catch (e) {
      print('Error fetching documents: $e');
      rethrow;
    }

    // If none found or all were null => results is empty
    return results;
  }

  /// Retrieves all documents from the collection specified by [collectionName] and [domain].
  /// Returns a map of document IDs to their data.
  /// Throws an error if the retrieval fails.
  Future<Map<String, Map<String, dynamic>>> getDocsInCollection(String collectionName, String domain,) async {
    final collectionPath = pathService.getCollectionPath(collectionName, domain);
    print('Fetching all documents from collection: $collectionPath');
    try {
      final querySnapshot = await _db.collection(collectionPath).get();

      // If no docs, return empty map
      if (querySnapshot.docs.isEmpty) {
        return {};
      }

      final results = <String, Map<String, dynamic>>{};
      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        convertToDateTime(data);
        results[doc.id] = data;
      }
      return results;
    } on FirebaseException catch (e) {
      throw StateError(
        'Error fetching documents from $collectionName: ${e.message}',
      );
    } catch (e) {
      print('Error fetching documents from collection $collectionName: $e');
      rethrow;
    }
  }

  // Helper method
  Map<String, dynamic> convertToDateTime(Map<String, dynamic> data) {
    data.forEach((key, value) {
      if (value is Timestamp) {
        // Convert Firestore Timestamp to local DateTime.
        data[key] = value.toDate().toLocal();
      } else if (value is DateTime) {
        // Optionally, ensure it's in local time.
        data[key] = value.toLocal();
      } else if (value is String) {
        // Try parsing and leave as DateTime if successful.
        DateTime? parsed = DateTime.tryParse(value);
        if (parsed != null) {
          data[key] = parsed.toLocal();
        }
      } else if (value is Map<String, dynamic>) {
        data[key] = convertToDateTime(value);
      } else if (value is List) {
        data[key] = value.map((item) {
          if (item is Timestamp) {
            return item.toDate().toLocal();
          } else if (item is DateTime) {
            return item.toLocal();
          } else if (item is String) {
            DateTime? parsed = DateTime.tryParse(item);
            return parsed != null ? parsed.toLocal() : item;
          } else if (item is Map<String, dynamic>) {
            return convertToDateTime(item);
          }
          return item;
        }).toList();
      }
    });
    return data;
  }


  /// Retrieves the specific [field] from a document identified by [id].
  /// Throws an error if the document or the field is not found.
  Future<dynamic> _getDocumentField(String id, String field) async {
    final document = await getDoc(id);
    if (!document.containsKey(field)) {
      throw ArgumentError("Field '$field' does not exist in document with id '$id'.");
    }
    return document[field];
  }

  /// Retrieves the value of [field] from the document with the given [id] and casts it to type [T].
  /// Throws an error if the document is missing, the field doesn't exist, or if the value isn't of type [T].
  Future<T> getFieldValue<T>(String id, String field) async {
    final value = await _getDocumentField(id, field);
    if (value is! T) {
      throw ArgumentError(
          "Field '$field' is expected to be of type ${T.toString()} but found ${value.runtimeType}."
      );
    }
    print('Getting field: $field in $id');
    return value;
  }

  /// Retrieves the value of [field] from the document with the given [id] as a List,
  /// and converts it to a [Set] of type [T].
  /// Throws an error if the document or field is missing, if the field is not a List, or if the conversion fails.
  Future<Set<T>> getSetFieldValue<T>(String id, String field) async {
    final value = await _getDocumentField(id, field);
    if (value is! List) {
      throw ArgumentError(
          "Field '$field' is expected to be a List but found ${value.runtimeType}."
      );
    }
    print('Getting set: $field in $id');
    try {
      return (value).map((e) => e as T).toSet();
    } catch (_) {
      throw ArgumentError(
          "Field '$field' contains values that can't be cast to ${T.toString()}."
      );
    }
  }

  /// Retrieves a document with the given [id] and converts its data into an object of type [T]
  /// using the provided [fromJson] function.
  /// Throws an error if the document is not found.
  Future<T> getObject<T>(String id) async {
    final data = await getDoc(id);
    String objectType = IdFunctions.getIdPart(id, 1);
    return CoreObject.fromJsons[objectType]!(data) as T;
  }

  /// Retrieves multiple documents specified by the set of [ids] and converts each into an object of type [T]
  /// using the provided [fromJson] function.
  /// Throws an error if any document is not found.
  /// Returns a set of the converted objects.
  Future<Set<T>> getObjects<T>(Set<String> ids) async {
    final documentMap = await getDocs(ids);
    return ids.map((id) {
      final data = documentMap[id];
      if (data == null) {
        throw StateError('No document found for ID: $id');
      }
      String objectType = IdFunctions.getIdPart(id, 1);
      return CoreObject.fromJsons[objectType]!(data) as T;
    }).toSet();
  }

  /// Retrieves all documents from the collection defined by [collectionName] and [domain],
  /// converting each document’s data into an object of type [T] via the [fromJson] function.
  /// Throws an error if any document is missing.
  /// Returns a set of the converted objects.
  Future<Set<T>> getObjectsInCollection<T>(String collectionName, String domain) async {
    final documentMap = await getDocsInCollection(collectionName, domain);
    return documentMap.entries.map((entry) {
      return CoreObject.fromJsons[collectionName]!(entry.value) as T;
    }).toSet();
  }

  /// Queries the collection (determined by [collectionName] and [domain]) with the provided [conditions].
  /// Conditions may include equality filters as well as inequality operators ('isLessThanOrEqualTo', 'isGreaterThanOrEqualTo').
  /// Limits the query to one result and returns the ID of the first matching document.
  /// Throws an error if no matching document is found.
  Future<String> _queryCollection(String collectionName, String domain, Map<String, dynamic> conditions,) async {
    Query query = _db.collection(pathService.getCollectionPath(collectionName, domain));
    conditions.forEach((field, value) {
      if (value is Map<String, dynamic>) {
        // Handle inequality operators (example for two operators)
        value.forEach((operator, operand) {
          switch (operator) {
            case 'isLessThanOrEqualTo':
              query = query.where(field, isLessThanOrEqualTo: operand);
              break;
            case 'isGreaterThanOrEqualTo':
              query = query.where(field, isGreaterThanOrEqualTo: operand);
              break;
            default:
              throw ArgumentError("Unsupported operator: $operator");
          }
        });
      } else {
        query = query.where(field, isEqualTo: value);
      }
    });
    final querySnapshot = await query.limit(1).get();
    if (querySnapshot.docs.isEmpty) {
      throw StateError("No document found in '$collectionName' matching $conditions");
    }
    return querySnapshot.docs.first.id;
  }

  /// Queries a collection (specified by [collectionName] and [domain]) for the first document where [field] equals [value].
  /// Returns the matching document's ID if found, otherwise null.
  /// Internally leverages the [_queryCollection] method.
  Future<String?> queryField<T>(String collectionName, String domain, String field, T value,) async {
    return await _queryCollection(collectionName, domain, { field: value });
  }


  /// Queries for the first active document in the collection (specified by [collectionName] and [domain]).
  /// An active document is defined as one with a 'startDate' less than or equal to the current time
  /// and an 'endDate' greater than or equal to the current time.
  /// Returns the ID of the active document, or throws an error if none is found.
  // TODO: Handle no active sessions/seasons!!!
  Future<String> getActiveObjectId(String collectionName, String domain) async {
    final now = DateTime.now().toUtc();
    final conditions = {
      'startDate': {'isLessThanOrEqualTo': now},
      'endDate': {'isGreaterThanOrEqualTo': now},
    };

    try {
      return await _queryCollection(collectionName, domain, conditions);
    } catch (e) {
      print('Error fetching active objects: $e');
      rethrow;
    }
  }

}
