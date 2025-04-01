import 'package:bessie/common/services/client_context_service.dart';
import 'package:bessie/common/utils/helpers/bess_id_functions.dart';
import 'package:bessie/common/utils/helpers/helper_functions.dart';
import 'package:bessie/common/utils/validators/bess_id_validation.dart';
import 'package:bessie/data/abstract/bess_object.dart';
import 'package:bessie/data/helper_objects/push_request.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../common/services/path_service.dart';
import '../../common/services/request_service.dart';
import '../bess_objects/domains/branch.dart';

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
      BessHelperFunctions.updateDocumentTimestamp(document);
      final resolvedPath = pathService.getDocPathFromRef(object.objId);
      final docRef = _db.doc(resolvedPath);
      batch.set(docRef, document, SetOptions(merge: true));
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

    Map<String, dynamic> branchDoc = (await _db.doc(pathService.getDocPathFromRef(clientContextService.branchId)).get()).data()!;
    Branch branch = Branch.fromJson(branchDoc);

    Map<String, Set<String>> updatedRefTracker = _updateRefTracker(branch.refTracker, objectsToPush);
    branch.refTracker = updatedRefTracker;
    objectsToPush.add(branch);
    _bulkPushObjects(objectsToPush);

  }

  static Map<String, Set<String>> _updateRefTracker(Map<String, Set<String>> refTracker, Set<BessObject> objects) {
    final Set<Map<String, dynamic>> documents = objects.map((element) => element.toJson()).toSet();
    // Process each document to update the tracker.
    for (final doc in documents) {
      final docId = BessIdFunctions.objIdToRef(doc['objId'] as String);
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
      for (final ref in currentRefs) {
        refTracker.putIfAbsent(ref, () => <String>{}).add(docId);
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
        if (value is String && value.startsWith("ref")) {
          referencedIds.add(value);
        } else if (value is List) {
          for (var item in value) {
            if (item is String && item.startsWith("ref")) {
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
