import '../../abstract/bess_object.dart';
import '../../abstract/schedule_block.dart';

class Schedule extends BessObject {
  Map<String, ScheduleBlock> blocks = {};

  Schedule() : super(idTitle: 'schedule');



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