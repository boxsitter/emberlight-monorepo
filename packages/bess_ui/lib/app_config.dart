import 'package:get/get.dart';

import 'common/constants/catppuccin_base.dart';
import 'common/routes/routes.dart';

class AppConfig {
  static Flavor theme = catppuccin.latte;

  static const double minWindowWidth = 640;
  static const double minWindowHeight = 480;

  static const Transition defaultTransitionAnimation = Transition.noTransition;

  static const String homePage = BessRoutes.home;

  static const bool updateHardCodedDataOnRun = false;
  static const bool createHardCodedDataOnRun = false;
}