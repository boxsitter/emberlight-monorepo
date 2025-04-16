import 'package:ember_core/ember_core_models.dart';
import 'package:ember_core/ember_core_utils.dart';

class CabinDependent extends CoreObject implements Dependent{
  @override
  final String principalPar;
  final Set<CamperId> camperRefs;
  final Map<CamperId, CamperPreferenceId> campersWithPreferences;

  CabinDependent({
    required this.principalPar,
    Set<String>? camperRefs,
    Map<CamperId, CamperPreferenceId>? campersWithPreferences ,
    super.id,
    super.createdAt,
    super.updatedAt,
  })  : camperRefs = camperRefs ?? {},
        campersWithPreferences = campersWithPreferences ?? {},
        super(
          domain: 'ses',
          type: 'cabin_dependent',
          idTag: IdFunctions.getIdPart(principalPar, 0), // inherits tag from parent
        );

  @override
  String coreToString() {
    return id;
  }

  @override
  void purgeRef(String id) {
    if (IdFunctions.getIdPart(id, 1) == 'camper') {
      if(camperRefs.remove(id) == false) { // TODO: remove this once the delete logic is bug free
        print('unnecessary purge');
      }
      if(campersWithPreferences.remove(id) == null) {
        print('unnecessary purge');
      }
    } else if (IdFunctions.getIdPart(id, 1) == 'camper_preference') {
      campersWithPreferences.removeWhere((key, value) => value == id);
    }
  }

  @override
  Map<String, dynamic> toJson() {
    final json = toJsonSuper();
    json.addAll({
      'principalPar': principalPar,
      'camperRefs': camperRefs.toList(),
      'campersWithPreferences': campersWithPreferences,
    });
    return json;
  }

  factory CabinDependent.fromJson(Map<String, dynamic> json) {
    final cabinDependent = CabinDependent(
      principalPar: json['principalPar'] as String,
      camperRefs: (json['camperRefs'] as List?)?.cast<String>().toSet() ?? <String>{},
      campersWithPreferences: (json['campersWithPreferences'] as Map?)?.cast<String, String>() ?? {},
    );
    cabinDependent.overwriteCoreObjectFromJson(json);
    return cabinDependent;
  }
}
