import 'package:bessie/data/abstract/bess_object.dart';
import 'package:bessie/data/models/roster.dart';
import 'package:bessie/data/models/schedule/schedule.dart';

import 'cabin.dart';

class Session extends BessObject{
  String name;
  late final Roster sessionRoster;
  final Map<String, Cabin> cabins = {};
  late final Schedule schedule;

  Session({
    required BessObject dataParent,
    required this.name,
  }) : super('Session-$name', dataParent) {
    sessionRoster = Roster(
      dataParent: this,
      title: 'Session Master Roster'
    );
    schedule = Schedule(dataParent: this);
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