import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:rxdart/rxdart.dart';

import '../../common/utils/helpers/bess_id_functions.dart';
import 'push_repository.dart';

/// A generic repository for live-updating Firestore data.
class LiveDataRepository {
  PushRepository bessObjectRepo = Get.find<PushRepository>();
  final FirebaseFirestore _db = Get.find<PushRepository>().db;

  get pathService => null;

  /// Watches a single Firestore document by [id].
  /// Parses it into [T] via [fromJson]. If the doc doesn't exist, emits `null`.
  Stream<T?> watchDoc<T>({required String id, required T Function(Map<String, dynamic> json) fromJson,}) {
    final resolvedPath = pathService.getDocPathFromId(id);
    return _db.doc(resolvedPath).snapshots().map((snapshot) {
      if (!snapshot.exists) return null;
      final data = snapshot.data() as Map<String, dynamic>;
      return fromJson(data);
    });
  }

  /// Watches a parent document at [parentId] that has a field [childIdField]
  /// containing a list (or set) of child IDs (Strings).
  ///
  /// For each child ID, we subscribe to its document [childDocPathBuilder(childId)]
  /// and parse it into [Child] with [childFromJson].
  ///
  /// Whenever the parent’s set of child IDs changes, the subscription set
  /// is automatically updated. Emitted values are a Map of childId -> Child,
  /// excluding any child docs that don't exist (or are null).
  Stream<Map<String, Child>> watchDocWithChildDocs<Parent, Child>({
    required String parentId,
    required Parent Function(Map<String, dynamic> json) parentFromJson,
    required String childIdField,
    bool updateChildrenRealtime = true,
    Child Function(Map<String, dynamic> json)? childFromJson,
  }) {
    assert(
    !updateChildrenRealtime || childFromJson != null,
    'childFromJson is required if updateChildrenRealtime is true.',
    );

    final resolvedParentPath = pathService.getPath(parentId, false);

    return _db.doc(resolvedParentPath).snapshots().switchMap((snapshot) {
      if (!snapshot.exists) {
        return Stream.value(<String, Child>{});
      }

      final data = snapshot.data() ?? {};
      final childIds = (data[childIdField] as List?)?.cast<String>() ?? [];

      if (childIds.isEmpty) {
        return Stream.value(<String, Child>{});
      }

      if (updateChildrenRealtime) {
        // Real-time updates for each child
        final childStreams = childIds.map((childId) {
          return watchDoc<Child>(
            id: childId,
            fromJson: childFromJson!,
          ).map((childObj) => MapEntry(childId, childObj));
        });

        return CombineLatestStream.list(childStreams).map((entries) {
          final result = <String, Child>{};
          for (final entry in entries) {
            if (entry.value != null) {
              result[entry.key] = entry.value as Child;
            }
          }
          return result;
        });
      } else {
        // One-time fetch without real-time updates
        return Future.wait(
          childIds.map((childId) async {
            final resolvedChildPath = pathService.getPath(childId, false);
            final doc = await _db.doc(resolvedChildPath).get();
            final childData = doc.exists ? doc.data() : null;
            return MapEntry(
              childId,
              (childData != null && childFromJson != null)
                  ? childFromJson(childData)
                  : null,
            );
          }),
        ).asStream().map((entries) {
          final result = <String, Child>{};
          for (final entry in entries) {
            if (entry.value != null) {
              result[entry.key] = entry.value as Child;
            }
          }
          return result;
        });
      }
    });
  }
}
