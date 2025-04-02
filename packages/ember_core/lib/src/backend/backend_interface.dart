import 'package:ember_core/ember_core_models.dart';

typedef FromJson<T> = T Function(Map<String, dynamic> json);

abstract class BackendInterface {
  String get backendName;
  String get backendDescription;

  Future<void> init();
  Future<T> getFieldValue<T>(String ref, String field);
  Future<Set<T>> getSetFieldValue<T>(String ref, String field);
  Future<T> getObject<T>(String ref, FromJson<T> fromJson);
  Future<Set<T>> getObjects<T>(Set<String> ref, FromJson<T> fromJson);
  Future<Set<T>> getObjectsInCollection<T>(String collectionName, String domain, FromJson<T> fromJson);
  Future<String?> queryField<T>(String collectionName, String domain, String field, T value);
  Future<void> commit(PushRequest pushRequest);
  Future<void> deleteObject(String key);
  Stream<Map<String, Child>> watchDocWithChildDocs<Parent, Child>();
}
