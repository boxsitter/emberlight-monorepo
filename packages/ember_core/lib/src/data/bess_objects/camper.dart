import '../abstract/bess_object.dart';

typedef CabinRef = String;
typedef AssignedMultiActivityBlockRef = String;
typedef CamperPreferenceCmp = String;
typedef ScheduledActivityRef = String;

class Camper extends BessObject {
  String firstName;
  String preferredName;
  String lastName;
  String gender;
  int age;
  String note;
  CabinRef? cabinRef;
  String? cabinName; // TODO: This could cause problems with deletion of cabins or cabinsInUse, look into it

  CamperPreferenceCmp? camperPreferenceCmp;
  bool camperPreferenceCompleted; // TODO: This could cause problems with deletion of preferences
  // maps assignable activity block ids to the activity ids that the campers are assigned to for that block
  Map<AssignedMultiActivityBlockRef, ScheduledActivityRef?> activityAssignmentRefs; // TODO: Make sure maps of references are handled correctly and that entries are purged whether the id being purged is a key or a value

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
    Map<AssignedMultiActivityBlockRef, ScheduledActivityRef>? activityAssignmentRefs,
    super.objId,
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
  String bessToString() {
    String idField = toStringSuper();
    String nameField = fullName;
    String ageField = 'Age: $age';
    String cabinField = 'cabinRef: ${cabinRef ?? "none"}';

    return '$idField $nameField, $ageField, $cabinField';
  }

  @override
  void purgeRef(String ref) {
    if (BessIdFunctions.getIdPart(ref, 2) == 'camper') {
      if(camperRefs.remove(ref) == false) { // TODO: remove this once the delete logic is bug free
        print('unnecessary purge');
      }
      if(campersWithPreferences.remove(ref) == null) {
        print('unnecessary purge');
      }
    } else if (BessIdFunctions.getIdPart(ref, 2) == 'cab') {
      campersWithPreferences.removeWhere((key, value) => value == ref);
    }
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
    camper.overwriteBessObjectFromJson(json);
    return camper;
  }
}
