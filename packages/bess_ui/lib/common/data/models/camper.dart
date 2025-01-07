import 'package:bessie/common/data/models/schedule/activity.dart';
import 'package:bessie/common/data/models/schedule/assignable_activity_block.dart';

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
    required BessObject dataParent,
    this.firstName = '',
    this.lastName = '',
    this.preferredName = '',
    this.gender = '',
    this.age = 0,
    this.cabin,
  }) : super('camper-$lastName-$firstName', dataParent);

  /// returns preferred name if set, first name if not
  String get name => preferredName.isNotEmpty ? preferredName : firstName;
  String get fullName => '$name $lastName';

  @override
  Map<String, dynamic> toJson() {
    final json = toJsonSuper();
    json.addAll({
      'firstName': firstName,
      'lastName': lastName,
      'preferredName': preferredName,
      'age': age,
    });
    return json;
  }

  @override
  String bessToString() {
    String idField = toStringSuper();
    String nameField = fullName;
    String ageField = 'Age: $age';
    String cabinField = 'Cabin: ${cabin?.name ?? "none"}';

    return '$idField $nameField, $ageField, $cabinField';
  }

}