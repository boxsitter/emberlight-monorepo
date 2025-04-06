import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ember_core/ember_core_models.dart';
import 'package:ember_core/ember_core_services.dart';
import 'package:ember_core/ember_core_utils.dart';
import 'package:ember_core/ember_core_validators.dart';
import 'package:get/get.dart';


import '../services/path_service.dart';

class PushRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  late final ClientContextService clientContextService;
  final PathService pathService = Get.find<PathService>();
  RequestService requestService = Get.find<RequestService>();

  get db => _db;

  /// Pushes a set of [CoreObject]s to Firestore using batch writes.
  /// Automatically updates the `updatedAt` field on each object.
  Future<void> _bulkPushObjects(Set<CoreObject> objects) async {
    if (objects.isEmpty) return;

    final batch = _db.batch();

    for (final object in objects) {
      Map<String, dynamic> document = object.toJson();
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
    Set<CoreObject> objectsToPush = pushRequest.objectsToPush;
    if (objectsToPush.isEmpty) {
      throw ArgumentError('Can\'t commit nothing');
    }

    if (!await requestService.disarmRequest(pushRequest)) {
      print('Operation cannot proceed');
      return;
    }

    Map<String, dynamic> sessionDoc = (await _db.doc(pathService.getDocPathFromId(clientContextService.sessionId)).get()).data()!;
    Session newSession = Session.fromJson(sessionDoc);
    await Future.wait([
      Future(() => _updateRefTracker(newSession.refTracker, objectsToPush)),
      Future(() => _updatePrincipalDependantLinkTracker(newSession.principalDependantLinkTracker, objectsToPush)),
    ]);


    CoreObject? existing = objectsToPush.lookup(newSession);
    if (existing == null) {
      objectsToPush.add(newSession);
    } else {
      (existing as Session).refTracker = newSession.refTracker;
    }
    _bulkPushObjects(objectsToPush);
  }

  static void _updateRefTracker(Map<String, Set<String>> refTracker, Set<CoreObject> objects) {
    final Set<Map<String, dynamic>> documents = objects.map((element) => element.toJson()).toSet();
    // Process each document to update the tracker.
    for (final Map<String, dynamic>doc in documents) {
      final String docId = doc['id'] as String;
      // Extract the set of referenced IDs from the document.
      final Set<String> currentRefs = _thisDocumentReferences(doc, docId);
      // Remove stale references:
      // For each key in the tracker, if the doc's id is present but the key is no longer referenced in the doc, remove it.
      for (final String key in refTracker.keys.toList()) {
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
  }

  static void _updatePrincipalDependantLinkTracker(Map<PrincipalId, Set<DependantId>> linkTracker, Set<CoreObject> objects) {
    for (CoreObject coreObject in objects) {
      if (coreObject is Dependant) {
        Dependant dependant = coreObject as Dependant;
        if (linkTracker.containsKey(dependant.principalPar)) {
          linkTracker[dependant.principalPar]?.add(coreObject.id);
        } else {
          linkTracker[dependant.principalPar] = {coreObject.id};
        }
      }
    }
  }

  static Set<String> _thisDocumentReferences(Map<String, dynamic> document, String thisDocId) {
    Set<String> output = _collectReferences(document.values.toList());
    output.remove(thisDocId);
    return output;
  }

  static Set<String> _collectReferences(dynamic item) {
    Set<String> referencedIds = {};

    // Base case: if the item itself is a valid reference
    if (item is String && CoreIdValidation.isPotentialId(item)) {
      referencedIds.add(item);
    } else if (item is List) {
      // Recursively process each element in the list
      for (var element in item) {
        referencedIds.addAll(_collectReferences(element));
      }
    } else if (item is Map) {
      // Recursively check both keys and values at deeper levels
      for (var entry in item.entries) {
        // Only check values at the root level, but both keys and values in nested maps
        referencedIds.addAll(_collectReferences(entry.key));
        referencedIds.addAll(_collectReferences(entry.value));
      }
    }

    return referencedIds;
  }
}
