import 'package:ember_core/ember_core_models.dart';

class AssignedMultiActivityBlock extends ScheduleBlock {
  final Set<String> activityDependantCmps;

  AssignedMultiActivityBlock({
    Set<String>? activityDependantCmps,
    required super.name,
    super.id,
    super.createdAt,
    super.updatedAt,
  })  : activityDependantCmps = activityDependantCmps ?? {},
        super(
          domain: 'ses',
          type: 'AMA_Block',
          idTag: name,
        );

  @override
  String bessToString() {
    return 'AssignedMultiActivityBlock: $name, Activities: ${activityDependantCmps.length}';
  }

  @override
  Map<String, dynamic> toJson() {
    final json = toJsonSuper();
    json.addAll({
      'name': name,
      'activityDependantCmps': activityDependantCmps.toList(),
    });
    return json;
  }

  factory AssignedMultiActivityBlock.fromJson(Map<String, dynamic> json) {
    final block = AssignedMultiActivityBlock(
      name: json['name'] as String,
      activityDependantCmps: (json['activityDependantCmps'] as List?)?.cast<String>().toSet() ?? <String>{},
    );
    block.overwriteBessObjectFromJson(json);
    return block;
  }

  @override
  void purgeRef(String id) {
    // TODO: implement purgeRef
  }

}
