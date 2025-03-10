import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Retrieves a document from the given [path].
  /// [path] should be a full path like 'Organizations/orgId/Branches/branchId/...'
  Future<Map<String, dynamic>?> getDocument(String path) async {
    try {
      DocumentSnapshot doc = await _db.doc(path).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print("Error getting document at $path: $e");
      rethrow;
    }
  }

  /// Sets the document at [path] with the given [data].
  /// If the document doesn't exist, it will be created.
  Future<void> setDocument(String path, Map<String, dynamic> data) async {
    try {
      await _db.doc(path).set(data);
    } catch (e) {
      print("Error setting document at $path: $e");
      rethrow;
    }
  }

  /// Updates the document at [path] with the given [data].
  Future<void> updateDocument(String path, Map<String, dynamic> data) async {
    try {
      await _db.doc(path).update(data);
    } catch (e) {
      print("Error updating document at $path: $e");
      rethrow;
    }
  }

  /// Deletes the document at the given [path].
  Future<void> deleteDocument(String path) async {
    try {
      await _db.doc(path).delete();
    } catch (e) {
      print("Error deleting document at $path: $e");
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
      return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    });
  }

  /// Caches all data in a given collection path by fetching it.
  /// This will load the data into Firestore's local cache.
  Future<void> cacheDataForPath(String path) async {
    try {
      // Assuming 'path' refers to a collection path.
      QuerySnapshot snapshot = await _db.collection(path).get();
      print("Cached ${snapshot.docs.length} documents from $path");
    } catch (e) {
      print("Error caching data for path $path: $e");
    }
  }
}
