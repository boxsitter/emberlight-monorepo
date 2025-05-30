import 'dart:async';

import 'package:ember_core/ember_core_models.dart';
import 'package:ember_core/src/hardcode/hardcoded_domains.dart';
import 'package:ember_core/user_houck_leyton.dart';
import 'package:get/get.dart';

import '../../ember_core.dart';
import '../../ember_core_backend.dart';
import '../../ember_core_frontend.dart';

typedef OrganizationId = String;
typedef BranchId = String;
typedef SeasonId = String;
typedef SessionId = String;

class ClientContext extends GetxService {
  // Replace Completers with simple, late-initialized fields
  late OrganizationId _organizationId;
  late BranchId _branchId;
  late SeasonId _seasonId;
  late SessionId _sessionId;

  // Provide simple getters
  OrganizationId get organizationId => _organizationId;
  BranchId get branchId => _branchId;
  SeasonId get seasonId => _seasonId;
  SessionId get sessionId => _sessionId;

  // Provide simple setters that allow overwriting the values
  set organizationId(OrganizationId id) => _organizationId = id;
  set branchId(BranchId id) => _branchId = id;
  set seasonId(SeasonId id) => _seasonId = id;
  set sessionId(SessionId id) => _sessionId = id;

  // For any services that relied on the Future, you can keep
  // these methods for compatibility. They now return an already-completed Future.
  Future<OrganizationId> getOrganizationId() => Future.value(_organizationId);
  Future<BranchId> getBranchId() => Future.value(_branchId);
  Future<SeasonId> getSeasonId() => Future.value(_seasonId);
  Future<SessionId> getSessionId() => Future.value(_sessionId);

  bool justMigrated = false;
}

class ContextService extends GetxService {
  static CoreBackend backend = BackendManager.instance;
  final ClientContext clientContext = Get.find<ClientContext>();

  Future<Session> get session async => backend.getObject(await clientContext.getSessionId());
  Future<Schedule> get schedule async => (await backend.getObjectsInCollection('schedule', 'ses')).first as Schedule;

  // TODO: This is sketchy rn. I will still need to implement robust checks for no assigned orgs/branches and no current or existing seasons or sessions
  Future<void> setDefaultContext() async {
    if (clientContext.justMigrated) {
      clientContext.justMigrated = false;
      return;
    }
    clientContext.organizationId = HardcodedDomains.ygs.id; // TODO: THIS NEEDS TO BE FIXED BEFORE ALLOWING MULTIPLE BRANCHES AND ORGS
    clientContext.branchId = HardcodedDomains.colman.id;

    // Retrieve the unique active Season.
    clientContext.seasonId = await backend.getActiveObjectId('season', 'brn');

    // Retrieve the unique active Session.
    clientContext.sessionId = await backend.getActiveObjectId('session', 'sea');
  }

  Future<void> migrateContext(SessionId sessionId) async {
    Session? session = await backend.getObject(sessionId);
    if (session != null) {
      clientContext.sessionId = sessionId;
    } else {
      throw StateError('Attempted to migrate to a context that doesn\'t exist');
    }
    clientContext.justMigrated = true;
    //Get.reset();
    // TODO: handle this manually. services should not need to be removed but controllers should. The whole deleting controllers marked as fenix was a good idea
    // TODO: clean up anything else manually
    FrontendManager.instance.onLogin();
    BackendManager.instance.onLogin();
    await EmberCore.onLogin();
    Get.offAllNamed('/');
  }

  Future<Map<String, String>> getSessionNames() async {
    final dynamicMap = await backend.getFieldFromCollection('session', 'sea', 'name');
    return dynamicMap.map((key, value) {
      return MapEntry(key, value.toString());
    });
  }
}
