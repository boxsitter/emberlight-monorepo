library;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ember_core/ember_core_backend.dart';
import 'package:ember_core/ember_core_debug.dart';
import 'package:ember_core/ember_core_models.dart';
import 'package:ember_fire/src/repositories/authentication_repository.dart';
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
  late final AuthenticationRepository authenticationRepo;

  EmberFire();

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
    authenticationRepo = Get.put(AuthenticationRepository(), permanent: true);
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

  // Auth

  @override
  bool isAuthenticated() {
    return authenticationRepo.isUserLoggedIn;
  }

  @override
  Future<void> login(String email, String password, bool rememberMe) async {
    await authenticationRepo.loginWithEmailAndPassword(email, password, rememberMe);
  }

}

class FireStarter {
  static bool _isInitialized = false; // Simple flag to track initialization

  static Future<void> initialize() async {
    // Prevent multiple initializations
    if (_isInitialized) {
      print('Firebase already initialized.');
      return;
    }

    try {
      print('Initializing Firebase...');
      // Ensure WidgetsFlutterBinding is initialized BEFORE Firebase.initializeApp
      // This is usually done in main(), but adding here for safety if called elsewhere.
      // WidgetsFlutterBinding.ensureInitialized(); // Uncomment if needed, but best practice is in main()

      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      _isInitialized = true; // Mark as initialized SUCCESSFULLY
      print('Firebase initialized successfully.');

      // --- Firestore specific setup ---
      final db = FirebaseFirestore.instance;

      // Firestore Emulator Setup (Consider platform differences)
      // Emulator is typically not used in production or web deployment.
      // `kIsWeb` helps differentiate web builds.
      if (Debug.useFirestoreEmulator) {
        try {
          print("Attempting to use Firestore Emulator...");
          // Ensure host is correct, especially if not running locally (e.g., Docker)
          db.useFirestoreEmulator('localhost', 6200);
          print("Using Firestore Emulator.");
        } catch (e) {
          print("WARNING: Failed to connect to Firestore emulator at localhost:6200. "
              "Ensure it's running. Falling back to cloud Firestore. Error: $e");
          // Decide if this error should prevent app startup or just log a warning.
        }
      }

      // Persistence Settings (Can have browser limitations)
      // Consider enabling only if needed and test cross-browser compatibility.
      // if (kIsWeb) {
      //   try {
      //     await db.enablePersistence(
      //       const PersistenceSettings(synchronizeTabs: true),
      //     );
      //     print('Firestore persistence with tab synchronization enabled (Web).');
      //   } catch (e) {
      //     print('Firestore Web Persistence failed: $e');
      //   }
      // } else {
      //    // Mobile persistence settings if needed
      //    // db.settings = const Settings(persistenceEnabled: true, cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED);
      //    print('Firestore persistence enabled (Mobile).');
      // }
      // --- End Firestore specific setup ---

    } catch (e) {
      print('-----------------------------------------');
      print('FATAL: Error initializing Firebase: $e');
      print('-----------------------------------------');
      // Depending on your app, you might want to rethrow the error
      // or show a user-friendly error message and prevent app continuation.
      _isInitialized = false; // Ensure it's marked as not initialized on failure
      rethrow; // Rethrow to indicate critical failure
    }
  }

  // Optional: Getter to check status from outside
  static bool get isInitialized => _isInitialized;
}
