import 'package:bess_ui/src/common/routes/routes_middleware.dart';
import 'package:bess_ui/src/pages/activity_preferences/controllers/activity_preferences_controller_diplomatic.dart';
import 'package:bess_ui/src/pages/dev_testing/dev_testing.dart' deferred as dev_testing_page;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../pages/activity_preferences/controllers/activity_preferences_controller_absolute.dart';
import '../../pages/activity_preferences/views/activity_preferences.dart' deferred as activity_preferences_page;
import '../../pages/authentication/view/forgot_password/forgot_password.dart';
import '../../pages/authentication/view/login/login.dart';
import '../../pages/authentication/view/reset_password/reset_password.dart';
import '../../pages/branch_manager/branch_manager.dart' deferred as branch_manager_page;
import '../../pages/console/view/console.dart' deferred as console_page;
import '../../pages/home/home.dart';
import '../../pages/rosters/controllers/rosters_controller.dart';
import '../../pages/rosters/rosters.dart' deferred as rosters_page;
import '../../pages/schedule/schedule_page.dart' deferred as schedule_page;
import '../../pages/session_manager/session_manager.dart' deferred as session_manager_page;
import '../../pages/session_manager/session_manager_controller.dart';
import '../../pages/unknown_route/unknown_route.dart';
import '../mixins/route_aware_controller_mixin.dart';

class BessRoutes {
  // static const home = '/';
  static const unknown = '/unknown';

  static const responsiveDesignExample = '/responsive-design';
  static const console = '/console';
  static const dev_testing = '/dev_testing';
  static const rosters = '/';
  static const schedulePage = '/schedule-page';
  static const sessionManager = '/session-manager';
  static const branchManager = '/branch-manager';

  static const activityPreferences = '/activity-preferences';
  static const activityPreferencesCampers = '/activity-preferences-campers';
  static const activityPreferencesSelector = '/activity-preferences-selector';

  static const login = '/login';
  static const forgotPassword = '/forgotPassword';
  static const resetPassword = '/resetPassword';

  static Set sideMenuItems = {
    console,
    dev_testing,
    rosters,
    activityPreferences,
    sessionManager,
    branchManager,
    schedulePage,
  };

  static Set publicRoutes = {
    login,
    forgotPassword,
    resetPassword,
    unknown,
  };

  static final List<GetPage> pages = [
    // GetPage(
    //   name: BessRoutes.home,
    //   page: () => const HomeScreen(),
    //   middlewares: [AuthMiddleware()], // PROTECTED
    // ),
    GetPage(
      name: BessRoutes.console,
      page: () => DeferredPageLoader(
        libLoader: console_page.loadLibrary,
        builder: () => const console_page.ConsoleScreen(),
      ),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: BessRoutes.dev_testing,
      page: () => DeferredPageLoader(
        libLoader: dev_testing_page.loadLibrary,
        builder: () => const dev_testing_page.DevTesting(),
      ),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: BessRoutes.rosters,
      page: () => DeferredPageLoader(
        libLoader: rosters_page.loadLibrary,
        builder: () => const rosters_page.Rosters(),
      ),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: BessRoutes.schedulePage,
      page: () => DeferredPageLoader(
        libLoader: schedule_page.loadLibrary,
        builder: () => const schedule_page.SchedulePage(),
      ),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: BessRoutes.sessionManager,
      page: () => DeferredPageLoader(
        libLoader: session_manager_page.loadLibrary,
        builder: () => const session_manager_page.SessionManager(),
      ),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: BessRoutes.activityPreferences,
      page: () => DeferredPageLoader(
        libLoader: activity_preferences_page.loadLibrary,
        builder: () => const activity_preferences_page.ActivityPreferences(),
      ),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: BessRoutes.activityPreferencesSelector,
      page: () => DeferredPageLoader(
        libLoader: activity_preferences_page.loadLibrary,
        builder: () => const activity_preferences_page.ActivityPreferences(),
      ),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: BessRoutes.branchManager,
      page: () => DeferredPageLoader(
        libLoader: branch_manager_page.loadLibrary,
        builder: () => const branch_manager_page.BranchManager(),
      ),
      middlewares: [AuthMiddleware()],
    ),

    // --- AUTHENTICATION ROUTES (Public for unauthenticated users) ---
    // No AuthMiddleware here to block unauthenticated access,
    // but AuthMiddleware will redirect *away* if already logged in.
    GetPage(name: BessRoutes.login, page: () => const LoginScreen()),
    GetPage(name: BessRoutes.forgotPassword, page: () => const ForgotPasswordScreen()),
    GetPage(name: BessRoutes.resetPassword, page: () => const ResetPasswordScreen()),

    // THIS MUST BE LAST IN THE LIST!!!
    GetPage(
      name: BessRoutes.unknown,
      page: () => const UnknownRoute(),
    ),
  ];

  static RouteAwareControllerMixin? getControllerForRoute(String? routeName) {
    if (routeName == null) return null;

    if (routeName == BessRoutes.rosters && Get.isRegistered<RostersController>()) {
      return Get.find<RostersController>();
    }
    if ((routeName == BessRoutes.activityPreferences || routeName == BessRoutes.activityPreferencesSelector) && Get.isRegistered<ActivityPreferencesControllerDiplomatic>()) {
      return Get.find<ActivityPreferencesControllerDiplomatic>();
    }
    if (routeName == BessRoutes.sessionManager && Get.isRegistered<SessionManagerController>()) {
      return Get.find<SessionManagerController>();
    }
    // Add other route-to-controller mappings here
    return null;
  }
}

class DeferredPageLoader<T extends Widget> extends StatelessWidget {
  const DeferredPageLoader({super.key, required this.libLoader, required this.builder});

  final Future<void> Function() libLoader;
  final T Function() builder;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: libLoader(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return builder();
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
