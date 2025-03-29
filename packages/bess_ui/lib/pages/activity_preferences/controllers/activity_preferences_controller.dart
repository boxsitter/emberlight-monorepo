import 'package:bessie/common/services/cabins_service.dart';
import 'package:bessie/common/services/session_roster_service.dart';
import 'package:bessie/data/repositories/bess_object_repository.dart';
import 'package:get/get.dart';
import 'package:bessie/common/services/client_context_service.dart';

import '../../../common/routes/routes.dart';
import '../../../data/models/cabin.dart';
import '../../../data/models/camper.dart';
import '../../../data/models/camper_preference.dart';
import '../../../data/models/schedule/assigned_multi_activity_block.dart';


class ActivityPreferencesController extends GetxController {
  final BessObjectRepository bessObjectRepo = Get.find<BessObjectRepository>();
  final ClientContextService contextService = Get.find<ClientContextService>();
  final CabinsService cabinsService = Get.find<CabinsService>();
  final SessionRosterService sessionRosterService = Get.find<SessionRosterService>();

  final RxMap<CabinId, String> cabinNames = <CabinId, String>{}.obs;
  final RxMap<CabinId, int> camperCounts = <CabinId, int>{}.obs;
  final RxMap<CabinId, int> campersWithPreferencesCounts = <CabinId, int>{}.obs;

  CabinId? selectedCabinId;
  String? selectedCabinName;
  final RxMap<CamperId, String> camperNames = <CamperId, String>{}.obs;
  final RxMap<CamperId, bool> camperIsCompleted = <CamperId, bool>{}.obs;

  CabinId? selectedCamperId;
  final RxMap<ActivityId, String> activityNames = <ActivityId, String>{}.obs;

  final RxBool isCabinDataLoaded = false.obs;
  final RxBool isCamperDataLoaded = false.obs;
  final RxBool isActivityDataLoaded = false.obs;

  Future<void> populateCabinMaps() async {
    isCabinDataLoaded.value = false;
    print('POPULATING CABIN MAPS');
    final Set<Cabin> cabinsInUseIds = await cabinsService.cabins;

    final names = <CabinId, String>{};
    final counts = <CabinId, int>{};
    final preferences = <CabinId, int>{};

    for (final Cabin cabin in cabinsInUseIds) {
      names[cabin.id] = cabin.name;
      counts[cabin.id] = cabin.camperIds.length;
      preferences[cabin.id] = cabin.campersWithPreferencesCount;
    }

    cabinNames.value = names;
    camperCounts.value = counts;
    campersWithPreferencesCounts.value = preferences;
    isCabinDataLoaded.value = true;
  }

  Future<void> populateCamperMaps() async {
    if (selectedCabinName == null || selectedCabinId == null) {
      return;
    }
    isCamperDataLoaded.value = false;
    print('POPULATING CAMPER MAPS');
    final Set<Camper> campers = await cabinsService.getCampersInCabin(selectedCabinId!);

    final names = <CamperId, String>{};
    final completed = <CamperId, bool>{};

    for (final Camper camper in campers) {
      names[camper.id] = camper.fullName;
      completed[camper.id] = camper.camperPreferenceCompleted;
    }

    camperNames.value = names;
    camperIsCompleted.value = completed;
    isCamperDataLoaded.value = true;
  }

  Future<void> populateActivityMaps() async {
    if (selectedCamperId == null) {
      return;
    }
    isActivityDataLoaded.value = false;
    print('POPULATING ACTIVITY MAPS');
  }

  void navigateToCampers(String cabinId, String cabinName) {
    selectedCabinId = cabinId;
    selectedCabinName = cabinName;
    Get.toNamed(BessRoutes.activityPreferencesCampers);
  }

  // void navigateToSelection(String camperId) {
  //   selectedCabinId = cabinId;
  //   selectedCabinName = cabinName;
  //   Get.toNamed(BessRoutes.activityPreferencesCampers);
  // }

}
