library;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ember_core/ember_core_backend.dart';
import 'package:ember_core/ember_core_models.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';

const _backendName = 'EmberFire';
const _backendDescription = 'Firebase backend for EmberCore.';

class EmberFire implements BackendInterface {

  final bool isReleaseMode;

  EmberFire({this.isReleaseMode = false});

  @override
  Future<void> init() async {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    if (isReleaseMode) {
      print("Using Remote Firestore Database");
    } else {
      FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
      print("Using Firestore Emulator");
    }
  }

  @override
  String get backendDescription => _backendName;

  @override
  // TODO: implement backendName
  String get backendName => _backendDescription;

  @override
  Future<void> commit(PushRequest pushRequest) async {
    commit(pushRequest);
  }

  @override
  Future<void> deleteObject(String key) async {
    deleteObject(key);
  }

  @override
  Future<T> getFieldValue<T>(String ref, String field) {
    return getFieldValue(ref, field);
  }

  @override
  Future<T> getObject<T>(String ref) {
    return getObject(ref);
  }

  @override
  Future<Set<T>> getObjects<T>(Set<String> ref) {
    return getObjects(ref);
  }

  @override
  Future<Set<T>> getObjectsInCollection<T>(String collectionName, String domain) {
    return getObjectsInCollection(collectionName, domain);
  }

  @override
  Future<Set<T>> getSetFieldValue<T>(String ref, String field) {
    return getSetFieldValue(ref, field);
  }

  @override
  Future<String?> queryField<T>(String collectionName, String domain, String field, T value) {
    return queryField(collectionName, domain, field, value);
  }

  @override
  Stream<Map<String, Child>> watchDocWithChildDocs<Parent, Child>() {
    return watchDocWithChildDocs();
  }

  @override
  Future<String> getActiveObjectId(String collectionName, String domain) {
    return getActiveObjectId(collectionName, domain);
  }

  @override
  Future<PushRequest> mergeObjectsWithDatabase({required Set<CoreObject> objects, required bool prioritizeAFields, required bool prioritizeAValues, required bool overwriteWithEmptyAValues, Set<String>? aFieldsToIgnore}) {
    return mergeObjectsWithDatabase(objects: objects, prioritizeAFields: prioritizeAFields, prioritizeAValues: prioritizeAValues, overwriteWithEmptyAValues: overwriteWithEmptyAValues);
  }

}
