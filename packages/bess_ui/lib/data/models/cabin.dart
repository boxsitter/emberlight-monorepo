import 'package:flutter/material.dart';

import '../abstract/bess_object.dart';

class Cabin extends BessObject {
  final String name;
  final int capacity;
  final Set<String> camperIds;
  int campersWithPreferencesCount;

  Cabin({
    required this.name,
    required this.capacity,
    Set<String>? camperIds,
    this.campersWithPreferencesCount = 0,
    super.id,
    super.createdAt,
    super.updatedAt,
  })  : camperIds = camperIds ?? {},
        super(idTitle: 'cabin-$name');

  @override
  String bessToString() {
    return 'Cabin: $name, Capacity: $capacity}';
  }

  @override
  Map<String, dynamic> toJson() {
    final json = toJsonSuper();
    json.addAll({
      'name': name,
      'capacity': capacity,
      'camperIds': camperIds.toList(),
      'campersWithPreferencesCount': campersWithPreferencesCount,
    });
    return json;
  }

  factory Cabin.fromJson(Map<String, dynamic> json, [bool clone = false]) {
    final cabin = Cabin(
      name: json['name'] as String,
      capacity: json['capacity'] as int,
      camperIds: (json['camperIds'] as List?)?.cast<String>().toSet() ?? <String>{},
      campersWithPreferencesCount: json['campersWithPreferencesCount'] as int,
    );
    cabin.overwriteBessObjectFromJson(json, clone);
    return cabin;
  }
}
