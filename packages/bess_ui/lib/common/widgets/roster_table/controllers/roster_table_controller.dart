import 'dart:async';
import 'package:bessie/common/services/cabins_service.dart';
import 'package:bessie/data/repositories/bess_object_repository.dart';
import 'package:get/get.dart';
import 'package:bessie/data/models/camper.dart';
import 'package:bessie/data/models/session.dart';
import 'package:bessie/common/services/client_context_service.dart';

import '../../../../data/repositories/live_data_repository.dart';

class RosterTableController extends GetxController {
  final BessObjectRepository bessObjectRepo = Get.find<BessObjectRepository>();
  final ClientContextService contextService = Get.find<ClientContextService>();
  final LiveDataRepository liveDataRepo = Get.find<LiveDataRepository>();
  final CabinsService cabinsService = Get.find<CabinsService>();

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
