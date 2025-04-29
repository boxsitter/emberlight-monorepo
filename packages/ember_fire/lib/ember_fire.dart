library;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ember_core/ember_core_backend.dart';
import 'package:ember_core/ember_core_models.dart';
import 'package:ember_fire/src/repositories/dumb_push_repository.dart';
import 'package:ember_fire/src/repositories/live_data_repository.dart';
import 'package:ember_fire/src/repositories/pull_repository.dart';
import 'package:ember_fire/src/repositories/commit_repository.dart';
import 'package:ember_fire/src/services/database_repair_service.dart';
import 'package:ember_fire/src/services/path_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';

import 'firebase_options.dart';

const _backendName = 'EmberFire';
const _backendDescription = 'Firebase backend for EmberCore.';

class EmberFire implements CoreBackend {
  late final PullRepository pullRepo;
  late final CommitRepository commitRepo;
  late final LiveDataRepository liveDataRepo;
  late final DatabaseRepairService databaseRepairService;

  final bool isReleaseMode;

  EmberFire({this.isReleaseMode = false});

  @override
  void init() {
    Get.put(DumbPushRepository(), permanent: true);
    Get.put(PathService(), permanent: true);
    pullRepo = Get.put(PullRepository(), permanent: true);
    liveDataRepo = Get.put(LiveDataRepository(), permanent: true);
    databaseRepairService = Get.put(DatabaseRepairService(), permanent: true);
  }

  @override
  void initLate() {
    commitRepo = Get.put(CommitRepository(), permanent: true);
  }

  @override
  // TODO: implement backendName
  String get backendName => _backendName;

  @override
  String get backendDescription => _backendDescription;

  @override
  Future<void> commit(Commit request) async {
    commitRepo.commit(request);
  }

  @override
  Future<void> deleteObject(String key) async {
    //deleteRepo.deleteObject(key);
    throw UnimplementedError();
  }

  @override
  Future<T> getFieldValue<T>(String ref, String field) {
    return pullRepo.getFieldValue(ref, field);
  }

  @override
  Future<T> getObject<T>(String ref) {
    return pullRepo.getObject(ref);
  }

  @override
  Future<Set<T>> getObjects<T>(Set<String> ref) {
    return pullRepo.getObjects(ref);
  }

  @override
  Future<Set<T>> getObjectsInCollection<T>(String collectionName, String domain) {
    return pullRepo.getObjectsInCollection(collectionName, domain);
  }

  @override
  Future<Set<T>> getSetFieldValue<T>(String ref, String field) {
    return pullRepo.getSetFieldValue(ref, field);
  }

  @override
  Future<String?> queryField<T>(String collectionName, String domain, String field, T value) {
    return pullRepo.queryField(collectionName, domain, field, value);
  }

  @override
  Future<Stream<Map<String, T>>> watchCollection<T>({
    required String collectionName,
    required String domain,
    bool updateDataInRealtime = true,
  }) {
    return liveDataRepo.watchCollection(
      collectionName: collectionName,
      domain: domain,
      updateDataInRealtime: updateDataInRealtime,
    );
  }

  @override
  Future<String> getActiveObjectId(String collectionName, String domain) {
    return pullRepo.getActiveObjectId(collectionName, domain);
  }

  @override
  Future<void> mergeObjectsWithDatabase({required Commit commit, required Set<CoreObject> objects, required bool prioritizeAFields, required bool prioritizeAValues, required bool overwriteWithEmptyAValues, Set<String>? aFieldsToIgnore}) async {
    await databaseRepairService.mergeObjectsWithDatabase(commit: commit, objects: objects, prioritizeAFields: prioritizeAFields, prioritizeAValues: prioritizeAValues, overwriteWithEmptyAValues: overwriteWithEmptyAValues);
  }

  @override
  Future<void> dumbDomainSetup (Organization org, Branch branch, Season season, Session session) async {
    await databaseRepairService.dumbDomainSetup(org, branch, season, session);
  }

  @override
  Future<Map<String, dynamic>> getFieldFromCollection(String collectionName, String domain, String field) {
    return pullRepo.getFieldFromCollection(collectionName, domain, field);
  }

  @override
  Future<void> cleanOrphanedDependents(Commit commit, Session session) {
    return databaseRepairService.cleanOrphanedDependents(commit, session);
  }

}

class FirebaseStarter {
  static bool _didInit = false;

  static Future<void> initCritical({required bool isReleaseMode}) async {
    if (Firebase.apps.isNotEmpty) {
      print('skipping firebase initialization');
      return;
    }
    print('initializing firebase');
    _didInit = true;

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    final db = FirebaseFirestore.instance;
    try {
      await db.enablePersistence(
        const PersistenceSettings(synchronizeTabs: true),
      );
    } catch (e) {
      print('Persistence failed: $e');
    }
    db.settings = const Settings(persistenceEnabled: true);

    if (isReleaseMode) {
      print("Using Remote Firestore Database");
    } else {
      db.useFirestoreEmulator('localhost', 8080);
      print("Using Firestore Emulator");
    }
  }
}
