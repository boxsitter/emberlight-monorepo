import 'package:bess_ui/src/common/routes/routes_middleware.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';

import '../../pages/activity_preferences/views/activity_preferences_cabins.dart';
import '../../pages/activity_preferences/views/activity_preferences_selector.dart';
import '../../pages/authentication/view/forgot_password/forgot_password.dart';
import '../../pages/authentication/view/login/login.dart';
import '../../pages/authentication/view/reset_password/reset_password.dart';
import '../../pages/console/view/console.dart';
import '../../pages/home/home.dart';
import '../../pages/rosters/session_roster.dart';
import '../../pages/schedule/schedule_page.dart';
import '../../pages/session_manager/session_manager.dart';

class BessRoutes {
  static const home = '/';

  static const responsiveDesignExample = '/responsive-design';
  static const console = '/console';
  static const rosters = '/session-roster';
  static const schedulePage = '/schedule-page';
  static const sessionManager = '/session-manager';
  static const activityRosters = '/activity-rosters';

  static const activityPreferencesCabins = '/activity-preferences-cabins';
  static const activityPreferencesCampers = '/activity-preferences-campers';
  static const activityPreferencesSelector = '/activity-preferences-selector';

  static const login = '/login';
  static const forgotPassword = '/forgotPassword';
  static const resetPassword = '/resetPassword';

  static Set sideMenuItems = {
    console,
    rosters,
    home,
    activityPreferencesCabins,
    activityRosters,
    responsiveDesignExample,
    sessionManager,
    schedulePage,
  };

  static Set publicRoutes = {
    login,
    forgotPassword,
    resetPassword,
  };

  static final List<GetPage> pages = [
    GetPage(
      name: BessRoutes.home,
      page: () => const HomeScreen(),
      middlewares: [AuthMiddleware()], // PROTECTED
    ),
    GetPage(
      name: BessRoutes.console,
      page: () => const ConsoleScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: BessRoutes.rosters,
      page: () => const Rosters(rosterTableController: 'session-roster-controller'),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: BessRoutes.schedulePage,
      page: () => const SchedulePage(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: BessRoutes.sessionManager,
      page: () => const SessionManager(pageControllerTag: 'session-manager-controller',),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: BessRoutes.activityPreferencesCabins,
      page: () => const ActivityPreferencesCabins(pageControllerTag: 'activity-preferences-controller'),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: BessRoutes.activityPreferencesSelector,
      page: () => const ActivityPreferencesSelector(pageControllerTag: 'activity-preferences-controller'),
      middlewares: [AuthMiddleware()],
    ),

    // --- AUTHENTICATION ROUTES (Public for unauthenticated users) ---
    // No AuthMiddleware here to block unauthenticated access,
    // but AuthMiddleware will redirect *away* if already logged in.
    GetPage(name: BessRoutes.login, page: () => const LoginScreen()),
    GetPage(name: BessRoutes.forgotPassword, page: () => const ForgotPasswordScreen()),
    GetPage(name: BessRoutes.resetPassword, page: () => const ResetPasswordScreen()),
  ];
}
