import '../../abstract/bess_object.dart';
import '../../abstract/schedule_block.dart';
import 'assignable_activity_block.dart';

class Schedule extends BessObject {
  final List<String> blocks;

  Schedule({
    this.blocks = const [],
    super.id,
    super.createdAt,
    super.updatedAt,
  })  : super(idTitle: 'schedule',);

  @override
  String bessToString() {
    return 'Schedule with ${blocks.length} block(s)';
  }

  @override
  Map<String, dynamic> toJson() {
    final json = toJsonSuper();
    json.addAll({
      'blocks': blocks,
    });
    return json;
  }

  factory Schedule.fromJson(Map<String, dynamic> json, [bool clone = false]) {
    final schedule = Schedule(
      blocks: (json['blocks'] as List?)?.cast<String>() ?? <String>[],
    );
    schedule.overwriteBessObjectFromJson(json, clone);
    return schedule;
  }
}