import 'package:ember_core/ember_core_models.dart';
import 'package:ember_core/ember_core_services.dart';
import 'package:ember_fire/src/repositories/pull_repository.dart';
import 'package:get/get.dart';

class DeletionService extends GetxService {
  PullRepository pullRepo = Get.find<PullRepository>();
  ClientContextService clientContextService = Get.find<ClientContextService>();

  Future<void> deleteCoreObject(DeleteRequest deleteRequest, CoreObject objectToDelete) async {
    if (objectToDelete is Domain) {
      deleteRequest.addObjectToDelete(objectToDelete);
      return;
    }

    Set<String> componentIds = getCmps(objectToDelete.toJson());
    List<Future<void>> deleteComponentFutures = [];
    for (String id in componentIds) {
      deleteComponentFutures.add(
          pullRepo.getObject(id).then((componentObject) {
            return deleteCoreObject(deleteRequest, componentObject);
          }).catchError((error) {
            print("Error processing component $id: $error");
          })
      );
    }

    if (deleteComponentFutures.isNotEmpty) {
      await Future.wait(deleteComponentFutures);
    }

    Session session = deleteRequest.getObjectOfType() ?? await clientContextService.session;
    Set<String>? objectsToPurgeIds = session.refTracker[objectToDelete.id];
    objectsToPurgeIds?.remove(objectToDelete.id); // I have no idea if it can end up in there but it's an easy check

    if (objectsToPurgeIds == null) {
      deleteRequest.addObjectToDelete(objectToDelete);
      return;
    }

    for (String id in objectsToPurgeIds) {
      CoreObject objectToPurge = deleteRequest.getObject(id: id) ??
          await pullRepo.getObject(id);
      objectToPurge.purgeRef(objectToDelete.id);
      deleteRequest.addObjectToPurge(objectToPurge);
    }

    deleteRequest.addObjectToDelete(objectToDelete);
  }

  Set<String> getCmps(Map<String, dynamic> json) {
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