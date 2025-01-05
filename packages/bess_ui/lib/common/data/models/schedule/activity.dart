import 'package:bessie/common/data/abstract/bess_object.dart';

import '../roster.dart';
import 'assignable_activity_block.dart';

class Activity extends BessObject {
  final String name;
  final int capacity;
  Roster roster;
  final AssignableActivityBlock assignableActivityBlock;

  Activity({
    required this.name,
    required this.capacity,
    required this.assignableActivityBlock,
  }) : roster = Roster(title: '$name Roster'), super('activity-$name');

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