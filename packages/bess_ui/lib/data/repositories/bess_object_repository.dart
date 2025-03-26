import 'package:bessie/common/utils/helpers/bess_id_functions.dart';
import 'package:bessie/data/abstract/bess_object.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BessObjectRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  get db => _db;

  /// Retrieves a Firestore document by [id], returning its data or `null`.
  Future<Map<String, dynamic>?> getDocument(String id) async {
    final resolvedPath = '${BessIdFunctions.getIdPrefix(id)}/$id';
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

  /// Returns the value of the specified [field] from the document with the given [id].
  Future<T> getFieldValue<T>(String id, String field) async {
    final document = await getDocument(id);
    if (document == null) {
      throw ArgumentError("Document with id '$id' does not exist.");
    }
    if (!document.containsKey(field)) {
      throw ArgumentError("Field '$field' does not exist in document with id '$id'.");
    }
    final value = document[field];
    if (value is! T) {
      throw ArgumentError("Field '$field' is expected to be of type ${T.toString()} but found ${value.runtimeType}.");
    }
    return value;
  }

  /// Fetches a Firestore document by [id] and converts it to type [T].
  /// Throws an exception if the document is not found.
  Future<T> getObject<T>(String id, T Function(Map<String, dynamic> json) fromJson,) async {
    final data = await getDocument(id);
    if (data == null) {
      // TODO: replace with custom error
      throw StateError('No document found for ID: $id');
    }
    return fromJson(data);
  }

  /// Returns a set of objects of type [T] by calling [getObject] on each [id].
  Future<List<T>> getObjects<T>(Set<String> ids, Future<T> Function(String id) getObject,) =>
      Future.wait(ids.map(getObject));

  Future<List<Map<String, dynamic>>> queryDocuments({
    required String collectionName,
    required Set<String> ids,
    required Map<String, dynamic> conditions,
  }) async {
    final List<Map<String, dynamic>> results = [];
    if (ids.isEmpty) return results;
    final List<String> idList = ids.toList();
    const int batchSize = 10;

    for (int i = 0; i < idList.length; i += batchSize) {
      final int end = (i + batchSize > idList.length) ? idList.length : (i + batchSize);
      final List<String> chunk = idList.sublist(i, end);

      // Start query with the document IDs.
      Query query = _db.collection(collectionName)
          .where(FieldPath.documentId, whereIn: chunk);

      // Apply all additional equality conditions.
      conditions.forEach((field, value) {
        query = query.where(field, isEqualTo: value);
      });

      final querySnapshot = await query.get();
      for (final doc in querySnapshot.docs) {
        results.add(doc.data() as Map<String, dynamic>);
      }
    }

    return results;
  }

  Future<String?> getFirstMatchingId<T>(Set<String> ids, String field, T value) async {
    for (final id in ids) {
      try {
        final fieldValue = await getFieldValue<T>(id, field);
        if (fieldValue == value) {
          return id;
        }
      } catch (e) {
        // You can optionally log or handle errors for individual documents
        continue;
      }
    }
    return null;
  }

  // TODO: Handle no active sessions/seasons!!!
  /// Returns the IDs from [ids] that reference "active" objects.
  /// Active objects have a 'startDate' and 'endDate' that enclose the current time (in UTC).
  /// All IDs in [ids] must share the same prefix, which is used as the collection name.
  Future<Set<String>> getActiveObjectIds(Set<String> ids) async {
    if (ids.isEmpty) return {};

    final inferredCollection = BessIdFunctions.getIdPrefix(ids.first);

    // Validate that all IDs have the same prefix.
    for (final id in ids) {
      if (BessIdFunctions.getIdPrefix(id) != inferredCollection) {
        throw ArgumentError("All ids must point to the same BessObject type.");
      }
    }

    final now = DateTime.now().toUtc();
    try {
      // Pass the DateTime object directly (the plugin will convert to a Timestamp).
      final querySnapshot = await _db
          .collection(inferredCollection)
          .where('startDate', isLessThanOrEqualTo: now)
          .where('endDate', isGreaterThanOrEqualTo: now)
          .get();

      final idSet = ids.toSet();
      return querySnapshot.docs
          .where((doc) => idSet.contains(doc.id))
          .map((doc) => doc.id)
          .toSet();
    } catch (e) {
      print('Error fetching active objects: $e');
      return {};
    }
  }

  /// Returns the first matching active ID from [ids] in the given [collectionName],
  /// or `null` if none are active.
  Future<String> getFirstActiveObjectId(Set<String> ids) async {
    try {
      final activeIds = await getActiveObjectIds(ids.toSet());
      if (activeIds.isNotEmpty) {
        return activeIds.first;
      } else {
        return '';
      }
    } catch (e) {
      print('Error fetching active objects: $e');
      return '';
    }
  }

  /// Writes [object] to Firestore at the path derived from its ID, merging fields if the doc exists.
  Future<void> pushObject(BessObject object) async {
    object.updateTimestamp();
    final resolvedPath = '${BessIdFunctions.getIdPrefix(object.id)}/${object.id}';
    try {
      print('Pushing object: ${object.id}');
      await _db.doc(resolvedPath).set(object.toJson(), SetOptions(merge: true));
    } catch (e) {
      print('Error pushing object at $resolvedPath: $e');
      rethrow;
    }
  }

  /// Updates an existing Firestore document using its 'id' field in [data].
  /// Throws an [ArgumentError] if 'id' is missing or not a [String].
  Future<void> updateDocument(Map<String, dynamic> data) async {
    if (data['id'] is! String) {
      throw ArgumentError("Document must contain a valid 'id' field.");
    }
    final id = data['id'] as String;
    final resolvedPath = '${BessIdFunctions.getIdPrefix(id)}/$id';

    try {
      // Automatically set updatedAt to now (in UTC)
      data['updatedAt'] = DateTime.now().toUtc();
      await _db.doc(resolvedPath).update(data);
    } catch (e) {
      print('Error updating document at $resolvedPath: $e');
      rethrow;
    }
  }

  /// Simply deletes a document, does not perform cleanup.
  Future<void> deleteDocument(String id) async {
    final resolvedPath = '${BessIdFunctions.getIdPrefix(id)}/$id';
    try {
      await _db.doc(resolvedPath).delete();
    } catch (e) {
      print('Error deleting document at $resolvedPath: $e');
      rethrow;
    }
  }
}
