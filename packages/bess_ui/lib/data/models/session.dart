import 'package:bessie/data/abstract/bess_object.dart';
import 'package:bessie/data/models/roster.dart';
import 'package:bessie/data/models/schedule/schedule.dart';

import 'cabin.dart';

class Session extends BessObject{
  String name;
  late final Roster sessionRoster;
  final Map<String, Cabin> cabins;
  late final Schedule schedule;

  Session({
    required this.name,
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : cabins = {},
        super(
        idTitle: 'session-$name',
        id: id,
        createdAt: createdAt,
        updatedAt: updatedAt,
      ) {
    sessionRoster = Roster(title: 'Session Master Roster');
    schedule = Schedule(); // Assuming Schedule() has a default constructor.
  }

  @override
  String bessToString() {
    return 'Session: $name\nRoster:\n${sessionRoster.bessToString()}\n'
        'Cabins: ${cabins.length} cabin(s)\nSchedule: ${schedule.toString()}';
  }

  @override
  Map<String, dynamic> toJson() {
    final json = toJsonSuper();
    json.addAll({
      'name': name,
      'sessionRoster': sessionRoster.toJson(),
      'cabins': cabins.map((key, cabin) => MapEntry(key, cabin.toJson())),
      'schedule': schedule.toJson(),
    });
    return json;
  }
   // TODO: This is raw Ai so check this
  factory Session.fromJson(Map<String, dynamic> json) {
    final session = Session(
      name: json['name'] as String,
      id: json['id'] as String,
      createdAt: DateTime.tryParse(json['createdAt'] as String),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String),
    );
    if (json.containsKey('sessionRoster')) {
      session.sessionRoster =
          Roster.fromJson(json['sessionRoster'] as Map<String, dynamic>);
    }
    if (json.containsKey('cabins')) {
      final cabinsJson = json['cabins'] as Map<String, dynamic>;
      cabinsJson.forEach((key, cabinJson) {
        session.cabins[key] =
            Cabin.fromJson(cabinJson as Map<String, dynamic>);
      });
    }
    if (json.containsKey('schedule')) {
      session.schedule =
          Schedule.fromJson(json['schedule'] as Map<String, dynamic>);
    }
    return session;
  }
}