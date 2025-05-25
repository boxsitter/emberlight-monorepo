import '../../ember_core_models.dart';
import '../models/core_objects/schedule_day.dart';

class HardcodedSchedule {
  static final ScheduleDay day1 = ScheduleDay(
    start: DateTime.now(),
    end: DateTime.now(),
    dayIndex: 0,
  );

  static final AMABlock choiceActivity = AMABlock(
    name: 'Choice Activity 1',
    isTemplate: false,
    start: DateTime.now(),
    end: DateTime.now(),
    isSkillsRec: false,
  );
}