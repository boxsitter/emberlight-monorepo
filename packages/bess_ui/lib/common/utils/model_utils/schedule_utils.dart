import 'package:bessie/common/data/models/schedule/assignable_activity_block.dart';

import '../../data/models/schedule/activity.dart';

class ScheduleUtils {
  static void addActivityToBlock(AssignableActivityBlock block, Activity activityToAdd) {
    if (activityToAdd.assignableActivityBlock == null) {
      block.activities[activityToAdd.id] = activityToAdd;
      activityToAdd.assignableActivityBlock = block;
    } else {
      removeActivityFromBlock(activityToAdd.assignableActivityBlock!, activityToAdd);
      addActivityToBlock(block, activityToAdd);
    }
  }

  static void removeActivityFromBlock(AssignableActivityBlock block, Activity activityToRemove) {
    block.activities.remove(activityToRemove.id);
    activityToRemove.assignableActivityBlock = null;
  }
}