import 'package:ember_core/ember_core_models.dart';
import 'package:ember_core/ember_core_utils.dart';

class CabinDependant extends BessObject implements Dependant{
  @override
  final String principalPar;
  final String name;
  final int capacity;
  final Set<CamperId> camperRefs;
  final Map<CamperId, CamperPreferenceId> campersWithPreferences;

  CabinDependant({
    required this.principalPar,
    required this.name,
    required this.capacity,
    Set<String>? camperRefs,
    Map<CamperId, CamperPreferenceId>? campersWithPreferences ,
    super.id,
    super.createdAt,
    super.updatedAt,
  })  : camperRefs = camperRefs ?? {},
        campersWithPreferences = campersWithPreferences ?? {},
        super(
          domain: 'ses',
          type: 'cabin_dependant',
          idTag: name,
        );

  @override
  String bessToString() {
    return 'Cabin: $name, Capacity: $capacity}';
  }

  @override
  void purgeRef(String id) {
    if (IdFunctions.getIdPart(id, 2) == 'camper') {
      if(camperRefs.remove(id) == false) { // TODO: remove this once the delete logic is bug free
        print('unnecessary purge');
      }
      if(campersWithPreferences.remove(id) == null) {
        print('unnecessary purge');
      }
    } else if (IdFunctions.getIdPart(id, 2) == 'camper_preference') {
      campersWithPreferences.removeWhere((key, value) => value == id);
    }
  }

  @override
  Map<String, dynamic> toJson() {
    final json = toJsonSuper();
    json.addAll({
      'principalPar': principalPar,
      'name': name,
      'capacity': capacity,
      'camperRefs': camperRefs.toList(),
      'campersWithPreferences': campersWithPreferences,
    });
    return json;
  }

  factory CabinDependant.fromJson(Map<String, dynamic> json) {
    final cabinDependant = CabinDependant(
      principalPar: json['principalPar'] as String,
      name: json['name'] as String,
      capacity: json['capacity'] as int,
      camperRefs: (json['camperRefs'] as List?)?.cast<String>().toSet() ?? <String>{},
      campersWithPreferences: (json['campersWithPreferences'] as Map?)?.cast<String, String>() ?? {},
    );
    cabinDependant.overwriteBessObjectFromJson(json);
    return cabinDependant;
  }
}
