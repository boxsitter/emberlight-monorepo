import 'package:bessie/common/data/abstract/bess_object.dart';
import 'package:bessie/common/data/models/roster.dart';
import 'package:bessie/common/data/models/schedule/schedule.dart';

import 'cabin.dart';

class Session extends BessObject{
  String name;
  Roster sessionRoster = Roster(title: 'Session Master');
  final Map<String, Cabin> cabins;
  Schedule schedule = Schedule();

  Session({required this.name}) : cabins = {}, super('Session-$name');

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