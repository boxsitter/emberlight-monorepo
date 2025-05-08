import 'package:ember_core/ember_core_debug.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class AuthenticationStateService extends GetxService {
  final _auth = FirebaseAuth.instance;

  User? get currentUser {
    final user = _auth.currentUser;
    Debug.logInfo(
        user == null ? 'currentUser accessed: No user logged in.' : 'currentUser accessed: User found (UID: ${user.uid})',
        verbosity: Verbosity.excessive,
        metadata: {'userId': user?.uid ?? 'null'}
    );
    return user;
  }

  bool get isUserLoggedIn => _auth.currentUser != null;
}