import 'package:bessie/common/services/path_service.dart';
import 'package:get/get.dart';

class ClientContextService extends GetxService {
  PathService pathService = Get.find<PathService>();

  void changeContext(String newSessionPath){
    pathService.updateSessionPath(newSessionPath);
  }

  bool setDefaultContext() {
    // TODO: should return false and set cwd to
    return false;
  }
}