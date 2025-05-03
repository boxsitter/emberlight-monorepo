import 'package:ember_core/ember_core_models.dart';
import 'package:get/get.dart';

import '../../ember_core_backend.dart';

class FrontendCommitService extends GetxService {
  CoreBackend backend = BackendManager.instance;

  Future<void> commit(Commit commit) async {
    await backend.commit(commit);
  }
}