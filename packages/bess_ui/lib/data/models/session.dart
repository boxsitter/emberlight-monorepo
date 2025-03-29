import 'package:bessie/data/abstract/bess_object.dart';
import 'package:bessie/data/models/camper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'camper_preference.dart';

class Session extends BessObject {
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final Set<String> registeredCamperIds;
  final Set<String> cabinsInUseIds;
  final Map<CamperId, CamperPreferenceId> camperIdToPreferenceId;
  final String scheduleId;

  Session({
    required this.name,
    required this.startDate,
    required this.endDate,
    Set<String>? registeredCamperIds,
    Set<String>? cabinsInUseIds,
    Map<CamperId, CamperPreferenceId>? camperIdToPreferenceId,
    required this.scheduleId,
    super.id,
    super.createdAt,
    super.updatedAt,
  })  : registeredCamperIds = registeredCamperIds ?? {},
        cabinsInUseIds = cabinsInUseIds ?? {},
        camperIdToPreferenceId = camperIdToPreferenceId ?? {},
        super(idTitle: 'session-$name');

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
      'cabinsInUseIds': cabinsInUseIds.toList(),
      'camperIdToPreferenceId': camperIdToPreferenceId,
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
      camperIdToPreferenceId: (json['camperIdToPreferenceId'] as Map?)?.cast<String, String>() ?? {},
      scheduleId: json['scheduleId'] as String,
    );
    session.overwriteBessObjectFromJson(json, clone);
    return session;
  }
}
