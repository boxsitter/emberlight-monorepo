import 'package:ember_core/ember_core_models.dart';

import '../../../ember_core_utils.dart';


typedef CabinId = String;
typedef AMABlockId = String;
typedef ActivityDependentId = String;
typedef CamperId = String;

class Camper extends CoreObject {
  String firstName;
  String preferredName;
  String lastName;
  String gender;
  int age;
  String note;
  CabinId? cabinRef;
  String? cabinName;
  final Map<PrincipalActivityId, double?> preferenceRefs; // A map of every unique activity type in the schedule to the camper's preference
  final Map<PrincipalActivityId, double> preferenceWeightRefs;
  // maps assignable activity block ids to the activity ids that the campers are assigned to for that block
  Map<AMABlockId, ActivityDependentId?> activityAssignmentRefs;

  Camper({
    required this.firstName,
    required this.lastName,
    this.preferredName = '',
    this.gender = '',
    this.age = 0,
    this.note = '',
    this.cabinRef,
    this.cabinName,
    Map<PrincipalActivityId, double?>? preferenceRefs,
    Map<PrincipalActivityId, double>? preferenceWeightRefs,
    Map<AMABlockId, ActivityDependentId>? activityAssignmentRefs,
    super.id,
    super.createdAt,
    super.updatedAt,
  })  : preferenceRefs = preferenceRefs ?? {},
        preferenceWeightRefs = preferenceWeightRefs ?? {},
        activityAssignmentRefs = activityAssignmentRefs ?? {},
        super(
        domain: 'ses',
        type: 'camper',
        idTag: '${firstName}_${lastName[0]}',
      );

  /// returns preferred name if set, first name if not
  String get name => preferredName.isNotEmpty ? preferredName : firstName;
  String get fullName => '$name $lastName';
  String get lastInitial => lastName[0];

  @override
  String coreToString() {
    // TODO: implement coreToString
    throw UnimplementedError();
  }

  @override
  Map<String, dynamic> toJson() {
    final json = toJsonSuper();
    json.addAll({
      'firstName': firstName,
      'lastName': lastName,
      'preferredName': preferredName,
      'gender': gender,
      'age': age,
      'note': note,
      'cabinRef': cabinRef,
      'cabinName': cabinName,
      'preferenceRefs': preferenceRefs.map((key, value) => MapEntry(key, value?.clamp(0.0, 1.0))),
      'preferenceWeightRefs': preferenceWeightRefs.map((key, value) => MapEntry(key, value.clamp(0.0, 1.0))),
      'activityAssignmentRefs': activityAssignmentRefs,
    });
    return json;
  }

  factory Camper.fromJson(Map<String, dynamic> json) {
    Camper camper = Camper(
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      preferredName: json['preferredName'] ?? '',
      gender: json['gender'] ?? '',
      age: json['age'] is int ? json['age'] : int.tryParse(json['age'].toString()) ?? 0,
      note: json['note'] ?? '',
      cabinRef: json['cabinRef'],
      cabinName: json['cabinName'],
      preferenceRefs: (json['preferenceRefs'] as Map?)?.cast<String, double?>() ?? {},
      preferenceWeightRefs: (json['preferenceWeightRefs'] as Map?)?.cast<String, double>() ?? {},
      activityAssignmentRefs: (json['activityAssignmentRefs'] as Map?)?.cast<String, String>() ?? {},
    );
    camper.overwriteCoreObjectFromJson(json);
    return camper;
  }

  @override
  void purgeRef(String id) {
    if (IdFunctions.getIdPart(id, 1) == 'cabin_dependent') {
      if (cabinRef == id) {
        cabinRef == null;
        cabinName == null;
      }
    }

    if (IdFunctions.getIdPart(id, 1) == 'AMA_Block') {
      activityAssignmentRefs.remove(id);
    }

    if (IdFunctions.getIdPart(id, 1) == 'activity_dependent') {
      activityAssignmentRefs.removeWhere((key, value) => value == id);
    }
  }


}
