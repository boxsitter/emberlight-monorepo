// import 'dart:math';
// import 'package:bessie/pages/console/controller/console_controller.dart';
// import 'package:get/get.dart';
//
// import '../../data/models/camper.dart';
// import '../../data/models/camper_preference.dart';
// import '../../data/models/delete_this_old_localdata.dart';
// import '../../data/models/schedule/activity.dart';
//
// class ActivitySignupService extends GetxService {
//   Map<String, Camper> get campers => localData.session!.sessionRoster.campers;
//
//   // follows the rules of the simple assignment algorithm
//   void setRanking ({
//     required CamperPreference preference,
//     required Activity activity,
//     required int value
//   }) {
//     if (value < 1) {
//       throw ArgumentError('Ranking cannot be less than 1');
//     }
//     if (value > preference.preferences.length) {
//       throw ArgumentError('Ranking cannot exceed the number of activities in the block');
//     }
//     // if the camper has already given another activity the same ranking, remove that activity's ranking first
//     // this makes duplicate rankings impossible
//     if(!preference.seenValues.add(value)) {
//       for(var entry in preference.preferences.entries) {
//         if (entry.value == value) {
//           preference.preferences[entry.key] = null;
//           break;
//         }
//       }
//     }
//     // set the new ranking
//     preference.preferences[activity] = value;
//     ConsoleController().log('${preference.camper.fullName} ranked ${activity.name} in ${preference.block.name} a $value');
//     // updates completed for the preference if all activities have a ranking set
//     if (preference.seenValues.length == preference.preferences.length) {
//       preference.completed = true;
//       ConsoleController().success('${preference.camper.fullName} has ranked all activities in ${preference.block.name}');
//     }
//   }
//
//   void clearPreference(CamperPreference preference) {
//     preference.preferences.forEach((key, value) {
//       preference.preferences[key] = null;
//     });
//
//     // clear seenValues as no rankings are left
//     preference.seenValues.clear();
//
//     // mark as incomplete
//     preference.completed = false;
//   }
//
//   // assigns all campers a random preference for each activity
//   // for testing
//   void rankRandom() {
//     final random = Random();
//
//     for (Camper camper in campers.values) {
//       for (CamperPreference preference in camper.activityPreferences.values) {
//         // Get all activities in a list
//         final activities = preference.preferences.keys.toList();
//
//         // Shuffle the activities randomly
//         activities.shuffle(random);
//
//         // Assign rankings randomly
//         int i = 1;
//         for (Activity activity in activities) {
//           setRanking(preference: preference, activity: activity, value: i);
//           i++;
//         }
//       }
//     }
//   }
// }