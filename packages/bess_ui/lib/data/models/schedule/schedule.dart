import '../../abstract/bess_object.dart';

typedef BlockId = String;
typedef ActivityTypeId = String;

class Schedule extends BessObject {
  List<BlockId> blockIds;
  Set<ActivityTypeId> uniqueActivityTypeIds;

  Schedule({
    List<BlockId>? blocks,
    super.id,
    super.createdAt,
    super.updatedAt,
    Set<ActivityTypeId>? activityTypes,
  })  : blockIds = blocks ?? [],
        uniqueActivityTypeIds = activityTypes ?? {},
        super(idTitle: 'schedule');

  @override
  String bessToString() {
    return 'Schedule with ${blockIds.length} block(s)';
  }

  @override
  Map<String, dynamic> toJson() {
    final json = toJsonSuper();
    json.addAll({
      'blocks': blockIds,
      'activityTypes': uniqueActivityTypeIds.toList(),
    });
    return json;
  }

  factory Schedule.fromJson(Map<String, dynamic> json, [bool clone = false]) {
    final schedule = Schedule(
      blocks: (json['blocks'] as List?)?.cast<BlockId>() ?? <BlockId>[],
      activityTypes: (json['activityTypes'] as List?)?.cast<ActivityTypeId>().toSet() ?? <ActivityTypeId>{},
    );
    schedule.overwriteBessObjectFromJson(json, clone);
    return schedule;
  }
}
