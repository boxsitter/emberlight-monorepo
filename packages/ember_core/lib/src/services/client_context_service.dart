import 'package:bessie/data/bess_objects/schedule/schedule.dart';
import 'package:bessie/data/repositories/pull_repository.dart';
import 'package:get/get.dart';

import '../../data/bess_objects/domains/season.dart';
import '../../data/bess_objects/domains/session.dart';
import '../../data/user_houck_leyton.dart';

class ClientContext {
  late String organizationId;
  late String branchId;
  late String seasonId;
  late String sessionId;
}

class ClientContextService extends GetxService {
  final PullRepository pullRepo = Get.find<PullRepository>();
  final ClientContext clientContext = Get.find<ClientContext>();

  get organizationId => clientContext.organizationId;
  get branchId => clientContext.branchId;
  get seasonId => clientContext.seasonId;
  get sessionId => clientContext.sessionId;

  Future<Session> get session async => await pullRepo.getObject(sessionId, Session.fromJson);
  Future<Schedule> get schedule async => await pullRepo.getObject(await pullRepo.getFieldValue(sessionId, 'scheduleId'), Schedule.fromJson);

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
    clientContext.seasonId = await pullRepo.getActiveObjectId('season', "brn");

    // Retrieve the unique active Session.
    clientContext.sessionId = await pullRepo.getActiveObjectId('session', "sea");
  }
}