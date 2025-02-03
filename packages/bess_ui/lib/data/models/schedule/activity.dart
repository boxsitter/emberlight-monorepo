import 'package:bessie/data/abstract/bess_object.dart';

import '../roster.dart';
import 'assignable_activity_block.dart';

class Activity extends BessObject {
  final String name;
  final int capacity;
  late final Roster roster;
  final AssignableActivityBlock block;

  Activity({
    required BessObject dataParent,
    required this.name,
    required this.capacity,
    required this.block,
  }) : super('activity-$name', dataParent) {
    roster = Roster(
      dataParent: this,
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