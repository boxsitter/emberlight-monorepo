import 'package:bessie/data/abstract/bess_object.dart';

import '../roster.dart';
import 'assignable_activity_block.dart';

class Activity extends BessObject {
  final String name;
  final int capacity;
  late final Roster roster;
  final AssignableActivityBlock block;

  Activity({
    required this.name,
    required this.capacity,
    required this.block,
  }) : super(idTitle: 'activity-$name') {
    roster = Roster(
      title: '$name Roster',
    );
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