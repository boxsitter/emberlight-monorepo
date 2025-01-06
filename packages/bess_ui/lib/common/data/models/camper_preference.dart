import 'package:bessie/common/data/abstract/bess_object.dart';
import 'package:bessie/common/data/models/schedule/activity.dart';
import 'package:bessie/common/data/models/schedule/assignable_activity_block.dart';

import 'camper.dart';

// Represents a camper's preference for each activity in a given AssignableActivityBlock
class CamperPreference extends BessObject {
  final Camper camper;
  final AssignableActivityBlock block;
  final Map<Activity, int?> preferences = {};
  final Set<int> seenValues = <int>{};
  // true when the camper has indicated their preference for every activity in the block
  bool completed = false;

  CamperPreference({required this.camper, required this.block}) : super('CamperPreference-${camper.lastName}-${camper.firstName}');

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