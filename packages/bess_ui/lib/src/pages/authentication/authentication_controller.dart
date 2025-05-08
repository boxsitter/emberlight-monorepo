import 'package:ember_core/ember_core_debug.dart';
import 'package:ember_core/ember_core_services.dart';
import 'package:ember_core/ember_core_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../common/routes/routes.dart';

class AuthenticationController extends GetxController {
  UserService userService = Get.find<UserService>();

  // TextEditingControllers for the form fields
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Observable for loading state
  final RxBool isLoading = false.obs;

  // Observable for password visibility
  final RxBool hidePassword = true.obs;

  // Observable for "Remember Me" checkbox
  final RxBool rememberMe = false.obs; // Default to false

  /// Toggles the visibility of the password input field.
  void togglePasswordVisibility() {
    hidePassword.value = !hidePassword.value;
  }

  /// Attempts to log in the user with the email and password from the controllers.
  Future<void> loginUser() async {
    if (isLoading.value) return; // Prevent multiple submissions if already loading

    try {
      Debug.logInfo('Attempting to login user with email: ${CoreFormatter.maskEmail(emailController.text)}');

      isLoading.value = true;

      final String email = emailController.text.trim();
      final String password = passwordController.text;

      // Perform login using your Ember Core UserService
      await userService.login(email, password);

      if (userService.isAuthenticated) {
        // Navigate to home screen on successful login
        // You might want to clear fields upon successful login:
        // emailController.clear();
        // passwordController.clear();
        Get.offAllNamed(BessRoutes.home); // Use offAllNamed to clear navigation stack up to home
      }
    } catch (e, st) {
      Error.throwWithStackTrace(Debug.parseException(e), st);
    } finally {
      isLoading.value = false;
      // Clear the password from the password controller for security,
      // especially if login failed, so it's not lingering in the field.
      passwordController.clear();
      print('Password controller cleared after login attempt.');
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
    Debug.logInfo('Disposed AuthenticationController');
  }
}