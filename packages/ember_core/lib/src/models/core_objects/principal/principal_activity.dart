

import '../../../../ember_core.dart';
import '../../interfaces/elevated.dart';

typedef PrincipalActivityId = String;

class PrincipalActivity extends CoreObject implements Principal, Elevated, Titled{
  final String name;
  final int capacity;
  final String description;
  final bool isSkillsRec;

  PrincipalActivity({
    required this.name,
    required this.capacity,
    required this.description,
    required this.isSkillsRec,
    super.id,
    super.createdAt,
    super.updatedAt,
  })  : super(
          domain: 'brn',
          type: 'principal_activity',
          idTag: name,
        );

  @override
  String coreToString() {
    return 'Activity: $name, Capacity: $capacity';
  }

  @override
  Map<String, dynamic> toJson() {
    final json = toJsonSuper();
    json.addAll({
      'name': name,
      'capacity': capacity,
      'description': description,
      'isSkillsRec': isSkillsRec,
    });
    return json;
  }

  factory PrincipalActivity.fromJson(Map<String, dynamic> json) {
    PrincipalActivity activity = PrincipalActivity(
      name: json['name'] as String,
      capacity: json['capacity'] as int,
      description: json['description'] as String,
      isSkillsRec: json['isSkillsRec'] as bool,
    );
    activity.overwriteCoreObjectFromJson(json);
    return activity;
  }

  @override
  void purgeRef(String id) {
    Debug.logInfo('Purging $id from ${this.id}');
    Debug.logInfo('unnecessary purge');
  }

  @override
  String get displayTitle => name;

  @override
  String get title => name;
}
