import 'package:ember_core/ember_core_debug.dart';
import 'package:ember_core/ember_core_models.dart';
import 'package:ember_core/ember_core_services.dart';
import 'package:get/get.dart';

class HeaderController extends GetxController {
  final UserService _userService = Get.find<UserService>();

  // Reactive variables to hold the user data and loading/error states
  final Rx<CoreUser?> currentUser = Rx<CoreUser?>(null);
  final RxBool isLoading = true.obs;
  final RxString error = ''.obs;

  // --- Safely computed properties ---
  String get userFullName {
    if (currentUser.value?.preferredName != null) {
      return currentUser.value?.preferredName ?? 'User';
    }
    return currentUser.value?.fullName ?? 'User';
  }

  String get userRoleName {
    // Assuming Role is an enum and role.name is always a valid string.
    // If CoreUser.role can be null, this needs a null check too.
    // For example: currentUser.value?.role?.name ?? 'Role';
    // Based on CoreUser, 'role' is not nullable, but role.name gives the string.
    if (currentUser.value?.role.name == 'root') {
      return '';
    }
    return currentUser.value?.role.name ?? 'Role';
  }

  String get userInitial {
    final name = currentUser.value?.fullName;
    if (name != null && name.isNotEmpty) {
      return name[0].toUpperCase();
    }
    return '?';
  }
  // --- End safely computed properties ---

  @override
  void onInit() {
    super.onInit();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      isLoading.value = true;
      error.value = '';
      Debug.logInfo('[HeaderController] Attempting to fetch current user...');
      final CoreUser? user = await _userService.getCurrentUser();
      print(user!.name);
      if (user != null) {
        // Before assigning, ensure critical fields used by getters are not null
        // if they are expected to be non-null strings.
        // Example: if user.firstName is unexpectedly null from DB and CoreUser.fullName
        // doesn't handle it, it could lead to issues.
        // However, CoreUser.fromJson should ideally handle this by assigning defaults.

        // Let's check the 'fullName' getter from CoreUser as an example of what could go wrong
        // if its constituent parts (firstName, lastName) are null and not handled in its own logic.
        // String tempFullName = user.fullName; // This line could throw if user.fullName has an issue.
                                          // For example, if it tries "'null' 'null'" or similar.
        // To be super safe, you might even log individual fields here before relying on getters:
        // Debug.logInfo('[HeaderController] Fetched user raw fields - firstName: "${user.firstName}", lastName: "${user.lastName}"');


        currentUser.value = user;
        // Now that currentUser.value is set, the getters will use it.
        // Ensure that user.fullName (from CoreUser model) is robust.
        Debug.logSuccess('[HeaderController] User data fetched: ${userFullName}');
      } else {
        Debug.logWarning('[HeaderController] No current user found by UserService.');
        error.value = 'User not found';
        currentUser.value = null;
      }
    } catch (e, st) {
      // The error "TypeError: null: type 'Null' is not a subtype of type 'String'"
      // strongly suggests an issue with how a null value is being treated as a String.
      // This could be inside user.fullName, user.role.name, or if `e.toString()` itself fails (unlikely).
      Debug.logWarning('[HeaderController] Error fetching user data: $e');
      error.value = 'Failed to load user data. Details: $e';
      currentUser.value = null;
    } finally {
      isLoading.value = false;
    }
  }
}