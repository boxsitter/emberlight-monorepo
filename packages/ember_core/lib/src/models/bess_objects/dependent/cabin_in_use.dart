import 'package:ember_core/ember_core_models.dart';
import 'package:ember_core/ember_core_utils.dart';

class CabinInUse extends BessObject {
  final String name;
  final int capacity;
  final Set<CamperRef> camperRefs;
  final Map<CamperRef, CamperPreferenceRef> campersWithPreferences;

  CabinInUse({
    required this.name,
    required this.capacity,
    Set<String>? camperRefs,
    Map<CamperRef, CamperPreferenceRef>? campersWithPreferences ,
    super.objId,
    super.createdAt,
    super.updatedAt,
  })  : camperRefs = camperRefs ?? {},
        campersWithPreferences = campersWithPreferences ?? {},
        super(
          domain: 'ses',
          type: 'cabin_in_use',
          idTag: name,
        );

  @override
  String bessToString() {
    return 'Cabin: $name, Capacity: $capacity}';
  }

  @override
  void purgeRef(String ref) {
    if (IdFunctions.getIdPart(ref, 2) == 'camper') {
      if(camperRefs.remove(ref) == false) { // TODO: remove this once the delete logic is bug free
        print('unnecessary purge');
      }
      if(campersWithPreferences.remove(ref) == null) {
        print('unnecessary purge');
      }
    } else if (IdFunctions.getIdPart(ref, 2) == 'camper_preference') {
      campersWithPreferences.removeWhere((key, value) => value == ref);
    }
  }

  @override
  Map<String, dynamic> toJson() {
    final json = toJsonSuper();
    json.addAll({
      'name': name,
      'capacity': capacity,
      'camperRefs': camperRefs.toList(),
      'campersWithPreferences': campersWithPreferences,
    });
    return json;
  }

  factory CabinInUse.fromJson(Map<String, dynamic> json) {
    final cabinInUse = CabinInUse(
      name: json['name'] as String,
      capacity: json['capacity'] as int,
      camperRefs: (json['camperRefs'] as List?)?.cast<String>().toSet() ?? <String>{},
      campersWithPreferences: (json['campersWithPreferences'] as Map?)?.cast<String, String>() ?? {},
    );
    cabinInUse.overwriteBessObjectFromJson(json);
    return cabinInUse;
  }
}
