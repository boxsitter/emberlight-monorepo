import 'dart:async';

import 'package:bess_ui/src/common/utils/helpers/helper_functions.dart';
import 'package:ember_core/ember_core_models.dart';
import 'package:ember_core/ember_core_services.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../common/mixins/route_aware_controller_mixin.dart';

class ActivityRostersController extends GetxController with RouteAwareControllerMixin {
  final ContextService contextService = Get.find<ContextService>();
  final RosterService rosterService = Get.find<RosterService>();

  final Map<String, String> amaBlockNames = <String, String>{};
  String? selectedAMABlockId;

  String? selectedAmaId = null;
  String? selectedAmaName = null;

  bool isBlockDataLoaded = false;

  @override
  Future<void> onNavigateTo(String to, String? from) async {
    isBlockDataLoaded = false;
    update(); // Show a loading state

    final scheduleService = Get.find<ScheduleService>();
    final Map<String, AMABlock> amaBlocks = await scheduleService.getAMABlocks();

    // Populate the names map for the UI, which was missing before.
    amaBlockNames.clear();
    amaBlocks.forEach((id, block) {
      amaBlockNames[id] = block.name;
    });

    // Handle the edge case where there are no blocks at all.
    if (amaBlocks.isEmpty) {
      selectedAMABlockId = null;
      isBlockDataLoaded = true;
      update();
      return;
    }

    // --- Robust Default Selection Logic ---
    final Map<String, List<DateTime>> intervals = {};
    for (final block in amaBlocks.values) {
      intervals[block.id] = [block.start, block.end];
    }

    // 1. Call the improved helper function to find the best block.
    final String? idealBlockId = BessHelperFunctions.findNextOrCurrentInterval(intervals);

    // 2. Safely set the selected ID.
    // If the helper finds a block, use it. If not, robustly fall back
    // to the very first block in the list. This prevents crashes.
    selectedAMABlockId = idealBlockId ?? amaBlocks.keys.first;

    isBlockDataLoaded = true;
    update(); // Update the UI with the data and selection.
  }

  // selectCamper method (ensure it calls populateActivityMaps)
  Future<void> selectAma(String amaId, String amaName) async {
    // Wait for any ongoing activity data loading to complete.
    while (isBlockDataLoaded) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
    selectedAmaId = amaId;
    selectedAmaName = amaName;
    update();
  }

  
}
