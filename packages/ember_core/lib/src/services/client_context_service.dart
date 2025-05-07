import 'dart:async';

import 'package:ember_core/ember_core_models.dart';
import 'package:ember_core/user_houck_leyton.dart';
import 'package:get/get.dart';

import '../../ember_core_backend.dart';
import '../backend/backend_manager.dart';

typedef OrganizationId = String;
typedef BranchId = String;
typedef SeasonId = String;
typedef SessionId = String;

class ClientContext extends GetxService {
  final Completer<OrganizationId> _orgCompleter = Completer();
  final Completer<BranchId> _branchCompleter = Completer();
  final Completer<SeasonId> _seasonCompleter = Completer();
  final Completer<SessionId> _sessionCompleter = Completer();

  Future<OrganizationId> getOrganizationId() => _orgCompleter.future;
  Future<BranchId> getBranchId() => _branchCompleter.future;
  Future<SeasonId> getSeasonId() => _seasonCompleter.future;
  Future<SessionId> getSessionId() => _sessionCompleter.future;

  set organizationId(OrganizationId id) {
    if (!_orgCompleter.isCompleted) {
      _orgCompleter.complete(id);
    }
  }

  set branchId(BranchId id) {
    if (!_branchCompleter.isCompleted) {
      _branchCompleter.complete(id);
    }
  }

  set seasonId(SeasonId id) {
    if (!_seasonCompleter.isCompleted) {
      _seasonCompleter.complete(id);
    }
  }

  set sessionId(SessionId id) {
    if (!_sessionCompleter.isCompleted) {
      _sessionCompleter.complete(id);
    }
  }
}

class ClientContextService extends GetxService {
  static CoreBackend backend = BackendManager.instance;
  final ClientContext clientContext = Get.find<ClientContext>();

  Future<Session> get session async => backend.getObject(await clientContext.getSessionId());
  Future<Schedule> get schedule async => (await backend.getObjectsInCollection('schedule', 'ses')).first as Schedule;

  // TODO: This is sketchy rn. I will still need to implement robust checks for no assigned orgs/branches and no current or existing seasons or sessions
  Future<void> setDefaultContext() async {
    clientContext.organizationId = TestUser.organizationId;
    clientContext.branchId = TestUser.branchId;

    // Retrieve the unique active Season.
    clientContext.seasonId = await backend.getActiveObjectId('season', 'brn');

    // Retrieve the unique active Session.
    clientContext.sessionId = await backend.getActiveObjectId('session', 'sea');
    asyncTasks();
  }

  Future<void> asyncTasks() async {
    Commit commit = Commit(disarmRequirementsLevel: 0);
    backend.cleanOrphanedDependents(commit, await session);
    commit
        .disarm(); // not good practice but this operation needs to happen regardless if the user confirms or not since it is an extension of an already confirmed action
    backend.commit(commit);
  }
}
