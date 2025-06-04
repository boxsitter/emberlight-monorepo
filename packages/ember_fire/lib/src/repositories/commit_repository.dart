import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ember_core/ember_core_debug.dart';
import 'package:ember_core/ember_core_models.dart';
import 'package:ember_core/ember_core_services.dart';
import 'package:ember_core/ember_core_utils.dart';
import 'package:ember_core/ember_core_validators.dart';
import 'package:ember_fire/src/repositories/pull_repository.dart';
import 'package:ember_fire/src/services/database_repair_service.dart';
import 'package:get/get.dart';


import '../services/path_service.dart';

class CommitRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final PullRepository pullRepo = Get.find<PullRepository>();
  final ContextService clientContextService = Get.find<ContextService>();
  final PathService pathService = Get.find<PathService>();
  CommitService requestService = Get.find<CommitService>();

  get db => _db;

  /// Efficiently applies create/update (push) and delete operations to Firestore
  /// using batched writes, processing directly from the input Sets.
  ///
  /// Args:
  ///   objectsToPush: A Set of CoreObject instances to be created or updated (merged).
  ///   objectsToDelete: A Set of CoreObject instances whose corresponding documents should be deleted.
  ///
  /// Throws:
  ///   Exception if any underlying Firestore batch commit fails.
  Future<void> _bulkApplyChanges({
    required Set<CoreObject> objectsToPush,
    required Set<CoreObject> objectsToDelete,
  }) async {
    if (objectsToPush.isEmpty && objectsToDelete.isEmpty) {
      Debug.logInfo('Bulk Apply: No objects to push or delete.');
      return;
    }

    Debug.logInfo('Bulk Apply: Starting. Processing ${objectsToPush.length} pushes and ${objectsToDelete.length} deletes.');

    // Use iterators to process both sets concurrently within batch limits
    final pushIterator = objectsToPush.iterator;
    final deleteIterator = objectsToDelete.iterator;

    // Flags to track if there are more items in each iterator
    bool hasMorePushes = pushIterator.moveNext();
    bool hasMoreDeletes = deleteIterator.moveNext();

    int batchesCommitted = 0;
    int totalOpsCommitted = 0;
    const int maxBatchSize = 500; // Firestore limit

    // Continue as long as there are items in either iterator
    while (hasMorePushes || hasMoreDeletes) {
      WriteBatch batch = _db.batch();
      int opsInCurrentBatch = 0;
      int pushesInBatch = 0;
      int deletesInBatch = 0;
      final batchNum = batchesCommitted + 1;

      // --- Add Push Operations (up to batch limit) ---
      while (hasMorePushes && opsInCurrentBatch < maxBatchSize) {
        final CoreObject currentPushObject = pushIterator.current;
        try {
          final String resolvedPath = await pathService.getDocPathFromId(currentPushObject.id);
          // Basic path validation
          if (!resolvedPath.contains('//') && resolvedPath.split('/').length % 2 == 0) {
            final docRef = _db.doc(resolvedPath);
            // Perform the required steps directly:
            Map<String, dynamic> document = currentPushObject.toJson();
            CoreHelperFunctions.updateDocumentTimestamp(document);
            document = convertDatesToTimestamp(document);

            batch.set(docRef, document);
            opsInCurrentBatch++;
            pushesInBatch++;
          } else {
            Debug.logInfo('Warning (Batch #$batchNum): Skipping push object with empty ID.');
          }
        } catch (e) {
          Debug.logInfo('Error processing push for object ID "${currentPushObject.id}" in batch #$batchNum: $e. Skipping.');
        }
        // Move to the next push item
        hasMorePushes = pushIterator.moveNext();
      }

      // --- Add Delete Operations (up to batch limit) ---
      while (hasMoreDeletes && opsInCurrentBatch < maxBatchSize) {
        final CoreObject currentDeleteObject = deleteIterator.current;
        try {
          final String resolvedPath = await pathService.getDocPathFromId(currentDeleteObject.id);
          // Basic path validation
          if (resolvedPath.isNotEmpty && !resolvedPath.contains('//') && resolvedPath.split('/').length % 2 == 0) {
            final docRef = _db.doc(resolvedPath);
            // Perform the delete step directly:
            batch.delete(docRef);
            opsInCurrentBatch++;
            deletesInBatch++;
          } else {
            Debug.logInfo('Warning (Batch #$batchNum): Invalid path "$resolvedPath" for delete object ID "$currentDeleteObject.id". Skipping.');
          }
        } catch (e) {
          Debug.logInfo('Error processing delete for object ID "${currentDeleteObject.id}" in batch #$batchNum: $e. Skipping.');
        }
        // Move to the next delete item
        hasMoreDeletes = deleteIterator.moveNext();
      }

      // --- Commit the current batch if it has operations ---
      if (opsInCurrentBatch > 0) {
        try {
          Debug.logInfo('Bulk Apply: Committing batch #$batchNum ($pushesInBatch pushes, $deletesInBatch deletes)...');
          await batch.commit();
          totalOpsCommitted += opsInCurrentBatch;
          batchesCommitted++;
          Debug.logInfo('Bulk Apply: Batch #$batchesCommitted committed successfully.');
        } catch (e) {
          Debug.logInfo('Error committing Firestore batch #$batchNum: $e');
          // Rethrow to signal failure. The loop will terminate.
          rethrow;
        }
      } else {
        Debug.logInfo('Bulk Apply: Batch #$batchNum contained no valid operations to commit.');
      }
    }
    Debug.logInfo('Bulk Apply: Finished. $totalOpsCommitted operations committed across $batchesCommitted batch(es).');
  }

  Future<bool> commit(Commit commit) async {
    DatabaseRepairService repairService = Get.find<DatabaseRepairService>();

    if (commit.objectsToPush.isEmpty && commit.objectsToDelete.isEmpty) {
      Debug.logInfo('Nothing to commit!');
      return false;
    }

    if (!await requestService.disarmCommit(commit)) {
      Debug.logInfo('Operation cannot proceed');
      return false;
    }

    // if the commit is intended to be merged rather than pushed, do that
    if (commit.merge && commit.objectsToPush.isNotEmpty) {
      final objectsToMerge = commit.objectsToPush.values.toSet();
      commit.objectsToPush.clear();
      await repairService.mergeObjectsWithDatabase(
        commit: commit,
        objects: objectsToMerge,
        prioritizeAFields: true,
        prioritizeAValues: true,
        overwriteWithEmptyAValues: false,
        aFieldsToIgnore: {'createdAt'},
      );
    }

    bool containsOnlyDomain = false;
    if (commit.objectsToPush.length == 1 && commit.objectsToDelete.length == 0) {
      for (CoreObject object in commit.objectsToPush.values) {
        if (object is Domain) {
          containsOnlyDomain = true;
        }
      }
    }

    // Don't update ref tracker if the commit only has a domain in it
    if (!containsOnlyDomain) {
      Set<CoreObject> ignore = {};
      Set<CoreObject> objectsToDeleteSnapshot = commit.objectsToDelete.values.toSet();
      for (CoreObject object in objectsToDeleteSnapshot) {
        await _cleanBeforeDelete(commit, object, ignore);
        ignore.add(object);
      }

      Session newSession = commit.getObjectOfType() ?? await clientContextService.session;
      await Future.wait([
        Future(() => _updateRefTracker(newSession.refTracker, commit.objectsToPush.values.toSet())),
        Future(() => _updatePrincipalDependentLinkTracker(newSession.principalDependentLinkTracker, commit.objectsToPush.values.toSet())),
      ]);
      commit.addObjectToPush(newSession);
    }

    await _bulkApplyChanges(objectsToPush: commit.objectsToPush.values.toSet(), objectsToDelete: commit.objectsToDelete.values.toSet());
    return true;
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

  static void _updatePrincipalDependentLinkTracker(Map<PrincipalId, Set<DependentId>> linkTracker, Set<CoreObject> objects) {
    for (CoreObject coreObject in objects) {
      if (coreObject is Dependent) {
        Dependent dependent = coreObject as Dependent;
        if (linkTracker.containsKey(dependent.principalPar)) {
          linkTracker[dependent.principalPar]?.add(coreObject.id);
        } else {
          linkTracker[dependent.principalPar] = {coreObject.id};
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

  Map<String, dynamic> convertDatesToTimestamp(Map<String, dynamic> data) {
    // Use .map().collect() to create a new map instead of modifying the original
    // while iterating, which is safer.
    final Map<String, dynamic> newData = data.map((key, value) {
      if (value is DateTime) {
        // Convert DateTime values to UTC Timestamp.
        return MapEntry(key, Timestamp.fromDate(value.toUtc()));
      } else if (value is Timestamp) {
        // Re-create Timestamp to enforce UTC.
        return MapEntry(key, Timestamp.fromDate(value.toDate().toUtc()));
      } else if (value is String) {
        // Parse string as date and convert to Timestamp.
        DateTime? parsed = DateTime.tryParse(value);
        if (parsed != null) {
          return MapEntry(key, Timestamp.fromDate(parsed.toUtc()));
        } else {
          // If not parsable as a date, return the original string
          return MapEntry(key, value);
        }
      } else if (value is Map<String, dynamic>) {
        // Recursively convert nested maps
        return MapEntry(key, convertDatesToTimestamp(value));
      } else if (value is List) {
        // Recursively convert items within the list
        return MapEntry(key, _convertListItems(value)); // Use helper for lists
      } else {
        // Return other types unchanged
        return MapEntry(key, value);
      }
    });
    return newData;
  }

// Helper function to process list items recursively
  List<dynamic> _convertListItems(List list) {
    return list.map((item) {
      if (item is DateTime) {
        return Timestamp.fromDate(item.toUtc());
      } else if (item is Timestamp) {
        return Timestamp.fromDate(item.toDate().toUtc());
      } else if (item is String) {
        DateTime? parsed = DateTime.tryParse(item);
        return parsed != null ? Timestamp.fromDate(parsed.toUtc()) : item;
      } else if (item is Map<String, dynamic>) {
        return convertDatesToTimestamp(item); // Recursive call for maps
      } else if (item is List) {
        return _convertListItems(item); // Recursive call for nested lists
      }
      return item; // Return other types unchanged
    }).toList(); // This correctly results in List<dynamic>
  }

  Future<void> _cleanBeforeDelete(Commit commit, CoreObject objectToDelete, Set<CoreObject> ignore) async {
    if (ignore.contains(objectToDelete)) {
      return;
    }

    if (objectToDelete is Domain) {
      commit.addObjectToDelete(objectToDelete);
      return;
    }

    // --- Modification starts here ---
    Set<String> componentIds = _getCmps(objectToDelete.toJson());
    List<Future<void>> deleteComponentFutures = [];

    for (String id in componentIds) {
      Future<void> processComponent() async {
        CoreObject? componentObject;
        try {
          componentObject = commit.getObject(id) ?? await pullRepo.getObject(id);

          if (componentObject != null) {
            await _cleanBeforeDelete(commit, componentObject, ignore);
          } else {
            Debug.logInfo('Warning: Could not find or fetch component object for ID $id during pre-delete cleaning.');
          }

        } catch (error) {
          print("Error processing component $id during pre-delete cleaning: $error");
        }
      }
      // Add the execution of the async closure to the list
      deleteComponentFutures.add(processComponent());
    }

    // Wait for all component cleaning operations to complete
    if (deleteComponentFutures.isNotEmpty) {
      await Future.wait(deleteComponentFutures);
    }

    Session session = commit.getObjectOfType() ?? await clientContextService.session;
    commit.addObjectToPush(session);
    Set<String>? objectsToPurgeIds = session.refTracker[objectToDelete.id];
    objectsToPurgeIds?.remove(objectToDelete.id); // I have no idea if it can end up in there but it's an easy check

    if (objectsToPurgeIds == null) {
      commit.addObjectToDelete(objectToDelete);
      return;
    }

    for (String id in objectsToPurgeIds) {
      if (!commit.objectsToDelete.containsKey(id) && id != objectToDelete.id) {
        CoreObject objectToPurge = commit.getObject(id) ?? await pullRepo.getObject(id);
        objectToPurge.purgeRef(objectToDelete.id);
        commit.addObjectToPush(objectToPurge);
      }
    }

    commit.addObjectToDelete(objectToDelete);
  }

  Set<String> _getCmps(Map<String, dynamic> json) {
    final Set<String> output = {};

    json.forEach((key, value) {
      final String lowerKey = key.toLowerCase();
      if (lowerKey.endsWith("cmp") || lowerKey.endsWith("cmps")) {
        if (value is String) {
          output.add(value);
        } else if (value is List) {
          for (var element in value) {
            if (element is String) {
              output.add(element);
            }
          }
        }
      }
    });

    return output;
  }
}

