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
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super(
    idTitle: 'activity-$name',
    id: id,
    createdAt: createdAt,
    updatedAt: updatedAt,
  ) {
    // Initialize the roster with a title based on this activity.
    roster = Roster(title: '$name Roster');
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

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      name: json['name'] as String,
      capacity: json['capacity'] as int,
      block: AssignableActivityBlock.fromJson(json['block'] as Map<String, dynamic>),
      id: json['id'] as String,
      createdAt: DateTime.tryParse(json['createdAt'] as String),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String),
    )..roster = Roster.fromJson(json['roster'] as Map<String, dynamic>);
  }

}