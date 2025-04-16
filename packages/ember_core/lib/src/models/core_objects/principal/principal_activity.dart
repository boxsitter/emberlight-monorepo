import 'package:ember_core/ember_core_models.dart';

import '../../abstract/elevated.dart';
import '../../abstract/principal.dart';

typedef ActivityTypeId = String;

class PrincipalActivity extends CoreObject implements Principal{
  final String name;
  final int capacity;
  final String description;

  PrincipalActivity({
    required this.name,
    required this.capacity,
    required this.description,
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
    });
    return json;
  }

  factory PrincipalActivity.fromJson(Map<String, dynamic> json) {
    PrincipalActivity activity = PrincipalActivity(
      name: json['name'] as String,
      capacity: json['capacity'] as int,
      description: json['description'] as String,
    );
    activity.overwriteCoreObjectFromJson(json);
    return activity;
  }

  @override
  void purgeRef(String id) {
    // TODO: implement purgeRef
  }
}
