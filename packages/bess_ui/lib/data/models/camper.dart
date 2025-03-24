import '../abstract/bess_object.dart';

class Camper extends BessObject {
  String firstName;
  String preferredName;
  String lastName;
  String gender;
  int age;
  String note;
  String? cabinId;

  // contains all AssignableActivityBlock's for the camper's session and their preferences for each
  //Map<AssignedMultiActivityBlock, CamperPreference> activityPreferences = {};
  // set of the activities a camper is assigned to for each activity block
  Set<String> activitiesIds;

  Camper({
    this.firstName = '',
    this.lastName = '',
    this.preferredName = '',
    this.gender = '',
    this.age = 0,
    this.note = '',
    this.cabinId,
    this.activitiesIds = const {},
    super.id,
    super.createdAt,
    super.updatedAt,
  }) : super(idTitle: 'camper-$lastName-$firstName');

  /// returns preferred name if set, first name if not
  String get name => preferredName.isNotEmpty ? preferredName : firstName;
  String get fullName => '$name $lastName';

  @override
  String bessToString() {
    String idField = toStringSuper();
    String nameField = fullName;
    String ageField = 'Age: $age';
    String cabinField = 'CabinId: ${cabinId ?? "none"}';

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
      'cabinId': cabinId,
      'activitiesIds': activitiesIds.toList(),
    });
    return json;
  }

  factory Camper.fromJson(Map<String, dynamic> json, [bool clone = false]) {
    Camper camper = Camper(
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      preferredName: json['preferredName'] ?? '',
      gender: json['gender'] ?? '',
      age: json['age'] is int ? json['age'] : int.tryParse(json['age'].toString()) ?? 0,
      note: json['note'] ?? '',
      cabinId: json['cabinId'],
      activitiesIds: (json['activitiesIds'] as List?)?.cast<String>().toSet() ?? <String>{},
    );
    camper.overwriteBessObjectFromJson(json, clone);
    return camper;
  }
}