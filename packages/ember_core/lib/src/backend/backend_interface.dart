import 'package:ember_core/ember_core_models.dart';

typedef FromJson<T> = T Function(Map<String, dynamic> json);

abstract class BackendInterface {
  String get backendName;
  String get backendDescription;

  Future<void> init();
  Future<T> getFieldValue<T>(String ref, String field);
  Future<Set<T>> getSetFieldValue<T>(String ref, String field);
  Future<T> getObject<T>(String ref);
  Future<Set<T>> getObjects<T>(Set<String> ref);
  Future<Set<T>> getObjectsInCollection<T>(String collectionName, String domain);
  Future<String?> queryField<T>(String collectionName, String domain, String field, T value);
  Future<String> getActiveObjectId(String collectionName, String domain);
  Future<void> commit(PushRequest pushRequest);
  Future<void> deleteObject(String key);
  Stream<Map<String, Child>> watchDocWithChildDocs<Parent, Child>(); // TODO: watch collection instead
  Future<PushRequest> mergeObjectsWithDatabase({
    required Set<CoreObject> objects,
    required bool prioritizeAFields,
    required bool prioritizeAValues,
    required bool overwriteWithEmptyAValues,
    Set<String>? aFieldsToIgnore
  });
}
