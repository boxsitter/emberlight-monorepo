import 'package:bessie/data/abstract/bess_object.dart';
import 'package:bessie/data/models/roster.dart';
import 'package:bessie/data/models/schedule/schedule.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'cabin.dart';

class Session extends BessObject {
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final Set<String> registeredCamperIds;
  final Set<String> cabinsInUseIds;
  late final String scheduleId;

  Session({
    required this.name,
    required this.startDate,
    required this.endDate,
    this.registeredCamperIds = const {},
    this.cabinsInUseIds = const {},
    required this.scheduleId,
    super.id,
    super.createdAt,
    super.updatedAt,
  })  : super(idTitle: 'session-$name',);

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
      'registeredCamperIds': registeredCamperIds.toList(),
      'cabinsInUse': cabinsInUseIds.toList(),
      'scheduleId': scheduleId,
    });
    return json;
  }

  factory Session.fromJson(Map<String, dynamic> json, [bool clone = false]) {
    final session = Session(
      name: json['name'] as String,
      startDate: (json['startDate'] as Timestamp).toDate(),
      endDate: (json['endDate'] as Timestamp).toDate(),
      registeredCamperIds: (json['registeredCamperIds'] as List?)?.cast<String>().toSet() ?? <String>{},
      cabinsInUseIds: (json['cabinsInUseIds'] as List?)?.cast<String>().toSet() ?? <String>{},
      scheduleId: json['scheduleId'] as String,
    );
    session.overwriteBessObjectFromJson(json, clone);
    return session;
  }
}
