import 'package:ember_core/ember_core_models.dart';

typedef BlockId = String;

class Schedule extends CoreObject {
  List<BlockId> blockCmps;
  Set<PrincipalActivityId> principalActivityRefs;

  Schedule({
    List<BlockId>? blockCmps,
    Set<PrincipalActivityId>? principalActivityRefs,
    super.id,
    super.createdAt,
    super.updatedAt,
  })  : blockCmps = blockCmps ?? [],
        principalActivityRefs = principalActivityRefs ?? {},
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
      'principalActivityRefs': principalActivityRefs.toList(),
    });
    return json;
  }

  factory Schedule.fromJson(Map<String, dynamic> json) {
    final schedule = Schedule(
      blockCmps: (json['blockCmps'] as List?)?.cast<BlockId>() ?? <BlockId>[],
      principalActivityRefs: (json['principalActivityRefs'] as List?)?.cast<PrincipalActivityId>().toSet() ?? <PrincipalActivityId>{},
    );
    schedule.overwriteCoreObjectFromJson(json);
    return schedule;
  }

  @override
  void purgeRef(String id) {
    principalActivityRefs.remove(id);
  }
}
