import 'package:ember_core/ember_core_models.dart';
import 'package:get/get.dart';

class DeletionService extends GetxService {
  Future<DeleteRequest> deleteObject(BessObject objectToDelete) {
    //get chain of components

    //get a set of all references to those components

    // TODO: don't forget to update the reference tracker

    // TODO: handle master objects
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