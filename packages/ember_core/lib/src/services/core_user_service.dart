import 'package:get/get.dart';

import '../../ember_core_models.dart';
import '../../ember_core_services.dart';
import '../models/core_objects/coreUser.dart';

class UserService extends GetxService {
  Future<void> registerCoreUser({
    required Commit commit,
    required String firstName,
    required String lastName,
    String? preferredName = '',
    String note = '',
    required BranchId branchPar,
    required OrganizationId organizationRef,
    required Role role,
  }) async {
    CoreUser userToRegister = CoreUser(
      firstName: firstName,
      lastName: lastName,
      preferredName: preferredName,
      note: note,
      branchPar: branchPar,
      organizationRef: organizationRef,
      role: role,
    );
    commit.addObjectToPush(userToRegister);
  }
}