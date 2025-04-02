import 'package:ember_core/ember_core_models.dart';

typedef ActivityTypeId = String;

class ActivityType extends BessObject {
  final String name;
  final int capacity;
  final String description;

  ActivityType({
    required this.name,
    required this.capacity,
    required this.description,
    super.objId,
    super.createdAt,
    super.updatedAt,
  })  : super(
          domain: 'brn',
          type: 'activity_type',
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
      'description': description,
    });
    return json;
  }

  factory ActivityType.fromJson(Map<String, dynamic> json) {
    ActivityType activity = ActivityType(
      name: json['name'] as String,
      capacity: json['capacity'] as int,
      description: json['description'] as String,
    );
    activity.overwriteBessObjectFromJson(json);
    return activity;
  }

  @override
  void purgeRef(String ref) {
    // TODO: implement purgeRef
  }
}
