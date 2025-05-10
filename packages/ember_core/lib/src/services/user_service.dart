import 'package:get/get.dart';

import '../../ember_core.dart';
import '../../ember_core_backend.dart';
import '../../ember_core_frontend.dart';
import '../../ember_core_models.dart';
import '../../ember_core_services.dart';

class UserService extends GetxService {
  static CoreBackend backend = BackendManager.instance;

  bool get isAuthenticated => backend.isAuthenticated();

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
    userToRegister.active = false;
    userToRegister.deactivationReason = 'Your account is pending approval'; // TODO: remove this in favor of camp codes
    commit.addObjectToPush(userToRegister);
  }

  Future<bool> login(String email, String password, bool rememberMe) async {
    await backend.login(email, password, rememberMe);
    if (isAuthenticated) {
      FrontendManager.instance.onLogin();
      BackendManager.instance.onLogin();
      EmberCore.onLogin();
    }
    return isAuthenticated;
  }
}