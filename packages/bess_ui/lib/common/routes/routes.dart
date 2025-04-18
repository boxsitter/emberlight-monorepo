import 'package:get/get_navigation/src/routes/get_route.dart';

import '../../pages/activity_preferences/views/activity_preferences_cabins.dart';
import '../../pages/activity_preferences/views/activity_preferences_campers.dart';
import '../../pages/authentication/view/forgot_password/forgot_password.dart';
import '../../pages/authentication/view/login/login.dart';
import '../../pages/authentication/view/reset_password/reset_password.dart';
import '../../pages/console/view/console.dart';
import '../../pages/home/home.dart';
import '../../pages/responsive_design_test/responsive_design.dart';
import '../../pages/schedule/schedule_page.dart';
import '../../pages/session_manager/session_manager.dart';
import '../../pages/session_roster/session_roster.dart';

class BessRoutes {
  static const home = '/';

  //static const secondScreen = '/second-screen';
  //static const secondScreenWithUID = '/second-screen/:userId';
  static const responsiveDesignExample = '/responsive-design/';
  static const console = '/console';
  static const sessionRoster = '/session-roster';
  static const schedulePage = '/schedule-page';
  static const sessionManager = '/session-manager';

  static const activityPreferencesCabins = '/activity-preferences-cabins';
  static const activityPreferencesCampers = '/activity-preferences-campers';

  static List sideMenuItems = [
    console,
    sessionRoster,
    home,
    activityPreferencesCabins,
    responsiveDesignExample,
    sessionManager,
    schedulePage,
  ];

  static const login = '/login';
  static const forgotPassword = '/forgotPassword';
  static const resetPassword = '/resetPassword';
}

class BessAppRoute {
  static final List<GetPage> pages = [
    GetPage(name: BessRoutes.home, page: () => const HomeScreen()),
    GetPage(name: BessRoutes.responsiveDesignExample, page: () => const ResponsiveDesignScreen()),
    GetPage(name: BessRoutes.console, page: () => const ConsoleScreen()),
    GetPage(name: BessRoutes.sessionRoster, page: () => const SessionRoster()),
    GetPage(name: BessRoutes.schedulePage, page: () => const SchedulePage()),
    GetPage(name: BessRoutes.sessionManager, page: () => const SessionManager()),

    GetPage(name: BessRoutes.activityPreferencesCabins, page: () => const ActivityPreferencesCabins()),
    GetPage(name: BessRoutes.activityPreferencesCampers, page: () => const ActivityPreferencesCampers()),

    GetPage(name: BessRoutes.login, page: () => const LoginScreen()),
    GetPage(name: BessRoutes.forgotPassword, page: () => const ForgotPasswordScreen()),
    GetPage(name: BessRoutes.resetPassword, page: () => const ResetPasswordScreen()),
  ];
}
