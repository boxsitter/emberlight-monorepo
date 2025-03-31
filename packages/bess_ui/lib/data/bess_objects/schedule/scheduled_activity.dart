import 'package:bessie/data/abstract/bess_object.dart';
import 'package:flutter/material.dart';

class ScheduledActivity extends BessObject {
  final String name;
  final int capacity;
  final Set<String> camperRefs;
  final String blockRef;

  ScheduledActivity({
    required this.name,
    required this.capacity,
    required this.blockRef,
    Set<String>? camperRefs,
    super.id,
    super.createdAt,
    super.updatedAt,
  })  : camperRefs = camperRefs ?? {},
        super(
          domain: 'ses',
          type: 'scheduled_activity',
          idTag: name,
        );

  @override
  String bessToString() {
    return 'Activity: $name, Capacity: $capacity';
  }

  @override
  Map<String, dynamic> toJson() {
    final json = toJsonSuper();
    json.addAll({
      'name': name,
      'capacity': capacity,
      'camperRefs': camperRefs.toList(),
      'blockRef': blockRef,
    });
    return json;
  }

  factory ScheduledActivity.fromJson(Map<String, dynamic> json) {
    ScheduledActivity activity = ScheduledActivity(
      name: json['name'] as String,
      capacity: json['capacity'] as int,
      camperRefs: (json['camperRefs'] as List?)?.cast<String>().toSet() ?? <String>{},
      blockRef: json['blockRef'] as String,
    );
    activity.overwriteBessObjectFromJson(json);
    return activity;
  }
}
