import 'package:bessie/data/abstract/schedule_block.dart';

import 'activity.dart';

class AssignableActivityBlock extends ScheduleBlock {
  Map<String, Activity> activities;

  AssignableActivityBlock({
    required super.name,
  }) : activities = {}, super(idTitle: 'assignableactivityblock-$name');

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