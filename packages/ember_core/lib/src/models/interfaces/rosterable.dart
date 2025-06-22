import '../../../ember_core_models.dart';
import '../roster_field.dart';

abstract class Rosterable {
  String get id;
  String get firstName;
  String get preferredName;
  String get lastName;
  String get fullName;
  String get gender;
  DateTime get birthdate;
  int get age;
  String get note;
  String? get cabinName;
  String? get ultracampId;
  Map<AMABlockId, ActivityDependentId?> get activityAssignmentRefs;

  String getFieldAsString(RosterField field);
}