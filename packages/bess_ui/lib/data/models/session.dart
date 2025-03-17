import 'package:bessie/data/abstract/bess_object.dart';
import 'package:bessie/data/models/roster.dart';
import 'package:bessie/data/models/schedule/schedule.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'cabin.dart';

class Session extends BessObject {
  String name;
  DateTime startDate;
  DateTime endDate;
  final List<String> cabinsInUse;
  late final Schedule schedule;
  Roster roster;

  Session({
    required this.name,
    required this.startDate,
    required this.endDate,
    super.id,
    super.createdAt,
    super.updatedAt,
  })  : cabinsInUse = [],
        roster = Roster(title: 'Session Roster'),
        super(
        idTitle: 'session-$name',
      ) {
    schedule = Schedule();
  }

  @override
  String bessToString() {
    return 'Session: $name';
  }

  @override
  Map<String, dynamic> toJson() {
    final json = toJsonSuper();
    json.addAll({
      'name': name,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'cabins': cabinsInUse,
      'roster': roster.toJson(),
      'schedule': schedule.toJson(),
    });
    return json;
  }

  factory Session.fromJson(Map<String, dynamic> json, [bool clone = false]) {
    final session = Session(
      name: json['name'] as String,
      startDate: (json['startDate'] as Timestamp).toDate(),
      endDate: (json['endDate'] as Timestamp).toDate(),
    );
    session.overwriteBessObjectFromJson(json, clone);

    if (json.containsKey('cabins')) {
      final cabinsJson = json['cabins'] as List<dynamic>;
      session.cabinsInUse.addAll(cabinsJson.map((e) => e as String));
    }
    if (json.containsKey('roster')) {
      session.roster = Roster.fromJson(json['roster'] as Map<String, dynamic>);
    }
    if (json.containsKey('schedule')) {
      session.schedule = Schedule.fromJson(json['schedule'] as Map<String, dynamic>);
    }

    return session;
  }
}
