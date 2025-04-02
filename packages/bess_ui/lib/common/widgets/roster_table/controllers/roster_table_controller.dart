import 'dart:async';

import 'package:ember_core/ember_core_backend.dart';
import 'package:ember_core/ember_core_models.dart';
import 'package:ember_core/ember_core_services.dart';
import 'package:get/get.dart';

class RosterTableController extends GetxController {
  final ClientContextService contextService = Get.find<ClientContextService>();
  final CabinService cabinsService = Get.find<CabinService>();

  final campers = <String, Camper>{}.obs;
  final count = 0.obs;

  StreamSubscription<Map<String, Camper>>? _campersSubscription;

  // void _startListening() {
  //   _campersSubscription = BackendManager.instance.watchDocWithChildDocs<Session, Camper>(
  //     parentId: contextService.sessionId,
  //     parentFromJson: Session.fromJson,
  //     childIdField: 'registeredCamperIds',
  //     childFromJson: Camper.fromJson,
  //   )
  //       .listen((camperMap) {
  //     campers.assignAll(camperMap);
  //   });
  // }

  void startListening() {
    if (_campersSubscription == null) {
      print('Started listening');
      //_startListening();
    }
  }

  void stopListening() {
    print('Stopped listening');
    _campersSubscription?.cancel();
    _campersSubscription = null;
  }

  @override
  void onInit() {
    super.onInit();
    //_startListening();
    ever(campers, (_) => count.value = campers.length);
  }

  @override
  void onClose() {
    stopListening();
    super.onClose();
  }
}
