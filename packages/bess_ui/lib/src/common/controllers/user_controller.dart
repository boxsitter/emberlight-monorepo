// import 'package:ember_core/ember_core_debug.dart';
// import 'package:ember_core/ember_core_models.dart';
// import 'package:ember_core/ember_core_services.dart';
// import 'package:get/get.dart';
//
// class UserController extends GetxController {
//   final UserService _userService = Get.find<UserService>();
//
//   CoreUser? currentUser;
//   bool fetchingUserData = false;
//
//   Future<void> _fetchUserData() async {
//     try {
//       fetchingUserData = true;
//       Debug.logInfo('[UserController] Attempting to fetch current user...');
//       final CoreUser? user = await _userService.getCurrentUser();
//       if (user != null) {
//
//         currentUser = user;
//         // Now that currentUser.value is set, the getters will use it.
//         // Ensure that user.fullName (from CoreUser model) is robust.
//         Debug.logSuccess('[HeaderController] User data fetched: ${userFullName}');
//       } else {
//         Debug.logWarning('[HeaderController] No current user found by UserService.');
//         error = 'User not found';
//         currentUser = null;
//       }
//     } catch (e, st) {
//       // The error "TypeError: null: type 'Null' is not a subtype of type 'String'"
//       // strongly suggests an issue with how a null value is being treated as a String.
//       // This could be inside user.fullName, user.role.name, or if `e.toString()` itself fails (unlikely).
//       Debug.logWarning('[HeaderController] Error fetching user data: $e');
//       error = 'Failed to load user data. Details: $e';
//       currentUser = null;
//     } finally {
//       fetchingUserData = false;
//     }
//   }
// }
//
