import '../../abstract/bess_object.dart';

typedef BlockId = String;
typedef ActivityTypeRef = String;

class Schedule extends BessObject {
  List<BlockId> blockCmps;
  Set<ActivityTypeRef> uniqueActivityTypeRefs;

  Schedule({
    List<BlockId>? blockCmps,
    Set<ActivityTypeRef>? uniqueActivityTypeRefs,
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
  String bessToString() {
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
      uniqueActivityTypeRefs: (json['uniqueActivityTypeRefs'] as List?)?.cast<ActivityTypeRef>().toSet() ?? <ActivityTypeRef>{},
    );
    schedule.overwriteBessObjectFromJson(json);
    return schedule;
  }
}
