import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ember_core/ember_core_models.dart';


import '../services/path_service.dart';

class DumbPushRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  get db => _db;

  // Don't use this unless debugging or database repair
  Future<void> dumbPush(String path, CoreObject object) async {
    try {
      await FirebaseFirestore.instance.doc(path).set(object.toJson());
      print('Document pushed successfully to $path');
    } catch (e) {
      print('Error pushing document: $e');
    }
  }
}
