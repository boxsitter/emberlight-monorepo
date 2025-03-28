import 'package:flutter/material.dart';

import '../abstract/bess_object.dart';

typedef CabinId = String;
typedef AssignedMultiActivityBlockId = String;
typedef CamperPreferenceId = String;
typedef ActivityId = String;

class Camper extends BessObject {
  String firstName;
  String preferredName;
  String lastName;
  String gender;
  int age;
  String note;
  CabinId? cabinId;
  String? cabinName;

  CamperPreferenceId? camperPreferenceId;
  // maps assignable activity block ids to the activity ids that the campers are assigned to for that block
  Map<AssignedMultiActivityBlockId, ActivityId?> activityAssignments;

  Camper({
    this.firstName = '',
    this.lastName = '',
    this.preferredName = '',
    this.gender = '',
    this.age = 0,
    this.note = '',
    this.cabinId,
    this.cabinName,
    this.camperPreferenceId,
    Map<AssignedMultiActivityBlockId, CamperPreferenceId>? activityPreferences,
    Map<AssignedMultiActivityBlockId, ActivityId>? activityAssignments,
    super.id,
    super.createdAt,
    super.updatedAt,
  })  : activityAssignments = activityAssignments ?? {},
        super(idTitle: 'camper-$lastName-$firstName');

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
      'cabinName': cabinName,
      'camperPreferenceId': camperPreferenceId,
      'activityAssignments': activityAssignments,
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
      cabinName: json['cabinName'],
      camperPreferenceId: json['camperPreferenceId'],
      activityAssignments:
          (json['activityAssignments'] as Map?)?.cast<String, String>() ?? {},
    );
    camper.overwriteBessObjectFromJson(json, clone);
    return camper;
  }
}
