import 'package:bessie/data/abstract/bess_object.dart';

import '../roster.dart';
import 'assignable_activity_block.dart';

class Activity extends BessObject {
  final String name;
  final int capacity;
  final Set<String> camperIds;
  final String blockId;

  Activity({
    required this.name,
    required this.capacity,
    required this.blockId,
    this.camperIds = const {},
    super.id,
    super.createdAt,
    super.updatedAt,
  }) : super(idTitle: 'activity-$name',);

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
      'camperIds': camperIds.toList(),
      'blockId': blockId,
    });
    return json;
  }

  factory Activity.fromJson(Map<String, dynamic> json, [bool clone = false]) {
    Activity activity = Activity(
      name: json['name'] as String,
      capacity: json['capacity'] as int,
      camperIds: (json['camperIds'] as List?)?.cast<String>().toSet() ?? <String>{},
      blockId: json['blockId'] as String,
    );
    activity.overwriteBessObjectFromJson(json, clone);
    return activity;
  }


}