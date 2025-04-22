import 'package:ember_core/ember_core_models.dart';

import '../../../ember_core_utils.dart';


typedef CabinId = String;
typedef AssignedMultiActivityBlockId = String;
typedef ActivityDependentId = String;

class Camper extends CoreObject {
  String firstName;
  String preferredName;
  String lastName;
  String gender;
  int age;
  String note;
  CabinId? cabinRef;
  String? cabinName;

  CamperPreferenceId? camperPreferenceCmp;
  bool camperPreferenceCompleted;
  // maps assignable activity block ids to the activity ids that the campers are assigned to for that block
  Map<AssignedMultiActivityBlockId, ActivityDependentId?> activityAssignmentRefs; // TODO: Make sure maps of references are handled correctly and that entries are purged whether the id being purged is a key or a value

  Camper({
    required this.firstName,
    required this.lastName,
    this.preferredName = '',
    this.gender = '',
    this.age = 0,
    this.note = '',
    this.cabinRef,
    this.cabinName,
    this.camperPreferenceCmp,
    this.camperPreferenceCompleted = false,
    Map<AssignedMultiActivityBlockId, ActivityDependentId>? activityAssignmentRefs,
    super.id,
    super.createdAt,
    super.updatedAt,
  })  : activityAssignmentRefs = activityAssignmentRefs ?? {},
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
    String idField = toStringSuper();
    String nameField = fullName;
    String ageField = 'Age: $age';
    String cabinField = 'cabinRef: ${cabinRef ?? "none"}';

    return '$idField $nameField, $ageField, $cabinField';
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
      'camperPreferenceCmp': camperPreferenceCmp,
      'camperPreferenceCompleted': camperPreferenceCompleted,
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
      camperPreferenceCmp: json['camperPreferenceCmp'] ?? '',
      camperPreferenceCompleted: json['camperPreferenceCompleted'] ?? false,
      activityAssignmentRefs: (json['activityAssignmentRefs'] as Map?)?.cast<String, String>() ?? {},
    );
    camper.overwriteCoreObjectFromJson(json);
    return camper;
  }

  @override
  void purgeRef(String id) {
    print('Purging $id from ${this.id}');
    // no need to handle principal cabin since the dependant will be in the delete chain anyway
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
