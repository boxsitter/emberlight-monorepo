import 'package:bessie/common/utils/helpers/bess_id_functions.dart';
import 'package:bessie/data/abstract/bess_object.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Retrieves a Firestore document by [id], returning its data or `null`.
  Future<Map<String, dynamic>?> getDocument(String id) async {
    final resolvedPath = '${BessIdFunctions.getIdPrefix(id)}/$id';
    try {
      final doc = await _db.doc(resolvedPath).get();
      return doc.exists ? doc.data() : null;
    } catch (e) {
      // TODO: replace with logging system and proper error throwing
      print('Error fetching document at $resolvedPath: $e');
      rethrow;
    }
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

  /// Returns the IDs from [ids] that reference "active" objects
  /// Active objects have a 'startDate' and 'endDate' that contains the current system data & time
  Future<Set<String>> getActiveObjectIds(List<String> ids) async {
    final now = DateTime.now();
    try {
      final querySnapshot = await _db
          .collection('sessions')
          .where('startDate', isLessThanOrEqualTo: now.toIso8601String())
          .where('endDate', isGreaterThanOrEqualTo: now.toIso8601String())
          .get();

      final idSet = ids.toSet();
      return querySnapshot.docs
          .where((doc) => idSet.contains(doc.id))
          .map((doc) => doc.id)
          .toSet();
    } catch (e) {
      print('Error fetching active sessions: $e');
      return {};
    }
  }

  /// Returns the first matching active ID from [ids], or `null` if none are active.
  Future<String?> getFirstActiveObjectId(Set<String> ids) async {
    final now = DateTime.now();
    try {
      final querySnapshot = await _db
          .collection('sessions')
          .where('startDate', isLessThanOrEqualTo: now.toIso8601String())
          .where('endDate', isGreaterThanOrEqualTo: now.toIso8601String())
          .get();

      final matchingDocs = querySnapshot.docs.where((doc) => ids.contains(doc.id));
      if (matchingDocs.isEmpty) return null;

      return matchingDocs.first.id; // Return the first match
    } catch (e) {
      print('Error fetching active sessions: $e');
      return null;
    }
  }

  /// Writes [object] to Firestore at the path derived from its ID, merging fields if the doc exists.
  Future<void> pushObject(BessObject object) async {
    object.updateTimestamp();
    final resolvedPath = '${BessIdFunctions.getIdPrefix(object.id)}/${object.id}';
    try {
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


  Future<void> deleteDocument(String id) async {
    // TODO: Call List<String> getSubObjectIds(); on the base object, run getSubObjectIds() in a loop on all ids in that list until the list stops growing, iterate through and delete all documents in that list
  }

  /// Streams changes to the Firestore document at [path],
  /// returning `null` if the document does not exist.
  Stream<Map<String, dynamic>?> documentStream(String path) {
    return _db.doc(path).snapshots().map(
          (doc) => doc.exists ? doc.data() : null,
    );
  }

  /// Streams all documents from the Firestore collection at [path].
  Stream<List<Map<String, dynamic>>> collectionStream(String path) =>
      _db.collection(path).snapshots().map(
            (snapshot) => snapshot.docs.map((doc) => doc.data()).toList(),
      );
}
