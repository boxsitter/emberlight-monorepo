// This file defines the application's route configurations using GetX's
// `GetPage`. Each route is associated with a specific screen and optional
// middleware. Uncommented routes can be easily added to extend functionality.

import 'package:bessie/features.authentication/screens/forgot_password/forgot_password.dart';
import 'package:bessie/features.authentication/screens/reset_password/reset_password.dart';
import 'package:bessie/routes/routes.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
import '../Pages/home.dart';
import '../Pages/responsive_design.dart';
import '../features.authentication/screens/login/login.dart';

class BessAppRoute {
  static final List<GetPage> pages = [
    GetPage(name: BessRoutes.home, page: () => const HomeScreen()),
    GetPage(name: BessRoutes.responsiveDesignExample, page: () => const ResponsiveDesignScreen()),

    GetPage(name: BessRoutes.login, page: () => const LoginScreen()),
    GetPage(name: BessRoutes.forgotPassword, page: () => const ForgotPasswordScreen()),
    GetPage(name: BessRoutes.resetPassword, page: () => const ResetPasswordScreen()),

    //
    // GetPage(name: BessRoutes.sessionManager, page: () => const SessionManagerScreen()),
    // GetPage(name: BessRoutes.sessionRoster, page: () => const SessionRosterScreen()),
  ];
}