import 'package:ember_core/ember_core_models.dart';
import 'package:ember_core/ember_core_services.dart';
import 'package:get/get.dart';

import '../../../common/routes/routes.dart';

typedef CabinId = String;

class ActivityPreferencesController extends GetxController {
  final ClientContextService contextService = Get.find<ClientContextService>();
  final CabinService cabinsService = Get.find<CabinService>();
  final SessionRosterService sessionRosterService = Get.find<SessionRosterService>();

  final RxMap<CabinId, String> cabinNames = <CabinId, String>{}.obs;
  final RxMap<CabinId, int> camperCounts = <CabinId, int>{}.obs;
  final RxMap<CabinId, int> campersWithPreferencesCounts = <CabinId, int>{}.obs;

  CabinId? selectedCabinId;
  String? selectedCabinName;
  final RxMap<CamperId, String> camperNames = <CamperId, String>{}.obs;
  final RxMap<CamperId, bool> camperIsCompleted = <CamperId, bool>{}.obs;

  CabinId? selectedCamperId;
  final RxMap<ScheduledActivityId, String> activityNames = <ScheduledActivityId, String>{}.obs;

  final RxBool isCabinDataLoaded = false.obs;
  final RxBool isCamperDataLoaded = false.obs;
  final RxBool isActivityDataLoaded = false.obs;

  Future<void> populateCabinMaps() async {
    isCabinDataLoaded.value = false;
    print('POPULATING CABIN MAPS');
    final Set<CabinInUse> cabinsInUseIds = await cabinsService.cabinsInUse;

    final names = <CabinId, String>{};
    final counts = <CabinId, int>{};
    final preferences = <CabinId, int>{};

    for (final CabinInUse cabin in cabinsInUseIds) {
      names[cabin.id] = cabin.name;
      counts[cabin.id] = cabin.camperRefs.length;
      preferences[cabin.id] = cabin.campersWithPreferences.length;
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
