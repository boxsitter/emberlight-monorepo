import 'package:bessie/data/abstract/bess_object.dart';
import 'package:bessie/data/models/schedule/schedule.dart';

typedef CamperId = String;

// Represents a camper's preference for each activity in a given AssignableActivityBlock
class CamperPreference extends BessObject {
  final CamperId camperId;
  final String camperName;
  final Map<UniqueActivityTypeId, double?> preferences; // A map of every unique activity type in the schedule to the camper's preference
  final Map<UniqueActivityTypeId, double> preferenceWeights; // For every unique activity, there is also a weight that gets modified when the camper participates in that activity
  int preferencesCompletedCount;
  // true when the camper has indicated their preference for every activity in the block
  bool completed;

  CamperPreference({
    required this.camperId,
    required this.camperName,
    Map<UniqueActivityTypeId, double?>? preferences,
    Map<UniqueActivityTypeId, double>? preferenceWeights,
    Set<double>? seenValues,
    this.preferencesCompletedCount = 0,
    this.completed = false,
    super.id,
    super.createdAt,
    super.updatedAt,
  })  : preferences = preferences ?? {},
        preferenceWeights = preferenceWeights ?? {},
        super(idTitle: 'camper_preference-$camperName');

  @override
  String bessToString() {
    // TODO: implement bessToString
    throw UnimplementedError();
  }

  @override
  Map<String, dynamic> toJson() {
    final json = toJsonSuper();
    json.addAll({
      'camperId': camperId,
      'camperName': camperName,
      'preferences': preferences.map((key, value) => MapEntry(key, value?.clamp(0.0, 1.0))),
      'preferenceWeights': preferenceWeights.map((key, value) => MapEntry(key, value?.clamp(0.0, 1.0))),
      'preferencesCompletedCount': preferencesCompletedCount,
      'completed': completed,
    });
    return json;
  }

  factory CamperPreference.fromJson(Map<String, dynamic> json, [bool clone = false]) {
    final preference = CamperPreference(
      camperId: json['camperId'] ?? '',
      camperName: json['camperName'] ?? '',
      preferences: (json['preferences'] as Map?)?.cast<String, double?>() ?? {},
      preferenceWeights: (json['preferenceWeights'] as Map?)?.cast<String, double>() ?? {},
      preferencesCompletedCount: json['preferencesCompletedCount'] ?? 0,
      completed: json['completed'] ?? false,
    );
    preference.overwriteBessObjectFromJson(json, clone);
    return preference;
  }

}