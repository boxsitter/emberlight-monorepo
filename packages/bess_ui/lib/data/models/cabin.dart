import 'package:bessie/data/models/roster.dart';

import '../abstract/bess_object.dart';
import 'camper.dart';

class Cabin extends BessObject {
  final String name;
  final int capacity;
  late final Roster roster;

  int get camperCount => roster.length;
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

  factory Cabin.fromJson(Map<String, dynamic> json, [bool clone = false]) {
    final cabin = Cabin(
      name: json['name'] as String,
      capacity: json['capacity'] as int,
    );

    // Let the superclass handle id, createdAt, and updatedAt.
    cabin.overwriteBessObjectFromJson(json, clone);

    // Use roster's fromJson method to reconstruct the cabin roster.
    if (json['roster'] != null) {
      cabin.roster = Roster.fromJson(json['roster'] as Map<String, dynamic>);
      // For each camper in the roster, assign this cabin's id.
      for (var camper in cabin.roster.campers.values) {
        camper.cabinId = cabin.id;
      }
    }

    return cabin;
  }

}