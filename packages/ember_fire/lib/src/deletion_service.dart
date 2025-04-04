import 'package:ember_core/ember_core_models.dart';
import 'package:get/get.dart';

class DeletionService extends GetxService {
  Future<DeleteRequest> deleteObject(BessObject objectToDelete) {
    //get chain of components
    Set<Map<String, dynamic>> objectsToDeleteJsons = {objectToDelete.toJson()};
    int preOpLength = 1;
    int postOpLength = 0;
    Set<Map<String, dynamic>> lastLoopSet = objectsToDeleteJsons;
    while (preOpLength != postOpLength) {
      preOpLength = objectsToDeleteJsons.length;
      Set<String> idsFound = {};
      for (Map<String, dynamic> json in lastLoopSet) {
        idsFound.addAll(getCmps(json));
      }
      // TODO: pull all cmps from database as jsons, add them, run again
    }

    //get a set of all references to those components
    // TODO: remove the set of objects to be deleted from references to purge, it would be unnecessary calls

    // TODO: don't forget to update the reference tracker

    // TODO: handle master objects
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


  Future<DeleteRequest> deletePrincipalObject(BessObject objectToDelete) {
    //get chain of components

    //get a set of all references to those components

    // TODO: don't forget to update the reference tracker

    // TODO: handle master objects
  }

  Future<DeleteRequest> deleteDomain() {

    // Much easier process, just delete the domain document.
    // Since references are contained to within domains, there is nothing to clean up
    // Still, stringent checks are necessary to make sure this isn't done by mistake
  }

  Future<DeleteRequest> cleanDeletedMasterObjectClones() {

  }
}