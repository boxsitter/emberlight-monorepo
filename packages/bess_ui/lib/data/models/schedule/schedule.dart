import '../../abstract/bess_object.dart';
import '../../abstract/schedule_block.dart';
import 'assignable_activity_block.dart';

class Schedule extends BessObject {
  Map<String, ScheduleBlock> blocks;

  Schedule({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : blocks = {},
        super(
        idTitle: 'schedule',
        id: id,
        createdAt: createdAt,
        updatedAt: updatedAt,
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

  factory Schedule.fromJson(Map<String, dynamic> json) {
    final schedule = Schedule(
      id: json['id'] as String,
      createdAt: DateTime.tryParse(json['createdAt'] as String),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String),
    );
    if (json.containsKey('blocks')) {
      final blocksJson = json['blocks'] as Map<String, dynamic>;
      blocksJson.forEach((key, blockJson) {
        // For now, we assume all blocks are AssignableActivityBlocks.
        schedule.blocks[key] = AssignableActivityBlock.fromJson(blockJson as Map<String, dynamic>);
      });
    }
    return schedule;
  }

}