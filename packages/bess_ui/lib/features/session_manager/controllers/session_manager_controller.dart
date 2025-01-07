import 'package:get/get.dart';

import '../../../common/data/models/cabin.dart';
import '../../../common/data/models/local_data.dart';

class SessionManagerController extends GetxController {
  final LocalData localData = Get.find<LocalData>();

  void initializeSessionForTesting() {
    addCabinToSession(name: "Henderson", capacity: 12);
    addCabinToSession(name: "Leckenby", capacity: 12);
    addCabinToSession(name: "Yarrow", capacity: 12);
    addCabinToSession(name: "Freeman 1", capacity: 14);
  }

  // TODO: This code is temporary, fix it
  // In the final version, this method should search through the branches cabin "templates" and activate that cabin for the current session
  // Creation of cabins should be handled in the branch manager
  // As of now, it creates the cabin and adds it
  void addCabinToSession({
    required String name,
    required int capacity,
  }) {
    Cabin cabinToAdd = Cabin(dataParent: localData.session!, name: name, capacity: capacity);
    localData.session!.cabins[cabinToAdd.id] = cabinToAdd;
    localData.session!.updateTimestamp();
  }
}