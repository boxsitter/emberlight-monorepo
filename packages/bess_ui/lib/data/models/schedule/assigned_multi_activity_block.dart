import 'package:bessie/data/abstract/schedule_block.dart';
import 'package:flutter/material.dart';


class AssignedMultiActivityBlock extends ScheduleBlock {
  final Set<String> activities;

  AssignedMultiActivityBlock({
    Set<String>? activities,
    required super.name,
    super.id,
    super.createdAt,
    super.updatedAt,
  })  : activities = activities ?? {},
        super(idTitle: 'assignedmultiactivityblock');

  @override
  String bessToString() {
    return 'AssignedMultiActivityBlock: $name, Activities: ${activities.length}';
  }

  @override
  Map<String, dynamic> toJson() {
    final json = toJsonSuper();
    json.addAll({
      'name': name,
      'activities': activities.toList(),
    });
    return json;
  }

  factory AssignedMultiActivityBlock.fromJson(Map<String, dynamic> json, [bool clone = false]) {
    final block = AssignedMultiActivityBlock(
      name: json['name'] as String,
      activities: (json['activities'] as List?)?.cast<String>().toSet() ?? <String>{},
    );
    block.overwriteBessObjectFromJson(json, clone);
    return block;
  }

}
