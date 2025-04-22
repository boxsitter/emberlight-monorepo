import 'package:ember_core/ember_core_models.dart';
import 'package:get/get.dart';

import '../../ember_core_backend.dart';

class FrontendCommitService extends GetxService {
  BackendInterface backend = BackendManager.instance;

  void commitRequest(Commit commit) {
    backend.commit(commit);
  }
}