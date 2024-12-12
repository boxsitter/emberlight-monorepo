// This file defines the application's route configurations using GetX's
// `GetPage`. Each route is associated with a specific screen and optional
// middleware. Uncommented routes can be easily added to extend functionality.

import 'package:bessie/routes/routes.dart';
import 'package:bessie/routes/routes_middleware.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
import '../app.dart';

class BessAppRoute {
  static final List<GetPage> pages = [
    // GetPage(name: BessRoutes.firstScreen, page: () => const FirstScreen(), middlewares: [ConstRouteMiddleware()]),
    // GetPage(name: BessRoutes.secondScreen, page: () => const SecondScreen(), middlewares: [ConstRouteMiddleware()]),
    GetPage(name: BessRoutes.responsiveDesignExample, page: () => const ResponsiveDesignScreen()),

    // GetPage(name: BessRoutes.login, page: () => const LoginScreen()),
    // GetPage(name: BessRoutes.forgetPassword, page: () => const ForgetPasswordScreen()),
    // GetPage(name: BessRoutes.dashboard, page: () => const DashboardScreen()),
    // GetPage(name: BessRoutes.settings, page: () => const SettingsScreen()),
    //
    // GetPage(name: BessRoutes.sessionManager, page: () => const SessionManagerScreen()),
    // GetPage(name: BessRoutes.sessionRoster, page: () => const SessionRosterScreen()),
  ];
}