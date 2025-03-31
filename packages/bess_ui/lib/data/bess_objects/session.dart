import 'package:bessie/data/abstract/bess_object.dart';
import 'package:bessie/data/bess_objects/camper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'camper.dart';
import 'camper_preference.dart';

typedef CamperPreferenceRef = String;

class Session extends BessObject {
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final Map<CamperRef, CamperPreferenceRef> camperRefToPreferenceRef; // TODO: Make sure this map counts as referencing both camper and preference

  Session({
    required this.name,
    required this.startDate,
    required this.endDate,
    Map<CamperRef, CamperPreferenceCmp>? camperIdToPreferenceId,
    super.id,
    super.createdAt,
    super.updatedAt,
  })  : camperRefToPreferenceRef = camperIdToPreferenceId ?? {},
        super(
          domain: 'sea',
          type: 'session',
          idTag: name,
        );

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
      'camperIdToPreferenceId': camperRefToPreferenceRef,
    });
    return json;
  }

  factory Session.fromJson(Map<String, dynamic> json) {
    final session = Session(
      name: json['name'] as String,
      startDate: (json['startDate'] as Timestamp).toDate(),
      endDate: (json['endDate'] as Timestamp).toDate(),
      camperIdToPreferenceId: (json['camperIdToPreferenceId'] as Map?)?.cast<String, String>() ?? {},
    );
    session.overwriteBessObjectFromJson(json);
    return session;
  }
}
