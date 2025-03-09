import 'package:bessie/data/models/roster.dart';

import '../abstract/bess_object.dart';
import 'camper.dart';

class Cabin extends BessObject {
  final String name;
  final int capacity;
  late final Roster roster;

  int get length => roster.length;
  Iterable<Camper> get campers => roster.values;

  Cabin({
    required this.name,
    required this.capacity,
  }) : super(idTitle: 'Cabin-$name') {
    roster = Roster(title: name);
  }

  @override
  String bessToString() {
    return 'Cabin: $name, Capacity: $capacity\nRoster:\n${roster.bessToString()}';
  }

  @override
  Map<String, dynamic> toJson() {
    final json = toJsonSuper();
    json.addAll({
      'name': name,
      'capacity': capacity,
      'roster': roster.toJson(),
    });
    return json;
  }

  factory Cabin.fromJson(Map<String, dynamic> json) {
    final cabin = Cabin(
      name: json['name'] as String,
      capacity: json['capacity'] as int,
    );

    // use roster's fromJson method to reconstruct the cabin roster
    if (json['roster'] != null) {
      cabin.roster = Roster.fromJson(json['roster'] as Map<String, dynamic>);
      // for each camper in the roster, assign this cabin.
      for (var camper in cabin.roster.campers.values) {
        camper.cabin = cabin;
      }
    }
    return cabin;
  }

}