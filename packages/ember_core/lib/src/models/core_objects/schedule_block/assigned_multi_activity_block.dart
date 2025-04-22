import 'package:ember_core/ember_core_models.dart';

class AssignedMultiActivityBlock extends CoreObject implements ScheduleBlock {
  @override
  final String name;
  @override
  final bool isTemplate;
  final Set<String> activityDependentCmps;

  AssignedMultiActivityBlock({
    required this.name,
    required this.isTemplate,
    Set<String>? activityDependentCmps,
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
      'isTemplate': isTemplate,
      'activityDependentCmps': activityDependentCmps.toList(),
    });
    return json;
  }

  factory AssignedMultiActivityBlock.fromJson(Map<String, dynamic> json) {
    final block = AssignedMultiActivityBlock(
      name: json['name'] as String,
      isTemplate: json['isTemplate'],
      activityDependentCmps: (json['activityDependentCmps'] as List?)?.cast<String>().toSet() ?? <String>{},
    );
    block.overwriteCoreObjectFromJson(json);
    return block;
  }

  @override
  void purgeRef(String id) {
    print('Purging $id from ${this.id}');
    // TODO: implement purgeRef
  }

}
