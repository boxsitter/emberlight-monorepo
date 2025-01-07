import 'package:bessie/common/data/models/roster.dart';

import '../abstract/bess_object.dart';
import 'camper.dart';

class Cabin extends BessObject {
  final String name;
  final int capacity;
  late final Roster roster;

  int get length => roster.length;
  Iterable<Camper> get campers => roster.values;

  Cabin({
    required BessObject dataParent,
    required this.name,
    required this.capacity,
  }) : super('Cabin-$name', dataParent) {
      roster = Roster(
          dataParent: this,
          title: name
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