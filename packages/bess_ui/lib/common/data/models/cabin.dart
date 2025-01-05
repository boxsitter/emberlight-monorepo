import 'package:bessie/common/data/models/roster.dart';
import 'package:bessie/features/console/controller/console_controller.dart';

import '../abstract/bess_object.dart';
import 'camper.dart';

class Cabin extends BessObject {
  String name;
  int capacity;
  Roster roster;

  Cabin({
    required this.name,
    required this.capacity,
  }) : roster = Roster(title: name), super('Cabin-$name');

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