import 'package:ember_core/ember_core_models.dart';

class ModelHelperFunctions {
  // CamperPreference
  static int preferencesCompletedCount(CamperPreference camperPreference) {
    // Access the values of the map, filter out the nulls, and return the count.
    return camperPreference.preferenceRefs.values.where((value) => value != null).length;
  }

  static bool preferenceCompleted(CamperPreference camperPreference, Schedule schedule) {
    // Use the 'every' method to iterate through each id in the set.
    // 'every' returns true only if the provided condition is true for ALL elements.
    return schedule.principalActivityRefs.every((id) {
      // Check 1: Key exists in preferenceRefs AND its value is not null.
      final hasNonNullPreference = camperPreference.preferenceRefs.containsKey(
          id) && camperPreference.preferenceRefs[id] != null;

      // Check 2: Key exists in preferenceWeightRefs.
      // (No need to check for null value here as the map type is <PrincipalActivityId, double>)
      final hasWeight = camperPreference.preferenceWeightRefs.containsKey(id);

      // The condition for 'every' returns true only if both checks pass for the current id.
      return hasNonNullPreference && hasWeight;
    });
  }
}