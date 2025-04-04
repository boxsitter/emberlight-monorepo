import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ember_core/ember_core_models.dart';
import 'package:ember_core/ember_core_services.dart';
import 'package:ember_core/ember_core_utils.dart';
import 'package:ember_core/ember_core_validators.dart';
import 'package:get/get.dart';


import '../path_service.dart';

class PushRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  late final ClientContextService clientContextService;
  final PathService pathService = Get.find<PathService>();
  RequestService requestService = Get.find<RequestService>();

  get db => _db;

  // /// Writes [object] to Firestore at the path derived from its ID, merging fields if the doc exists.
  // /// This really should only be used in favor of bulkPushObjects if a user action truly requires just one object be pushed
  // Future<void> _pushObject(BessObject object) async {
  //   final resolvedPath = pathService.getDocPathFromId(object.id);
  //   try {
  //     Map<String, dynamic> document = object.toJson();
  //     BessIdValidation.validateDocument(document);
  //     print('Pushing object: ${object.id}');
  //     BessHelperFunctions.updateDocumentTimestamp(document);
  //     await _db.doc(resolvedPath).set(document, SetOptions(merge: true));
  //   } catch (e) {
  //     print('Error pushing object at $resolvedPath: $e');
  //     rethrow;
  //   }
  // }

  /// Pushes a set of [BessObject]s to Firestore using batch writes.
  /// Automatically updates the `updatedAt` field on each object.
  Future<void> _bulkPushObjects(Set<BessObject> objects) async {
    if (objects.isEmpty) return;

    final batch = _db.batch();

    for (final object in objects) {
      Map<String, dynamic> document = object.toJson();
      BessIdValidation.validateDocument(document);
      CoreHelperFunctions.updateDocumentTimestamp(document);
      final resolvedPath = pathService.getDocPathFromId(object.id);
      final docId = _db.doc(resolvedPath);
      batch.set(docId, document, SetOptions(merge: true));
    }

    try {
      await batch.commit();
      print('Successfully pushed ${objects.length} objects.');
    } catch (e) {
      print('Error during bulk push: $e');
      rethrow;
    }
  }

  Future<void> commit(PushRequest pushRequest) async {
    Set<BessObject> objectsToPush = pushRequest.objectsToPush;
    if (objectsToPush.isEmpty) {
      throw ArgumentError('Can\'t commit nothing');
    }

    if (!await requestService.disarmRequest(pushRequest)) {
      print('Operation cannot proceed');
      return;
    }

    Map<String, dynamic> sessionDoc = (await _db.doc(pathService.getDocPathFromId(clientContextService.sessionId)).get()).data()!;
    Session session = Session.fromJson(sessionDoc);

    Map<String, Set<String>> updatedRefTracker = _updateRefTracker(session.refTracker, objectsToPush);
    session.refTracker = updatedRefTracker;
    objectsToPush.add(session);
    _bulkPushObjects(objectsToPush);
  }

  static Map<String, Set<String>> _updateRefTracker(Map<String, Set<String>> refTracker, Set<BessObject> objects) {
    final Set<Map<String, dynamic>> documents = objects.map((element) => element.toJson()).toSet();
    // Process each document to update the tracker.
    for (final doc in documents) {
      final docId = doc['id'] as String;
      // Extract the set of referenced IDs from the document.
      final currentRefs = _thisDocumentReferences(doc);

      // Remove stale references:
      // For each key in the tracker, if the doc's id is present but the key is no longer referenced in the doc, remove it.
      for (final key in refTracker.keys.toList()) {
        if (refTracker[key]!.contains(docId) && !currentRefs.contains(key)) {
          refTracker[key]!.remove(docId);
        }
      }

      // Add missing references:
      // For each referenced id in the document, ensure that the doc's id is added to the tracker.
      for (final id in currentRefs) {
        refTracker.putIfAbsent(id, () => <String>{}).add(docId);
      }
    }

    // Remove unreferenced objects:
    // Delete any tracker entry whose set is empty.
    refTracker.removeWhere((key, set) => set.isEmpty);

    return refTracker;
  }

  static Set<String> _thisDocumentReferences(Map<String, dynamic> document) {
    Set<String> referencedIds = {};

    void collectIds(String key, dynamic value) {
      if (key.endsWith('ref') || key.endsWith('refs') || key.endsWith('Ref') || key.endsWith('Refs')) {
        if (value is String) {
          referencedIds.add(value);
        } else if (value is List) {
          for (var item in value) {
            if (item is String) {
              referencedIds.add(item);
            }
          }
        }
      } else if (value is Map<String, dynamic>) {
        value.forEach(collectIds);
      }
    }

    document.forEach(collectIds);
    return referencedIds;
  }

  // Future<void> commit(CommitData request) {
  //   // TODO: Implement this!
  // }

  // /// Updates an existing Firestore document using its 'id' field in [data].
  // /// Throws an [ArgumentError] if 'id' is missing or not a [String].
  // Future<void> updateDocument(Map<String, dynamic> data) async {
  //   if (data['id'] is! String) {
  //     throw ArgumentError("Document must contain a valid 'id' field.");
  //   }
  //   final id = data['id'] as String;
  //   final resolvedPath = pathService.getPathFromId(id, false);
  //
  //   try {
  //     // Automatically set updatedAt to now (in UTC)
  //     data['updatedAt'] = DateTime.now().toUtc();
  //     print('Updating doc: $id');
  //     await _db.doc(resolvedPath).update(data);
  //   } catch (e) {
  //     print('Error updating document at $resolvedPath: $e');
  //     rethrow;
  //   }
  // }

}
