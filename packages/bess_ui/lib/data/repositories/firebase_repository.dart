import 'package:bessie/common/utils/helpers/bess_id_functions.dart';
import 'package:bessie/data/abstract/bess_object.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../../common/services/path_service.dart';

class FirebaseRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  PathService pathService = Get.find<PathService>();

  /// Retrieves a document from the given [path].
  /// [path] should be a full path like 'Organizations/orgId/Branches/branchId/...'
  Future<Map<String, dynamic>?> getDocument(String id) async {
    String prefix = BessIdFunctions.getIdPrefix(id);
    final resolvedPath = "$prefix/$id";

    try {
      DocumentSnapshot doc = await _db.doc(resolvedPath).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print("Error getting document at $resolvedPath: $e");
      rethrow;
    }
  }

  // Returns an object from a document with id
  // TODO: Errors and crashes if the document doesn't exist, fix that
  Future<T> getObject<T>(String id, T Function(Map<String, dynamic> json) fromJson,) async {
    return fromJson((await getDocument(id))!);
  }

  Future<List<T>> getObjects<T>(
      List<String> ids,
      Future<T> Function(String id) getObject,
      ) async {
    return Future.wait(ids.map((id) => getObject(id)));
  }

  /// Retrieves objects from a Firestore collection that are active now.
  /// Assumes each document has "startDate" and "endDate" fields.
  Future<List<String>> getActiveObjectIds(List<String> ids) async {
    final now = DateTime.now();
    List<String> activeIds = [];

    try {
      // Fetch only sessions that are active now (efficient in Firestore)
      QuerySnapshot querySnapshot = await _db
          .collection("sessions")
          .where("startDate", isLessThanOrEqualTo: now.toIso8601String())
          .where("endDate", isGreaterThanOrEqualTo: now.toIso8601String())
          .get();

      // Filter out only the requested session IDs (efficient in memory)
      Set<String> idSet = ids.toSet(); // Convert to a Set for fast lookup
      activeIds = querySnapshot.docs
          .where((doc) => idSet.contains(doc.id)) // Filter in memory
          .map((doc) => doc.id)
          .toList();
    } catch (e) {
      print("Error fetching active sessions: $e");
    }

    return activeIds;
  }


  /// Retrieves a single active object from a Firestore collection that is active now.
  /// Assumes each document has "startDate" and "endDate" fields. If more than one active object is found, throws an error.
  Future<String?> getFirstActiveObjectId(List<String> ids) async {
    final now = DateTime.now();
    Set<String> idSet = ids.toSet(); // Convert to a Set for fast lookup

    try {
      // Query Firestore for active sessions
      QuerySnapshot querySnapshot = await _db
          .collection("sessions")
          .where("startDate", isLessThanOrEqualTo: now.toIso8601String())
          .where("endDate", isGreaterThanOrEqualTo: now.toIso8601String())
          .get();

      // Find the first matching ID in the query results
      for (var doc in querySnapshot.docs) {
        if (idSet.contains(doc.id)) {
          return doc.id; // Return immediately when the first match is found
        }
      }
    } catch (e) {
      print("Error fetching active sessions: $e");
    }

    return null; // No matching active session found
  }

  Future<void> pushObject(BessObject object) async {
    String prefix = BessIdFunctions.getIdPrefix(object.id);
    final resolvedPath = "$prefix/${object.id}";

    try {
      await _db.doc(resolvedPath).set(object.toJson(), SetOptions(merge: true));
    } catch (e) {
      print("Error pushing object at $resolvedPath: $e");
      rethrow;
    }
  }

  /// Updates the document at [path] with the given [data].
  Future<void> updateDocument(Map<String, dynamic> data) async {
    // Ensure the 'id' field exists; otherwise, throw an error.
    if (!data.containsKey('id') || data['id'] is! String) {
    throw ArgumentError("Document must contain a valid 'id' field.");
    }
    String id = data['id'] as String;
    String prefix = BessIdFunctions.getIdPrefix(id);
    final resolvedPath = "$prefix/$id";

    try {
      await _db.doc(resolvedPath).update(data);
    } catch (e) {
      print("Error updating document at $resolvedPath: $e");
      rethrow;
    }
  }

  /// Deletes the document at the given [path].
  Future<void> deleteDocument(String id) async {
    // TODO: Call List<String> getSubObjectIds(); on the base object, run getSubObjectIds() in a loop on all ids in that list until the list stops growing, iterate through and delete all documents in that list
    String prefix = BessIdFunctions.getIdPrefix(id);
    final resolvedPath = "$prefix/$id";

    try {
      await _db.doc(resolvedPath).delete();
    } catch (e) {
      print("Error deleting document at $resolvedPath: $e");
      rethrow;
    }
  }

  /// Returns a stream that listens to real-time changes for the document at [path].
  Stream<Map<String, dynamic>?> documentStream(String path) {
    return _db.doc(path).snapshots().map((doc) {
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
      return null;
    });
  }

  /// Returns a stream for a collection at [path].
  /// [path] should be a collection path like 'Organizations/orgId/Branches/branchId/...'
  Stream<List<Map<String, dynamic>>> collectionStream(String path) {
    return _db.collection(path).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => doc.data()).toList();
    });
  }
}
