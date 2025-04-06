import 'package:ember_core/ember_core_models.dart';
import 'package:ember_core/src/models/core_objects/principal/principal_activity.dart';

typedef BlockId = String;

class Schedule extends CoreObject {
  List<BlockId> blockCmps;
  Set<ActivityTypeId> uniqueActivityTypeRefs;

  Schedule({
    List<BlockId>? blockCmps,
    Set<ActivityTypeId>? uniqueActivityTypeRefs,
    super.id,
    super.createdAt,
    super.updatedAt,
  })  : blockCmps = blockCmps ?? [],
        uniqueActivityTypeRefs = uniqueActivityTypeRefs ?? {},
        super(
          domain: 'ses',
          type: 'schedule',
          idTag: 'schedule',
        );

  @override
  String coreToString() {
    return 'Schedule with ${blockCmps.length} block(s)';
  }

  @override
  Map<String, dynamic> toJson() {
    final json = toJsonSuper();
    json.addAll({
      'blockCmps': blockCmps,
      'uniqueActivityTypeRefs': uniqueActivityTypeRefs.toList(),
    });
    return json;
  }

  factory Schedule.fromJson(Map<String, dynamic> json) {
    final schedule = Schedule(
      blockCmps: (json['blockCmps'] as List?)?.cast<BlockId>() ?? <BlockId>[],
      uniqueActivityTypeRefs: (json['uniqueActivityTypeRefs'] as List?)?.cast<ActivityTypeId>().toSet() ?? <ActivityTypeId>{},
    );
    schedule.overwriteCoreObjectFromJson(json);
    return schedule;
  }

  @override
  void purgeRef(String id) {
    // TODO: implement purgeRef
  }
}
