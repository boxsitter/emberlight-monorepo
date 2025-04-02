import 'package:ember_core/ember_core_models.dart';

class AssignedMultiActivityBlock extends ScheduleBlock {
  final Set<String> scheduledActivityCmps;

  AssignedMultiActivityBlock({
    Set<String>? scheduledActivityCmps,
    required super.name,
    super.objId,
    super.createdAt,
    super.updatedAt,
  })  : scheduledActivityCmps = scheduledActivityCmps ?? {},
        super(
          domain: 'ses',
          type: 'AMA_Block',
          idTag: name,
        );

  @override
  String bessToString() {
    return 'AssignedMultiActivityBlock: $name, Activities: ${scheduledActivityCmps.length}';
  }

  @override
  Map<String, dynamic> toJson() {
    final json = toJsonSuper();
    json.addAll({
      'name': name,
      'scheduledActivityCmps': scheduledActivityCmps.toList(),
    });
    return json;
  }

  factory AssignedMultiActivityBlock.fromJson(Map<String, dynamic> json) {
    final block = AssignedMultiActivityBlock(
      name: json['name'] as String,
      scheduledActivityCmps: (json['scheduledActivityCmps'] as List?)?.cast<String>().toSet() ?? <String>{},
    );
    block.overwriteBessObjectFromJson(json);
    return block;
  }

  @override
  void purgeRef(String ref) {
    // TODO: implement purgeRef
  }

}
