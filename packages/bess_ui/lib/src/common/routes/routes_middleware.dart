import 'package:ember_core/ember_core_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'routes.dart'; // Your BessRoutes class is here

class AuthMiddleware extends GetMiddleware {
  @override
  int? get priority => 0;

  UserService userService = Get.find<UserService>();

  @override
  RouteSettings? redirect(String? route) {
    // Define which routes are considered "public" (accessible without login)
    // These are routes that unauthenticated users CAN visit.
    final List<String> publicAuthRoutes = [
      BessRoutes.login,
      BessRoutes.forgotPassword,
      BessRoutes.resetPassword,
      // If you add a sign-up page, include its route string here:
      // BessRoutes.signUp,
    ];

    final bool isTryingToAccessPublicAuthRoute = publicAuthRoutes.contains(route);

    print('AuthMiddleware: Current route: $route, IsAuthenticated: ${userService.isAuthenticated}');

    if (userService.isAuthenticated) {
      // User IS authenticated
      if (isTryingToAccessPublicAuthRoute) {
        // If an authenticated user tries to access login, forgot password, etc.,
        // redirect them to the home page.
        print('AuthMiddleware: Authenticated user on a public auth page ($route). Redirecting to ${BessRoutes.home}');
        return const RouteSettings(name: BessRoutes.home);
      }
      // For any other route (which are effectively protected or other non-auth public pages), allow access.
      print('AuthMiddleware: Authenticated user accessing $route. Allowed.');
      return null; // No redirection needed, proceed to the intended route.
    } else {
      // User is NOT authenticated
      if (isTryingToAccessPublicAuthRoute) {
        // If an unauthenticated user is trying to access a public auth route (like login), allow it.
        print('AuthMiddleware: Unauthenticated user accessing public auth route $route. Allowed.');
        return null; // No redirection needed
      } else {
        // If an unauthenticated user tries to access any other route (which should be protected),
        // redirect them to the login page.
        print('AuthMiddleware: Unauthenticated user on protected route $route. Redirecting to ${BessRoutes.login}');
        return const RouteSettings(name: BessRoutes.login);
      }
    }
  }
}