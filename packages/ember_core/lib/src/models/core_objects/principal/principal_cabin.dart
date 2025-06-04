import 'package:ember_core/ember_core_models.dart';

import '../../../../ember_core_debug.dart';
import '../../interfaces/elevated.dart';

class PrincipalCabin extends CoreObject implements Principal, Elevated{
  final String name;
  final int capacity;

  PrincipalCabin({
    required this.name,
    required this.capacity,
    super.id,
    super.createdAt,
    super.updatedAt,
  }) : super(
    domain: 'brn',
    type: 'principal_cabin',
    idTag: name,
  );

  @override
  String coreToString() {
    return 'Branch cabin: $name, Capacity: $capacity}';
  }

  @override
  Map<String, dynamic> toJson() {
    final json = toJsonSuper();
    json.addAll({
      'name': name,
      'capacity': capacity,
    });
    return json;
  }

  factory PrincipalCabin.fromJson(Map<String, dynamic> json) {
    final branchCabin = PrincipalCabin(
      name: json['name'] as String,
      capacity: json['capacity'] as int,
    );
    branchCabin.overwriteCoreObjectFromJson(json);
    return branchCabin;
  }

  @override
  void purgeRef(String id) {
    Debug.logInfo('Purging $id from ${this.id}');
    Debug.logInfo('unnecessary purge');
  }
}
