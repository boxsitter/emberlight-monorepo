import 'package:ember_core/ember_core_models.dart';
import 'package:ember_core/user_houck_leyton.dart';
import 'package:get/get.dart';

import '../../ember_core_backend.dart';
import '../models/core_objects/domain/session.dart';


class ClientContext extends GetxService {
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

  Future<Session> get session async => await backend.getObject(sessionId);
  Future<Schedule> get schedule async => (await backend.getObjectsInCollection('schedule', 'ses')).first as Schedule;

  // TODO: This is sketchy rn. I will still need to implement robust checks for no assigned orgs/branches and no current or existing seasons or sessions
  Future<void> setDefaultContext() async {
    clientContext.organizationId = User.organizationId;
    clientContext.branchId = User.branchId;

    // Retrieve the unique active Season.
    clientContext.seasonId = await backend.getActiveObjectId('season', 'brn');

    // Retrieve the unique active Session.
    clientContext.sessionId = await backend.getActiveObjectId('session', 'sea');

    asyncTasks();
  }

  Future<void> asyncTasks() async {
    Commit commit = Commit(disarmRequirementsLevel: 0);
    backend.cleanOrphanedDependents(commit, await session);
    commit.disarm(); // not good practice but this operation needs to happen regardless if the user confirms or not since it is an extension of an already confirmed action
    backend.commit(commit);
  }
}