
import '../../../ember_core.dart';
import '../roster_field.dart';

abstract class Rosterable implements Titled, CoreObject {
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
  bool? get arrived;
  bool? get canSwim;

  String getFieldAsString(RosterField field);
}