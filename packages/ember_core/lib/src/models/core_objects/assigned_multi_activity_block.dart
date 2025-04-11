import 'package:ember_core/ember_core_models.dart';

class AssignedMultiActivityBlock extends ScheduleBlock {
  final Set<String> activityDependentCmps;

  AssignedMultiActivityBlock({
    Set<String>? activityDependentCmps,
    required super.name,
    super.id,
    super.createdAt,
    super.updatedAt,
  })  : activityDependentCmps = activityDependentCmps ?? {},
        super(
          domain: 'ses',
          type: 'AMA_Block',
          idTag: name,
        );

  @override
  String coreToString() {
    return 'AssignedMultiActivityBlock: $name, Activities: ${activityDependentCmps.length}';
  }

  @override
  Map<String, dynamic> toJson() {
    final json = toJsonSuper();
    json.addAll({
      'name': name,
      'activityDependentCmps': activityDependentCmps.toList(),
    });
    return json;
  }

  factory AssignedMultiActivityBlock.fromJson(Map<String, dynamic> json) {
    final block = AssignedMultiActivityBlock(
      name: json['name'] as String,
      activityDependentCmps: (json['activityDependentCmps'] as List?)?.cast<String>().toSet() ?? <String>{},
    );
    block.overwriteCoreObjectFromJson(json);
    return block;
  }

  @override
  void purgeRef(String id) {
    // TODO: implement purgeRef
  }

}
