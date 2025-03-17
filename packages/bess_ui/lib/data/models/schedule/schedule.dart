import '../../abstract/bess_object.dart';
import '../../abstract/schedule_block.dart';
import 'assignable_activity_block.dart';

class Schedule extends BessObject {
  Map<String, ScheduleBlock> blocks;

  Schedule({
    super.id,
    super.createdAt,
    super.updatedAt,
  })  : blocks = {},
        super(
        idTitle: 'schedule',
      );

  @override
  String bessToString() {
    return 'Schedule with ${blocks.length} block(s)';
  }

  @override
  Map<String, dynamic> toJson() {
    final json = toJsonSuper();
    json.addAll({
      'blocks': blocks.map((key, block) => MapEntry(key, block.toJson())),
    });
    return json;
  }

  factory Schedule.fromJson(Map<String, dynamic> json, [bool clone = false]) {
    final schedule = Schedule();
    schedule.overwriteBessObjectFromJson(json, clone);
    if (json.containsKey('blocks')) {
      final blocksJson = json['blocks'] as Map<String, dynamic>;
      blocksJson.forEach((key, blockJson) {
        schedule.blocks[key] = AssignableActivityBlock.fromJson(blockJson as Map<String, dynamic>);
      });
    }
    return schedule;
  }
}