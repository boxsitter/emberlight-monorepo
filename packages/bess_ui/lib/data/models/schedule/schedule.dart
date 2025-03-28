import '../../abstract/bess_object.dart';

typedef BlockId = String;
typedef UniqueActivityTypeId = String;

class Schedule extends BessObject {
  List<BlockId> blockIds;
  Set<UniqueActivityTypeId> uniqueActivityTypeIds;

  Schedule({
    List<BlockId>? blocks,
    super.id,
    super.createdAt,
    super.updatedAt,
    Set<UniqueActivityTypeId>? uniqueActivityTypes,
  })  : blockIds = blocks ?? [],
        uniqueActivityTypeIds = uniqueActivityTypes ?? {},
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
      'uniqueActivityTypes': uniqueActivityTypeIds.toList(),
    });
    return json;
  }

  factory Schedule.fromJson(Map<String, dynamic> json, [bool clone = false]) {
    final schedule = Schedule(
      blocks: (json['blocks'] as List?)?.cast<BlockId>() ?? <BlockId>[],
      uniqueActivityTypes: (json['uniqueActivityTypes'] as List?)?.cast<UniqueActivityTypeId>().toSet() ?? <UniqueActivityTypeId>{},
    );
    schedule.overwriteBessObjectFromJson(json, clone);
    return schedule;
  }
}
