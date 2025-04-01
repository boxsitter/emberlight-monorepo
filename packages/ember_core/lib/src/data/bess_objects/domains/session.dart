import 'package:bessie/data/abstract/bess_object.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../common/utils/helpers/bess_id_functions.dart';
import '../camper_preference.dart';

typedef CamperPreferenceRef = String;

class Session extends BessObject {
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final Map<CamperRef, CamperPreferenceRef> camperRefToPreferenceRef; // TODO: Make sure this map counts as referencing both camper and preference
  Map<String, Set<String>> refTracker;
  Map<String, Set<String>> principalDependantLinkTracker;

  Session({
    required this.name,
    required this.startDate,
    required this.endDate,
    Map<CamperRef, CamperPreferenceRef>? camperIdToPreferenceId,
    Map<String, Set<String>>? refTracker,
    super.objId,
    super.createdAt,
    super.updatedAt,
  })  : camperRefToPreferenceRef = camperIdToPreferenceId ?? {},
        refTracker = refTracker ?? {},
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
  void purgeRef(String ref) {
    if (BessIdFunctions.getIdPart(ref, 2) == 'camper') {
      if(camperRefToPreferenceRef.remove(ref) == null) {
        print('unnecessary purge');
      }
    } else if (BessIdFunctions.getIdPart(ref, 2) == 'camper_preference') {
      camperRefToPreferenceRef.removeWhere((key, value) => value == ref);
    }
  }

  @override
  Map<String, dynamic> toJson() {
    final json = toJsonSuper();
    json.addAll({
      'name': name,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'camperIdToPreferenceId': camperRefToPreferenceRef,
      'refTracker': refTracker.map((key, value) => MapEntry(key, value.toList())),
    });
    return json;
  }

  factory Session.fromJson(Map<String, dynamic> json) {
    final session = Session(
      name: json['name'] as String,
      startDate: (json['startDate'] as Timestamp).toDate(),
      endDate: (json['endDate'] as Timestamp).toDate(),
      camperIdToPreferenceId: (json['camperIdToPreferenceId'] as Map?)?.cast<String, String>() ?? {},
      refTracker: (json['refTracker'] as Map<String, dynamic>?)?.map((key, value) => MapEntry(key, Set<String>.from(value ?? [])),) ?? {},
    );
    session.overwriteBessObjectFromJson(json);
    return session;
  }
}
