import 'package:get/get_navigation/src/routes/transitions_type.dart';

import 'common/constants/catppuccin_base.dart';
import 'common/routes/routes.dart';

class AppConfig {
  static Flavor theme = catppuccin.latte;

  static const double minWindowWidth = 640;
  static const double minWindowHeight = 480;

  static const bool addDummyDataForTesting = true;

  static const Transition defaultTransitionAnimation = Transition.noTransition;

  static const String homePage = BessRoutes.home;
}