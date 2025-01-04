import 'package:bessie/common/data/models/roster.dart';
import 'package:bessie/features/console/controller/console_controller.dart';

import '../abstract/bess_object.dart';
import 'camper.dart';

class Cabin extends BessObject {
  String name;
  int capacity;
  Roster roster;

  Cabin({
    this.name = '',
    this.capacity = 0,
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

  void addCamper(Camper camper) {
    if((roster.size + 1) > capacity) {
      //TODO: Over capacity conflict
      ConsoleController().error('$name is already at capacity');
    } else if (camper.cabin == null) {
      roster.addCamper(camper);
      camper.cabin = this;
    } else {
      camper.cabin?.removeCamper(camper);
      addCamper(camper);
    }
  }

  void removeCamper(Camper camper) {
    roster.removeCamper(camper);
    camper.cabin = null;
  }
}