

import 'package:ember_core/ember_core_models.dart';
import 'package:ember_core/ember_core_utils.dart';
import 'package:ember_core/src/models/core_objects/principal/principal_activity.dart';

typedef CamperId = String;

// Represents a camper's preference for each activity in a given AssignableActivityBlock
class CamperPreference extends CoreObject {
  final CamperId camperRef;
  final String camperName;
  final Map<PrincipalActivityId, double?> preferenceRefs; // A map of every unique activity type in the schedule to the camper's preference
  final Map<PrincipalActivityId, double> preferenceWeightRefs; // For every unique activity, there is also a weight that gets modified when the camper participates in that activity

  CamperPreference({
    required this.camperRef,
    required this.camperName,
    Map<PrincipalActivityId, double?>? preferenceRefs,
    Map<PrincipalActivityId, double>? preferenceWeightRefs,
    super.id,
    super.createdAt,
    super.updatedAt,
  })  : preferenceRefs = preferenceRefs ?? {},
        preferenceWeightRefs = preferenceWeightRefs ?? {},
        super(
          domain: 'ses',
          type: 'camper_preference',
          idTag: camperName,
        );



  @override
  String coreToString() {
    // TODO: implement coreToString
    throw UnimplementedError();
  }

  @override
  Map<String, dynamic> toJson() {
    final json = toJsonSuper();
    json.addAll({
      'camperRef': camperRef,
      'camperName': camperName,
      'preferenceRefs': preferenceRefs.map((key, value) => MapEntry(key, value?.clamp(0.0, 1.0))),
      'preferenceWeightRefs': preferenceWeightRefs.map((key, value) => MapEntry(key, value.clamp(0.0, 1.0))),
    });
    return json;
  }

  factory CamperPreference.fromJson(Map<String, dynamic> json) {
    final preference = CamperPreference(
      camperRef: json['camperRef'] ?? '',
      camperName: json['camperName'] ?? '',
      preferenceRefs: (json['preferenceRefs'] as Map?)?.cast<String, double?>() ?? {},
      preferenceWeightRefs: (json['preferenceWeightRefs'] as Map?)?.cast<String, double>() ?? {},
    );
    preference.overwriteCoreObjectFromJson(json);
    return preference;
  }

  @override
  void purgeRef(String id) {
    if (IdFunctions.getIdPart(id, 1) == 'principal_activity') {
      preferenceRefs.remove(id);
      preferenceWeightRefs.remove(id);
    }
  }

}