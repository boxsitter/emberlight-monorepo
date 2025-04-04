

import 'package:ember_core/ember_core_models.dart';
import 'package:ember_core/ember_core_utils.dart';

typedef CamperId = String;

// Represents a camper's preference for each activity in a given AssignableActivityBlock
class CamperPreference extends BessObject {
  final CamperId camperRef;
  final String camperName;
  final Map<ActivityTypeId, double?> preferencesRefs; // A map of every unique activity type in the schedule to the camper's preference
  final Map<ActivityTypeId, double> preferenceWeightRefs; // For every unique activity, there is also a weight that gets modified when the camper participates in that activity
  int preferencesCompletedCount;
  // true when the camper has indicated their preference for every activity in the block
  bool completed;

  CamperPreference({
    required this.camperRef,
    required this.camperName,
    Map<ActivityTypeId, double?>? preferencesRefs,
    Map<ActivityTypeId, double>? preferenceWeightRefs,
    this.preferencesCompletedCount = 0,
    this.completed = false,
    super.id,
    super.createdAt,
    super.updatedAt,
  })  : preferencesRefs = preferencesRefs ?? {},
        preferenceWeightRefs = preferenceWeightRefs ?? {},
        super(
          domain: 'ses',
          type: 'camper_preference',
          idTag: camperName,
        );

  @override
  String bessToString() {
    // TODO: implement bessToString
    throw UnimplementedError();
  }

  @override
  void purgeRef(String id) {
    if (IdFunctions.getIdPart(id, 2) == 'activity_type') {
      if(preferencesRefs.remove(id) == null) {
        print('unnecessary purge');
      }

      if(preferenceWeightRefs.remove(id) == null) {
        print('unnecessary purge');
      }
    }
  }

  @override
  Map<String, dynamic> toJson() {
    final json = toJsonSuper();
    json.addAll({
      'camperRef': camperRef,
      'camperName': camperName,
      'preferencesRefs': preferencesRefs.map((key, value) => MapEntry(key, value?.clamp(0.0, 1.0))),
      'preferenceWeightRefs': preferenceWeightRefs.map((key, value) => MapEntry(key, value.clamp(0.0, 1.0))),
      'preferencesCompletedCount': preferencesCompletedCount,
      'completed': completed,
    });
    return json;
  }

  factory CamperPreference.fromJson(Map<String, dynamic> json) {
    final preference = CamperPreference(
      camperRef: json['camperRef'] ?? '',
      camperName: json['camperName'] ?? '',
      preferencesRefs: (json['preferencesRefs'] as Map?)?.cast<String, double?>() ?? {},
      preferenceWeightRefs: (json['preferenceWeightRefs'] as Map?)?.cast<String, double>() ?? {},
      preferencesCompletedCount: json['preferencesCompletedCount'] ?? 0,
      completed: json['completed'] ?? false,
    );
    preference.overwriteBessObjectFromJson(json);
    return preference;
  }


}