import 'dart:async';
import 'package:bessie/common/services/cabin_service.dart';
import 'package:get/get.dart';
import 'package:bessie/data/bess_objects/camper.dart';
import 'package:bessie/data/bess_objects/domains/session.dart';
import 'package:bessie/common/services/client_context_service.dart';

import '../../../../data/repositories/live_data_repository.dart';
import '../../../../data/repositories/pull_repository.dart';

class RosterTableController extends GetxController {
  final PullRepository bessObjectRepo = Get.find<PullRepository>();
  final ClientContextService contextService = Get.find<ClientContextService>();
  final LiveDataRepository liveDataRepo = Get.find<LiveDataRepository>();
  final CabinService cabinsService = Get.find<CabinService>();

  final campers = <String, Camper>{}.obs;
  final count = 0.obs;

  StreamSubscription<Map<String, Camper>>? _campersSubscription;

  void _startListening() {
    _campersSubscription = liveDataRepo
        .watchDocWithChildDocs<Session, Camper>(
      parentId: contextService.sessionId,
      parentFromJson: Session.fromJson,
      childIdField: 'registeredCamperIds',
      childFromJson: Camper.fromJson,
    )
        .listen((camperMap) {
      campers.assignAll(camperMap);
    });
  }

  void startListening() {
    if (_campersSubscription == null) {
      print('Started listening');
      _startListening();
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
    _startListening();
    ever(campers, (_) => count.value = campers.length);
  }

  @override
  void onClose() {
    stopListening();
    super.onClose();
  }
}
