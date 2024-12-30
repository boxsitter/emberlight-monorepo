import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../routes/routes.dart';
import '../../utils/exceptions/firebase_auth_exceptions.dart';
import '../../utils/exceptions/firebase_exceptions.dart';
import '../../utils/exceptions/format_exceptions.dart';
import '../../utils/exceptions/platform_exceptions.dart';

class AuthenticationRepository extends GetxController {
  static AuthenticationRepository get instance => Get.find();

  // Firebase Auth Instance
  final _auth = FirebaseAuth.instance;

  // Get Authenticated User Data
  User? get authUser => _auth.currentUser;

  // Get IsAuthenticated User
  bool get isAuthenticated => _auth.currentUser != null;

  // @override
  // void onReady() {
  //   _auth.setPersistence(Persistence.LOCAL);
  // }

  // Function to determine that relevant screen and redirect accordingly
  void screenRedirect() async {
    final user = _auth.currentUser;

    // If the user is logged in
    if (user != null) {
      final user = _auth.currentUser;

      // If the user is logged in
      if (user != null) {
        // Navigate to the home screen
        Get.offAllNamed(BessRoutes.home);
      } else {
        Get.offAllNamed(BessRoutes.login);
      }
    }
  }

  // Login
  Future<UserCredential> loginWithEmailAndPassword(
      String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
          email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw BessFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw BessFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const BessFormatException();
    } on PlatformException catch (e) {
      throw BessPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  // Register
  Future<UserCredential> registerWithEmailAndPassword(
      String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw BessFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw BessFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const BessFormatException();
    } on PlatformException catch (e) {
      throw BessPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

// Register user by admin

// Email verification

// Forget Password

// Forget Password

// Re Authenticate User

// Logout User

// Delete User
}
