import 'package:bessie/common/services/path_service.dart';
import 'package:bessie/common/utils/helpers/bess_id_functions.dart';
import 'package:bessie/common/utils/validators/bess_id_validation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class PullRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final PathService pathService = Get.find<PathService>();

  FirebaseFirestore get db => _db;

  /// Retrieves a document from Firestore for the given [id] using the resolved document path.
  /// Returns a map of the document data if it exists, or null if it doesn't.
  /// Throws an error if there is an issue during retrieval.
  Future<Map<String, dynamic>?> _getDocument(String id) async {
    final resolvedPath = pathService.getDocPathFromId(id);
    try {
      print('Getting doc: $id');
      final doc = await _db.doc(resolvedPath).get();
      return doc.exists ? doc.data() : null;
    } catch (e) {
      // TODO: replace with logging system and proper error throwing
      print('Error fetching document at $resolvedPath: $e');
      rethrow;
    }
  }

  /// Retrieves multiple documents from Firestore for the given set of [ids].
  /// Validates that all IDs share the same collection and batches the queries according to Firestore’s whereIn limit.
  /// Returns a map where each key is a document ID and the value is its data (or null if not found).
  Future<Map<String, Map<String, dynamic>?>> _getDocuments(Set<String> ids) async {
    if (ids.isEmpty) return {};
    BessIdValidation.validateIdsShareCollection(ids);
    final collection = pathService.getCollectionPathFromId(ids.first);
    final idList = BessIdFunctions.refIdsToObjs(ids).toList();

    print('Getting docs: [${ids.join('\n')}]');

    // Create batches of at most 10 IDs each (Firestore whereIn limit)
    final batches = <List<String>>[];
    for (int i = 0; i < idList.length; i += 10) {
      final end = (i + 10 < idList.length) ? i + 10 : idList.length;
      batches.add(idList.sublist(i, end));
    }

    // Execute each batch query concurrently and collect their results
    final batchResults = await Future.wait(batches.map((batch) async {
      final querySnapshot = await _db
          .collection(collection)
          .where(FieldPath.documentId, whereIn: batch)
          .get();
      final batchMap = <String, Map<String, dynamic>?>{};
      for (final doc in querySnapshot.docs) {
        batchMap[doc.id] = doc.data();
      }
      return batchMap;
    }));

    // Merge the maps from all batches into a single results map
    final results = <String, Map<String, dynamic>?>{};
    for (final map in batchResults) {
      results.addAll(map);
    }
    return results;
  }

  /// Retrieves all documents from the collection specified by [collectionName] and [domain].
  /// Returns a map of document IDs to their data.
  /// Throws an error if the retrieval fails.
  Future<Map<String, Map<String, dynamic>?>> _getDocumentsInCollection(String collectionName, String domain) async {
    final results = <String, Map<String, dynamic>?>{};
    final collection = pathService.getCollectionPath(collectionName, domain);
    try {
      print('Fetching all documents from collection: $collectionName');
      final querySnapshot = await _db.collection(collection).get();
      for (final doc in querySnapshot.docs) {
        results[doc.id] = doc.data();
      }
    } catch (e) {
      print('Error fetching documents from collection $collectionName: $e');
      rethrow;
    }
    return results;
  }

  /// Retrieves the specific [field] from a document identified by [id].
  /// Throws an error if the document or the field is not found.
  Future<dynamic> _getDocumentField(String id, String field) async {
    final document = await _getDocument(id);
    if (document == null) {
      throw ArgumentError("Document with id '$id' does not exist.");
    }
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
    return value as T;
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
  Future<T> getObject<T>(String id, T Function(Map<String, dynamic> json) fromJson,) async {
    final data = await _getDocument(id);
    if (data == null) {
      throw StateError('No document found for ID: $id');
    }
    return fromJson(data);
  }

  /// Retrieves multiple documents specified by the set of [ids] and converts each into an object of type [T]
  /// using the provided [fromJson] function.
  /// Throws an error if any document is not found.
  /// Returns a set of the converted objects.
  Future<Set<T>> getObjects<T>(Set<String> ids, T Function(Map<String, dynamic> json) fromJson,) async {
    final documentMap = await _getDocuments(ids);
    return ids.map((id) {
      final data = documentMap[id];
      if (data == null) {
        throw StateError('No document found for ID: $id');
      }
      return fromJson(data);
    }).toSet();
  }

  /// Retrieves all documents from the collection defined by [collectionName] and [domain],
  /// converting each document’s data into an object of type [T] via the [fromJson] function.
  /// Throws an error if any document is missing.
  /// Returns a set of the converted objects.
  Future<Set<T>> getObjectsInCollection<T>(String collectionName, String domain, T Function(Map<String, dynamic> json) fromJson,) async {
    final documentMap = await _getDocumentsInCollection(collectionName, domain);
    return documentMap.entries.map((entry) {
      if (entry.value == null) {
        throw StateError('No document found for ID: ${entry.key}');
      }
      return fromJson(entry.value!);
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
