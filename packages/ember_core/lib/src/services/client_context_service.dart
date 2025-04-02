import 'package:ember_core/ember_core_models.dart';
import 'package:ember_core/user_houck_leyton.dart';
import 'package:get/get.dart';

import '../../ember_core_backend.dart';


class ClientContext {
  late String organizationId;
  late String branchId;
  late String seasonId;
  late String sessionId;
}

class ClientContextService extends GetxService {
  static BackendInterface backend = BackendManager.instance;
  final ClientContext clientContext = Get.find<ClientContext>();

  get organizationId => clientContext.organizationId;
  get branchId => clientContext.branchId;
  get seasonId => clientContext.seasonId;
  get sessionId => clientContext.sessionId;

  Future<Session> get session async => await backend.getObject(sessionId, Session.fromJson);
  Future<Schedule> get schedule async => await backend.getObject(await backend.getFieldValue(sessionId, 'scheduleId'), Schedule.fromJson);

  @override
  void onInit() {
    super.onInit();
    setDefaultContext();
  }

  // TODO: This is sketchy rn. I will still need to implement robust checks for no assigned orgs/branches and no current or existing seasons or sessions
  Future<void> setDefaultContext() async {
    clientContext.organizationId = User.organizationId;
    clientContext.branchId = User.branchId;

    // Retrieve the unique active Season.
    clientContext.seasonId = await backend.getActiveObjectId('season', "brn");

    // Retrieve the unique active Session.
    clientContext.sessionId = await backend.getActiveObjectId('session', "sea");
  }
}