import 'package:bess_ui/src/pages/rosters/widgets/searchbar.dart';
import 'package:flutter/material.dart';

import '../controllers/rosters_controller.dart';

/// A builder function that constructs and returns a configured [BessMenuBar] for the Rosters page.
List<Widget> buildRostersTrailingWidgets({
  required RostersController controller,
}) {
  return [
    BessSearchbar(onSearchChange: controller.setSearchQuery, noMatches: controller.filteredRoster.isEmpty, controller: controller.searchController,),
  ];
}