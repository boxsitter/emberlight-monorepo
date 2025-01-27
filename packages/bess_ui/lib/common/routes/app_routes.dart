// This file defines the application's route configurations using GetX's
// `GetPage`. Each route is associated with a specific screen and optional
// middleware. Uncommented routes can be easily added to extend functionality.

import 'package:bessie/common/routes/routes.dart';
import 'package:bessie/common/routes/routes_middleware.dart';
import 'package:bessie/features/session_roster/session_roster.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';

import '../../features/authentication/view/forgot_password/forgot_password.dart';
import '../../features/authentication/view/login/login.dart';
import '../../features/authentication/view/reset_password/reset_password.dart';
import '../../features/console/view/console.dart';
import '../../features/home/home.dart';
import '../../features/responsive_design_test/responsive_design.dart';

class BessAppRoute {
  static final List<GetPage> pages = [
    GetPage(name: BessRoutes.home, page: () => const HomeScreen(), middlewares: [BessRouteMiddleware()]),
    GetPage(name: BessRoutes.responsiveDesignExample, page: () => const ResponsiveDesignScreen()),
    GetPage(name: BessRoutes.console, page: () => const ConsoleScreen()),
    GetPage(name: BessRoutes.sessionRoster, page: () => const SessionRoster()),
    GetPage(name: BessRoutes.login, page: () => const LoginScreen()),
    GetPage(name: BessRoutes.forgotPassword, page: () => const ForgotPasswordScreen()),
    GetPage(name: BessRoutes.resetPassword, page: () => const ResetPasswordScreen()),
  ];
}
