import '../../ember_core.dart';
import '../models/core_objects/schedule_day.dart';

class HardcodedSchedule {
  static final ScheduleDay day1 = ScheduleDay(
    id: '0_wednesday-schedule_day-ses-Nned9WU',
    start: DateTime.now(),
    end: DateTime.now(),
    dayIndex: 0,
  );

  static final AMABlock choiceActivity = AMABlock(
    id: 'choice_activity_1-ama_block-ses-NnRd9WU',
    title: 'Choice Activity 1',
    isTemplate: false,
    start: DateTime.now(),
    end: DateTime.now(),
    isSkillsRec: false,
  );
}