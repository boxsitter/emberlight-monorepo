import 'package:bessie/common/services/client_context_service.dart';
import 'package:bessie/common/utils/helpers/bess_id_functions.dart';
import 'package:bessie/data/abstract/bess_object.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../common/services/path_service.dart';

class DeleteRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  late final ClientContextService clientContextService;
  final PathService pathService = Get.find<PathService>();

  get db => _db;

  /// Simply deletes a document, does not perform cleanup.
  Future<void> deleteDocument(String id) async {
    final resolvedPath = pathService.getDocPathFromId(id);
    try {
      print('Deleting doc: $id');
      await _db.doc(resolvedPath).delete();
    } catch (e) {
      print('Error deleting document at $resolvedPath: $e');
      rethrow;
    }
  }
  
  Future<void> deleteDomain() {
    return Future(() => print('unimplemented'));
    // Much easier process, just delete the domain document.
    // Since references are contained to within domains, there is nothing to clean up
    // Still, stringent checks are necessary to make sure this isn't done by mistake
  }
  
  // /// Removes all instances of [referenceIdToRemove] from any array fields in the [parentId] document.
  // Future<Map<String, dynamic>> _purgeReferencesTo(Future<Map<String, dynamic>?> document, String referenceIdToRemove) async {
  //   bool modified = false;
  //   final fieldUpdates = <String, dynamic>{};
  //
  //   for (final entry in document.entries) {
  //     final key = entry.key;
  //     final value = entry.value;
  //
  //     // Remove string fields where value is exactly the ID
  //     if (value is String && value == referenceIdToRemove) {
  //       fieldUpdates[key] = FieldValue.delete();
  //       modified = true;
  //     }
  //
  //     // Remove from lists
  //     else if (value is List && value.contains(referenceIdToRemove)) {
  //       await _removeIdFromCollection(parentId, key, referenceIdToRemove);
  //       modified = true;
  //     }
  //
  //     // Remove from maps
  //     else if (value is Map) {
  //       final map = Map<String, dynamic>.from(value);
  //       final matches = map.entries.any(
  //             (entry) => entry.key == referenceIdToRemove || entry.value == referenceIdToRemove,
  //       );
  //       if (matches) {
  //         await _removeIdFromCollection(parentId, key, referenceIdToRemove);
  //         modified = true;
  //       }
  //     }
  //   }
  //
  //   // Apply single-field deletes (like top-level String fields)
  //   if (fieldUpdates.isNotEmpty) {
  //     fieldUpdates['updatedAt'] = DateTime.now().toUtc();
  //     await _db.doc(resolvedPath).update(fieldUpdates);
  //   }
  //
  //   if (!modified) {
  //     print('No references to $referenceIdToRemove found in $parentId.');
  //   }
  // }


}
