import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../common/services/path_service.dart';

class FirebaseRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  PathService pathService = Get.find<PathService>();

  /// Helper method that replaces "./" with the workingDirectory from pathService.
  String _resolvePath(String path) {
    if (path.startsWith('./')) {
      return path.replaceFirst('./', pathService.workingDirectory);
    }
    return path;
  }

  /// Retrieves a document from the given [path].
  /// [path] should be a full path like 'Organizations/orgId/Branches/branchId/...'
  Future<Map<String, dynamic>?> getDocument(String path) async {
    final resolvedPath = _resolvePath(path);
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

  // Returns all document IDs in a collection
  Future<List<String>> getDocumentIds(String collectionPath) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection(collectionPath).get();
    return snapshot.docs.map((doc) => doc.id).toList();
  }

  // Checks if a document exists in a collection
  Future<bool> documentExists(String collectionPath, String docId) async {
    DocumentSnapshot doc = await FirebaseFirestore.instance.collection(collectionPath).doc(docId).get();
    return doc.exists;
  }

  // Returns an object from a document pointed to by path
  // TODO: Errors and crashes if the document doesn't exist, fix that
  Future<T> getObject<T>(String path, T Function(Map<String, dynamic> json) fromJson,) async {
    return fromJson((await getDocument(path))!);
  }

  Future<Map<String, T>> getCollectionAsObjects<T>(String path, T Function(Map<String, dynamic> json) fromJson,) async {
    final resolvedPath = _resolvePath(path);
    try {
      QuerySnapshot snapshot = await _db.collection(resolvedPath).get();

      Map<String, T> objectsMap = {};
      for (var doc in snapshot.docs) {
        objectsMap[doc.id] = fromJson(doc.data() as Map<String, dynamic>);
      }
      return objectsMap;
    }
    catch (e) {
      print("Error retrieving collection at $resolvedPath: $e");
      rethrow;
    }
  }

  /// Retrieves objects from a Firestore collection that are active now.
  /// Assumes each document has "startDate" and "endDate" fields.
  Future<List<T>> getActiveObjects<T>(String path, T Function(Map<String, dynamic>) fromJson) async {
    final resolvedPath = _resolvePath(path);
    final now = DateTime.now();
    // Use the reusable method to get all objects.
    final objectsMap = await getCollectionAsObjects<T>(resolvedPath, fromJson);

    // Filter objects based on startDate and endDate.
    return objectsMap.values.where((obj) {
      final dynamic dynamicObj = obj;
      final DateTime startDate = dynamicObj.startDate;
      final DateTime endDate = dynamicObj.endDate;
      return now.isAfter(startDate) && now.isBefore(endDate);
    }).toList();
  }

  /// Retrieves a single active object from a Firestore collection that is active now.
  /// Assumes each document has "startDate" and "endDate" fields. If more than one active object is found, throws an error.
  Future<T?> getUniqueActiveObject<T>(String path, T Function(Map<String, dynamic>) fromJson,) async {
    final resolvedPath = _resolvePath(path);
    final activeObjects = await getActiveObjects<T>(resolvedPath, fromJson);

    if (activeObjects.length > 1) {
      throw Exception("Error: More than one active object found in '$resolvedPath'. Overlapping is not allowed.");
    }

    return activeObjects.isNotEmpty ? activeObjects.first : null;
  }

  /// Sets the document at [path] with the given [data].
  /// If the document doesn't exist, it will be created.
  Future<void> setDocument(String path, Map<String, dynamic> data) async {
    final resolvedPath = _resolvePath(path);
    try {
      await _db.doc(resolvedPath).set(data);
    } catch (e) {
      print("Error setting document at $resolvedPath: $e");
      rethrow;
    }
  }

  /// Updates the document at [path] with the given [data].
  Future<void> updateDocument(String path, Map<String, dynamic> data) async {
    final resolvedPath = _resolvePath(path);
    try {
      await _db.doc(resolvedPath).update(data);
    } catch (e) {
      print("Error updating document at $resolvedPath: $e");
      rethrow;
    }
  }

  /// Deletes the document at the given [path].
  Future<void> deleteDocument(String path) async {
    final resolvedPath = _resolvePath(path);
    try {
      await _db.doc(resolvedPath).delete();
    } catch (e) {
      print("Error deleting document at $resolvedPath: $e");
      rethrow;
    }
  }

  /// Returns a stream that listens to real-time changes for the document at [path].
  Stream<Map<String, dynamic>?> documentStream(String path) {
    final resolvedPath = _resolvePath(path);
    return _db.doc(resolvedPath).snapshots().map((doc) {
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
      return null;
    });
  }

  /// Returns a stream for a collection at [path].
  /// [path] should be a collection path like 'Organizations/orgId/Branches/branchId/...'
  Stream<List<Map<String, dynamic>>> collectionStream(String path) {
    final resolvedPath = _resolvePath(path);
    return _db.collection(resolvedPath).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  /// Caches all data in a given collection path by fetching it.
  /// This will load the data into Firestore's local cache.
  Future<void> cacheDataForPath(String path) async {
    final resolvedPath = _resolvePath(path);
    try {
      // Assuming 'path' refers to a collection path.
      QuerySnapshot snapshot = await _db.collection(resolvedPath).get();
      print("Cached ${snapshot.docs.length} documents from $resolvedPath");
    } catch (e) {
      print("Error caching data for path $resolvedPath: $e");
    }
  }
}
