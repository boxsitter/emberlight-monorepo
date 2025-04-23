import 'package:ember_core/ember_core_models.dart';

import '../../../ember_core_utils.dart';
import '../abstract/time_interval.dart';

typedef ScheduleDayId = String;

class ScheduleDay extends CoreObject implements TimeInterval {
  int dayIndex;
  @override
  DateTime start;
  @override
  DateTime end;
  List<BlockId> blockCmps;

  ScheduleDay({
    required this.dayIndex,
    required this.start,
    required this.end,
    List<BlockId>? blockCmps,
    super.id,
    super.createdAt,
    super.updatedAt,
  })  : blockCmps = blockCmps ?? [],
        super(
        domain: 'ses',
        type: 'schedule_day',
        idTag: '${dayIndex}_${CoreFormatter.weekdayToString(start.weekday, true)}',
      );

  @override
  String coreToString() {
    throw UnimplementedError();
  }

  @override
  Map<String, dynamic> toJson() {
    final json = toJsonSuper();
    json.addAll({
      'dayIndex': dayIndex,
      'start': start,
      'end': end,
      'blockCmps': blockCmps,
    });
    return json;
  }

  factory ScheduleDay.fromJson(Map<String, dynamic> json) {
    final scheduleDay = ScheduleDay(
      dayIndex: json['dayIndex'] as int,
      start: json['start'] as DateTime,
      end: json['end'] as DateTime,
      blockCmps: (json['blockCmps'] as List?)?.cast<BlockId>() ?? <BlockId>[],
    );
    scheduleDay.overwriteCoreObjectFromJson(json);
    return scheduleDay;
  }

  @override
  void purgeRef(String id) {
    blockCmps.remove(id);
  }
}