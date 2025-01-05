import 'package:bessie/common/utils/model_utils/schedule_utils.dart';
import 'package:get/get.dart';

import '../../../common/data/models/local_data.dart';
import '../../../common/data/models/schedule/activity.dart';
import '../../../common/data/models/schedule/assignable_activity_block.dart';
import '../../../common/data/models/schedule/schedule.dart';

class ScheduleController extends GetxController {
  final LocalData localData = Get.find<LocalData>();

  Schedule _getSchedule() {
    return localData.session!.schedule;
  }

  void initializeSessionForTesting() {
    AssignableActivityBlock testChoiceActivity = AssignableActivityBlock(name: 'Test Choice Activity');
    _getSchedule().blocks[testChoiceActivity.id] = testChoiceActivity;

    ScheduleUtils.addActivityToBlock(testChoiceActivity, Activity(name: 'Gaga Ball', capacity: 6,));
    ScheduleUtils.addActivityToBlock(testChoiceActivity, Activity(name: 'Boating', capacity: 8,));
    ScheduleUtils.addActivityToBlock(testChoiceActivity, Activity(name: 'OLS', capacity: 8,));
    ScheduleUtils.addActivityToBlock(testChoiceActivity, Activity(name: 'Arts and Crafts', capacity: 8,));
  }
}