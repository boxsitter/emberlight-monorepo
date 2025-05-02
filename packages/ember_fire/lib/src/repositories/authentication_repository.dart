import 'package:ember_core/ember_core_debug.dart';
import 'package:ember_core/ember_core_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../debug/auth_exceptions.dart';

class AuthenticationRepository {
  // Firebase Auth Instance
  final _auth = FirebaseAuth.instance;

  /// Logs in a user with the provided email and password using Firebase Authentication.
  ///
  /// Parameters:
  ///   [email]: The user's registered email.
  ///   [password]: The user's password.
  ///
  /// Returns:
  ///   A [Future] that completes with the [UserCredential] on successful authentication.
  ///
  /// Throws:
  ///   A specific exception extending [EmberException] (e.g., [AuthCredentialsFailure], [AuthServiceError])
  ///   if the login fails or an unexpected error occurs.
  Future<UserCredential> loginWithEmailAndPassword(String email, String password) async {
    Debug.logInfo(
      'Attempting Firebase login for email: ${CoreFormatter.maskEmail(email)}',
      verbosity: Verbosity.verbose,
    );

    try {
      // Attempt to sign in using Firebase Auth
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Log successful login
      final userId = userCredential.user?.uid ?? 'N/A';
      Debug.logSuccess(
        'Firebase login successful for user: $userId',
        verbosity: Verbosity.verbose,
      );

      // Return the credential on success
      return userCredential;

    } on FirebaseAuthException catch (e, st) {
      final exception = BessFirebaseAuthExceptionFactory.fromCode(e.code);
      Error.throwWithStackTrace(Debug.parseException(exception), st);
    } catch (e, st) {
      Error.throwWithStackTrace(Debug.parseException(e), st);
    }
  }

  /// Stream for listening to authentication state changes.
  /// Emits the current [User] when logged in, or null when logged out.
  Stream<User?> get authStateChanges {
    Debug.logInfo('authStateChanges stream accessed', verbosity: Verbosity.excessive);
    return _auth.authStateChanges();
  }

  /// Gets the current authenticated user. Returns null if no user is logged in.
  User? get currentUser {
    final user = _auth.currentUser;
    Debug.logInfo(
        user == null ? 'currentUser accessed: No user logged in.' : 'currentUser accessed: User found (UID: ${user.uid})',
        verbosity: Verbosity.excessive,
        metadata: {'userId': user?.uid ?? 'null'}
    );
    return user;
  }

  // --- Placeholder Methods ---

  // Register (To be implemented later)
  // Future<UserCredential> registerWithEmailAndPassword(String email, String password, String name) async {
  //   // Implementation needed
  // }

  // Register user by admin (To be implemented later)
  // Future<void> registerUserByAdmin(...) async {
  //   // Implementation needed
  // }

  // Email verification (To be implemented later)
  // Future<void> sendEmailVerification() async {
  //   // Implementation needed
  // }

  // Forgot Password (To be implemented later)
  // Future<void> sendPasswordResetEmail(String email) async {
  //   // Implementation needed
  // }

  // Logout User (To be implemented later)
  // Future<void> logout() async {
  //   // Implementation needed
  // }

  // Deactivate User (To be implemented later)
  // Future<void> deactivateUser() async {
  //   // Implementation needed
  // }

  // Delete user (To be implemented later)
  // Future<void> deleteUser() async {
  //   // Implementation needed
  // }
}
