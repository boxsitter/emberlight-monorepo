import 'package:bessie/common/services/cabins_service.dart';
import 'package:bessie/data/models/schedule/activity.dart';
import 'package:bessie/data/models/schedule/assignable_activity_block.dart';
import 'package:get/get.dart';

import '../abstract/bess_object.dart';
import 'cabin.dart';
import 'camper_preference.dart';

class Camper extends BessObject {
  String firstName;
  String preferredName;
  String lastName;
  String gender;
  int age;
  Cabin? cabin;

  // contains all AssignableActivityBlock's for the camper's session and their preferences for each
  Map<AssignableActivityBlock, CamperPreference> activityPreferences = {};
  // set of the activities a camper is assigned to for each activity block
  Map<AssignableActivityBlock, Activity?> activities = {};

  Camper({
    this.firstName = '',
    this.lastName = '',
    this.preferredName = '',
    this.gender = '',
    this.age = 0,
    this.cabin,
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
    String cabinField = 'Cabin: ${cabin?.name ?? "none"}';

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
      'cabinId': cabin?.id,
      // Note: activityPreferences and activities are handled separately.
    });
    return json;
  }

  factory Camper.fromJson(Map<String, dynamic> json) {
    // handle id referenced fields
    final String? cabinId = json['cabinId'] as String?;
    Cabin? resolvedCabin;

    if(cabinId != null) {
      resolvedCabin = Get.find<CabinsService>().fetchCabinById(cabinId);
    }

    return Camper(
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      preferredName: json['preferredName'] ?? '',
      gender: json['gender'] ?? '',
      age: json['age'] is int ? json['age'] : int.tryParse(json['age'].toString()) ?? 0,
      cabin: resolvedCabin,
      id: json['id'] as String,
      createdAt: DateTime.tryParse(json['createdAt'] as String),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String),
    );
  }

}