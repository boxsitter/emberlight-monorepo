import 'package:ember_core/ember_core.dart';
import 'package:get/get.dart';

class UserController extends GetxController {
  final UserService _userService = Get.find<UserService>();

  static CoreUser nullUser = CoreUser(firebaseUid: null, firstName: 'null', lastName: 'null', role: Role.nullRole);

  CoreUser currentUser = nullUser;
  bool fetchingUserData = false;

  Future<void> _fetchUserData() async {
    try {
      fetchingUserData = true;
      Debug.logInfo('[UserController] Attempting to fetch current user...');
      final CoreUser? user = await _userService.getCurrentUser();
      if (user != null) {

        currentUser = user;
        // Now that currentUser.value is set, the getters will use it.
        // Ensure that user.fullName (from CoreUser model) is robust.
        Debug.logSuccess('[UserController] User data fetched: ${currentUser?.fullName}');
      } else {
        Debug.logWarning('[UserController] No current user found by UserService.');
        currentUser = nullUser;
      }
    } catch (e, st) {
      // The error "TypeError: null: type 'Null' is not a subtype of type 'String'"
      // strongly suggests an issue with how a null value is being treated as a String.
      // This could be inside user.fullName, user.role.name, or if `e.toString()` itself fails (unlikely).
      Debug.logWarning('[UserController] Error fetching user data: $e');
      currentUser = nullUser;
    } finally {
      fetchingUserData = false;
    }
  }
}

