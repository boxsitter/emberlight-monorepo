import 'package:bessie/common/services/client_context_service.dart';
import 'package:bessie/common/utils/helpers/bess_id_functions.dart';
import 'package:bessie/common/utils/validators/bess_id_validation.dart';
import 'package:get/get.dart';

import '../../data/helper_objects/delete_request.dart';

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