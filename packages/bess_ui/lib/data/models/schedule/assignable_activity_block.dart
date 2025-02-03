import 'package:bessie/data/abstract/schedule_block.dart';

import '../../abstract/bess_object.dart';
import 'activity.dart';

class AssignableActivityBlock extends ScheduleBlock {
  Map<String, Activity> activities;

  AssignableActivityBlock({
    required BessObject dataParent,
    required String name,
  }) : activities = {}, super('assignableactivityblock-$name', dataParent, name: name);

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