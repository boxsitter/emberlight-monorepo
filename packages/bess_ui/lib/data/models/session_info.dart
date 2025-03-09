import 'package:bessie/data/abstract/bess_object.dart';
import 'package:bessie/data/models/roster.dart';
import 'package:bessie/data/models/schedule/schedule.dart';

import 'cabin.dart';

class SessionInfo extends BessObject{
  String name;
  late final Roster sessionRoster;
  final Map<String, Cabin> cabins = {};
  late final Schedule schedule;

  SessionInfo({
    required this.name,
  }) : super(idTitle: 'Session-$name') {
    sessionRoster = Roster(
      title: 'Session Master Roster'
    );
    schedule = Schedule();
  }

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