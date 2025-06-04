import 'package:ember_core/ember_core_models.dart';
import 'package:ember_core/ember_core_utils.dart';

import '../../../../ember_core_debug.dart';

class CabinDependent extends CoreObject implements Dependent{
  @override
  final String principalPar;
  final Set<CamperId> camperRefs;
  final Set<CamperId> campersWithPreferences;

  CabinDependent({
    required this.principalPar,
    Set<String>? camperRefs,
    Set<CamperId>? campersWithPreferences,
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
    Debug.logInfo('Purging $id from ${this.id}');
    if (IdFunctions.getIdPart(id, 1) == 'camper') {
      camperRefs.remove(id);
      campersWithPreferences.remove(id);
    } else if (IdFunctions.getIdPart(id, 1) == 'camper_preference') {
      campersWithPreferences.remove(id);
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
      campersWithPreferences: (json['campersWithPreferences'] as List?)?.cast<String>().toSet() ?? <String>{},
    );
    cabinDependent.overwriteCoreObjectFromJson(json);
    return cabinDependent;
  }
}
