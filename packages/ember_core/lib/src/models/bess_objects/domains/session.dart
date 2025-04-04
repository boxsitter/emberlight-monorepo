import 'package:ember_core/ember_core_models.dart';
import 'package:ember_core/ember_core_utils.dart';

typedef CamperPreferenceId = String;

class Session extends BessObject {
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final Map<CamperId, CamperPreferenceId> camperRefToPreferenceRef; // TODO: Make sure this map counts as referencing both camper and preference
  Map<String, Set<String>> refTracker; // TODO: Still track who is referencing a principal in here. If the principal is deleted or found missing, call purge on everyone referencing it and delete the entry.
  Map<String, Set<String>> principalDependantLinkTracker; //TODO: On init, check the integrity of all principals. If one is missing, call delete on all its dependants and purge references to it

  Session({
    required this.name,
    required this.startDate,
    required this.endDate,
    Map<CamperId, CamperPreferenceId>? camperIdToPreferenceId,
    Map<String, Set<String>>? refTracker,
    Map<String, Set<String>>? principalDependantLinkTracker,
    super.id,
    super.createdAt,
    super.updatedAt,
  })  : camperRefToPreferenceRef = camperIdToPreferenceId ?? {},
        refTracker = refTracker ?? {},
        principalDependantLinkTracker = principalDependantLinkTracker ?? {},
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
  void purgeRef(String id) {
    if (IdFunctions.getIdPart(id, 2) == 'camper') {
      if(camperRefToPreferenceRef.remove(id) == null) {
        print('unnecessary purge');
      }
    } else if (IdFunctions.getIdPart(id, 2) == 'camper_preference') {
      camperRefToPreferenceRef.removeWhere((key, value) => value == id);
    }
  }

  @override
  Map<String, dynamic> toJson() {
    final json = toJsonSuper();
    json.addAll({
      'name': name,
      'startDate': startDate,
      'endDate': endDate,
      'camperIdToPreferenceId': camperRefToPreferenceRef,
      'refTracker': refTracker.map((key, value) => MapEntry(key, value.toList())),
      'principalDependantLinkTracker': principalDependantLinkTracker.map((key, value) => MapEntry(key, value.toList())),
    });
    return json;
  }

  factory Session.fromJson(Map<String, dynamic> json) {
    final session = Session(
      name: json['name'] as String,
      startDate: json['startDate'] as DateTime,
      endDate: json['endDate'] as DateTime,
      camperIdToPreferenceId: (json['camperIdToPreferenceId'] as Map?)?.cast<String, String>() ?? {},
      refTracker: (json['refTracker'] as Map<String, dynamic>?)?.map((key, value) => MapEntry(key, Set<String>.from(value ?? [])),) ?? {},
      principalDependantLinkTracker: (json['principalDependantLinkTracker'] as Map<String, dynamic>?)?.map((key, value) => MapEntry(key, Set<String>.from(value ?? [])),) ?? {},
    );
    session.overwriteBessObjectFromJson(json);
    return session;
  }
}
