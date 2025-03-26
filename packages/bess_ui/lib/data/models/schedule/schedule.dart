import '../../abstract/bess_object.dart';

class Schedule extends BessObject {
  final List<String> blocks;

  Schedule({
    List<String>? blocks,
    super.id,
    super.createdAt,
    super.updatedAt,
  })  : blocks = blocks ?? [],
        super(idTitle: 'schedule');

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
