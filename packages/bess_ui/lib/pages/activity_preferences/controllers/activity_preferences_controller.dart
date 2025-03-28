import 'package:bessie/common/services/cabins_service.dart';
import 'package:bessie/data/repositories/bess_object_repository.dart';
import 'package:get/get.dart';
import 'package:bessie/common/services/client_context_service.dart';

import '../../../common/routes/routes.dart';
import '../../../data/models/cabin.dart';
import '../../../data/models/camper.dart';


class ActivityPreferencesController extends GetxController {
  final BessObjectRepository bessObjectRepo = Get.find<BessObjectRepository>();
  final ClientContextService contextService = Get.find<ClientContextService>();
  final CabinsService cabinsService = Get.find<CabinsService>();

  final RxMap<CabinId, String> cabinNames = <CabinId, String>{}.obs;
  final RxMap<CabinId, int> camperCounts = <CabinId, int>{}.obs;
  final RxMap<CabinId, int> campersWithPreferencesCounts = <CabinId, int>{}.obs;

  final RxBool isCabinDataLoaded = false.obs;

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

  void navigateToCampers(String cabinId, String cabinName) {
    Get.toNamed(
      BessRoutes.activityPreferencesCampers,
      arguments: {
        'cabinId': cabinId,
        'cabinName': cabinName,
      },
    );
  }

}
