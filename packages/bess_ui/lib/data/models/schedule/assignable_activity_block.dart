import 'package:bessie/data/abstract/schedule_block.dart';

import 'activity.dart';

class AssignableActivityBlock extends ScheduleBlock {
  Map<String, Activity> activities;

  AssignableActivityBlock({
    required super.name,
    super.id,
    super.createdAt,
    super.updatedAt,
  })  : activities = {}, super();

  @override
  String bessToString() {
    return 'AssignableActivityBlock: $name, Activities: ${activities.length}';
  }

  @override
  Map<String, dynamic> toJson() {
    final json = toJsonSuper();
    json.addAll({
      'name': name,
      'activities': activities.map((key, activity) => MapEntry(key, activity.toJson())),
    });
    return json;
  }

  factory AssignableActivityBlock.fromJson(Map<String, dynamic> json) {
    final block = AssignableActivityBlock(
      name: json['name'] as String,
      id: json['id'] as String,
      createdAt: DateTime.tryParse(json['createdAt'] as String),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String),
    );
    if (json.containsKey('activities')) {
      final activitiesJson = json['activities'] as Map<String, dynamic>;
      activitiesJson.forEach((key, activityJson) {
        block.activities[key] = Activity.fromJson(activityJson as Map<String, dynamic>);
      });
    }
    return block;
  }

}