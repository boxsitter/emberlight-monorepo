import 'package:bessie/common/data/abstract/schedule_block.dart';

import 'activity.dart';

class AssignableActivityBlock extends ScheduleBlock {
  Map<String, Activity> activities;

  AssignableActivityBlock({required String name}) : activities = {}, super('assignableactivityblock-$name', name: name);

  @override
  String bessToString() {
    // TODO: implement bessToString
    throw UnimplementedError();
  }

  @override
  Map<String, dynamic> toJson() {
    // TODO: implement toJson
    throw UnimplementedError();
  }

}