import 'package:bessie/data/abstract/bess_object.dart';

import '../roster.dart';
import 'assignable_activity_block.dart';

class Activity extends BessObject {
  final String name;
  final int capacity;
  late Roster roster;
  final AssignableActivityBlock block;

  Activity({
    required this.name,
    required this.capacity,
    required this.block,
    super.id,
    super.createdAt,
    super.updatedAt,
  }) : super(
    idTitle: 'activity-$name',
  ) {
    roster = Roster(title: 'activity-$name');
  }

  @override
  String bessToString() {
    return 'Activity: $name, Capacity: $capacity, Block: ${block.name}';
  }

  @override
  Map<String, dynamic> toJson() {
    final json = toJsonSuper();
    json.addAll({
      'name': name,
      'capacity': capacity,
      // Inline the roster and block JSON.
      'roster': roster.toJson(),
      'block': block.toJson(),
    });
    return json;
  }

  factory Activity.fromJson(Map<String, dynamic> json, [bool clone = false]) {
    Activity activity = Activity(
      name: json['name'] as String,
      capacity: json['capacity'] as int,
      block: AssignableActivityBlock.fromJson(json['block'] as Map<String, dynamic>),
    );
    activity.overwriteBessObjectFromJson(json, clone);
    activity.roster = Roster.fromJson(json['roster'] as Map<String, dynamic>);
    return activity;
  }


}