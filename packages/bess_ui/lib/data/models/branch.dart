import 'package:bessie/data/abstract/bess_object.dart';
import 'package:bessie/data/models/schedule/activity_type.dart';

class Branch extends BessObject {
  final String name;
  final Set<String> seasons;
  final Set<ActivityTypeId> activityTypeIds;

  Branch({
    required this.name,
    Set<String>? seasons,
    Set<ActivityTypeId>? activityTypeIds,
    super.id,
    super.createdAt,
    super.updatedAt,
  })  : seasons = seasons ?? {},
        activityTypeIds = activityTypeIds ?? {},
        super(idTitle: 'branch-$name');

  @override
  String bessToString() {
    return 'Branch: $name';
  }

  @override
  Map<String, dynamic> toJson() {
    final json = toJsonSuper();
    json.addAll({
      'name': name,
      'seasons': seasons.toList(),
      'activityTypeIds': activityTypeIds.toList(),
    });
    return json;
  }

  factory Branch.fromJson(Map<String, dynamic> json, [bool clone = false]) {
    final branch = Branch(
      name: json['name'] as String,
      seasons: (json['seasons'] as List?)?.cast<String>().toSet() ?? <String>{},
      activityTypeIds: (json['activityTypeIds'] as List?)?.cast<ActivityTypeId>().toSet() ?? <ActivityTypeId>{},
    );
    branch.overwriteBessObjectFromJson(json, clone);
    return branch;
  }
}
