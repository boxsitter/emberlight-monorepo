import 'package:ember_core/src/hardcode/hardcoded_domains.dart';
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
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? preferredName = '',
    String note = '',
    required Role role,
  }) async {
    String firebaseUid = await backend.registerWithEmailAndPassword(email: email, password: password);

    CoreUser userToRegister = CoreUser(
      firebaseUid: firebaseUid,
      firstName: firstName,
      lastName: lastName,
      preferredName: preferredName,
      note: note,
      // branchRef: HardcodedDomains.colman.id,
      // organizationRef: HardcodedDomains.ygs.id,
      role: role,
    );
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

  Future<void> logout() async {
    await backend.logout();
  }

  Future<CoreUser> getCurrentUser() async {
    String? firebaseUid = backend.getCurrentUid();
    if (firebaseUid == null) {
      throw Exception('User not logged in');
    }
    String? userId = await backend.queryField('core_user', 'rot', 'firebaseUid', firebaseUid);
    print(userId);
    if (userId == null) {
      throw Exception('User does not have a CoreUser object associated with their firebase credentials');
    }
    CoreUser user = await backend.getObject(userId);
    return user;
  }
}