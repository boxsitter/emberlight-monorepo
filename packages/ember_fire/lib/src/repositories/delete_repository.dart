import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ember_core/ember_core_models.dart';
import 'package:ember_core/ember_core_services.dart';
import 'package:ember_fire/src/repositories/push_repository.dart';
import 'package:get/get.dart';

import '../services/path_service.dart';

class DeleteRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  late final ClientContextService clientContextService;
  final PathService pathService = Get.find<PathService>();
  final PushRepository pushRepo = Get.find<PushRepository>();
  RequestService requestService = Get.find<RequestService>();

  get db => _db;

  /// Simply deletes a document, does not perform cleanup.
  // ignore: unused_element
  Future<void> _deleteDocument(String id) async {
    final resolvedPath = pathService.getDocPathFromId(id);
    try {
      print('Deleting doc: $id');
      await _db.doc(resolvedPath).delete();
    } catch (e) {
      print('Error deleting document at $resolvedPath: $e');
      rethrow;
    }
  }

  // Future<void> commit(DeleteRequest deleteRequest) async{
  //   Set<CoreObject> objectsToDelete = deleteRequest.objectsToDelete.values.toSet();
  //
  //   if (objectsToDelete.isEmpty) {
  //     print('Nothing to commit!');
  //     return;
  //   }
  //
  //   if (!await requestService.disarmRequest(pushRequest)) {
  //   print('Operation cannot proceed');
  //   return;
  //   }
  //
  //   Session newSession = pushRequest.getObjectOfType() ?? await pullRepo.getObject(clientContextService.sessionId);
  //   await Future.wait([
  //   Future(() => _updateRefTracker(newSession.refTracker, objectsToPush)),
  //   Future(() => _updatePrincipalDependentLinkTracker(newSession.principalDependentLinkTracker, objectsToPush)),
  //   ]);
  //
  //
  // }



}
