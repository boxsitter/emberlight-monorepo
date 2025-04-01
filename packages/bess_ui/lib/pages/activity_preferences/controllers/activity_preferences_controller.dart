import 'package:bessie/common/services/cabin_service.dart';
import 'package:bessie/common/services/session_roster_service.dart';
import 'package:bessie/data/repositories/push_repository.dart';
import 'package:get/get.dart';
import 'package:bessie/common/services/client_context_service.dart';

import '../../../common/routes/routes.dart';
import '../../../data/bess_objects/branch_cabin.dart';
import '../../../data/bess_objects/camper.dart';
import '../../../data/bess_objects/camper_preference.dart';
import '../../../data/bess_objects/schedule/assigned_multi_activity_block.dart';


class ActivityPreferencesController extends GetxController {
  final PullRepository bessObjectRepo = Get.find<PullRepository>();
  final ClientContextService contextService = Get.find<ClientContextService>();
  final CabinService cabinsService = Get.find<CabinService>();
  final SessionRosterService sessionRosterService = Get.find<SessionRosterService>();

  final RxMap<CabinId, String> cabinNames = <CabinId, String>{}.obs;
  final RxMap<CabinId, int> camperCounts = <CabinId, int>{}.obs;
  final RxMap<CabinId, int> campersWithPreferencesCounts = <CabinId, int>{}.obs;

  CabinId? selectedCabinId;
  String? selectedCabinName;
  final RxMap<CamperRef, String> camperNames = <CamperRef, String>{}.obs;
  final RxMap<CamperRef, bool> camperIsCompleted = <CamperRef, bool>{}.obs;

  CabinId? selectedCamperId;
  final RxMap<ScheduledActivityRef, String> activityNames = <ScheduledActivityRef, String>{}.obs;

  final RxBool isCabinDataLoaded = false.obs;
  final RxBool isCamperDataLoaded = false.obs;
  final RxBool isActivityDataLoaded = false.obs;

  Future<void> populateCabinMaps() async {
    isCabinDataLoaded.value = false;
    print('POPULATING CABIN MAPS');
    final Set<BranchCabin> cabinsInUseIds = await cabinsService.cabinsInUse;

    final names = <CabinId, String>{};
    final counts = <CabinId, int>{};
    final preferences = <CabinId, int>{};

    for (final BranchCabin cabin in cabinsInUseIds) {
      names[cabin.objId] = cabin.name;
      counts[cabin.objId] = cabin.camperRefs.length;
      preferences[cabin.objId] = cabin.campersWithPreferences;
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

    final names = <CamperRef, String>{};
    final completed = <CamperRef, bool>{};

    for (final Camper camper in campers) {
      names[camper.objId] = camper.fullName;
      completed[camper.objId] = camper.camperPreferenceCompleted;
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
