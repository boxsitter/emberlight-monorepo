import 'package:bessie/common/data/abstract/schedule_block.dart';

import '../../abstract/bess_object.dart';

class Schedule extends BessObject {
  Map<String, ScheduleBlock> blocks; //TODO: replace with a list of days

  Schedule() : blocks = {}, super('schedule');



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