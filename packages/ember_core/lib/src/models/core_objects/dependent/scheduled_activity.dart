import 'package:ember_core/ember_core_models.dart';

class ActivityDependent extends CoreObject implements Dependent{
  @override
  final String principalPar;
  final String name;
  final int capacity;
  final Set<String> camperRefs;
  final String blockRef;

  ActivityDependent({
    required this.principalPar,
    required this.name,
    required this.capacity,
    required this.blockRef,
    Set<String>? camperRefs,
    super.id,
    super.createdAt,
    super.updatedAt,
  })  : camperRefs = camperRefs ?? {},
        super(
          domain: 'ses',
          type: 'activity_dependent',
          idTag: name,
        );

  @override
  String coreToString() {
    return 'Activity: $name, Capacity: $capacity';
  }

  @override
  Map<String, dynamic> toJson() {
    final json = toJsonSuper();
    json.addAll({
      'principalPar': principalPar,
      'name': name,
      'capacity': capacity,
      'camperRefs': camperRefs.toList(),
      'blockRef': blockRef,
    });
    return json;
  }

  factory ActivityDependent.fromJson(Map<String, dynamic> json) {
    ActivityDependent activity = ActivityDependent(
      principalPar: json['principalPar'] as String,
      name: json['name'] as String,
      capacity: json['capacity'] as int,
      camperRefs: (json['camperRefs'] as List?)?.cast<String>().toSet() ?? <String>{},
      blockRef: json['blockRef'] as String,
    );
    activity.overwriteCoreObjectFromJson(json);
    return activity;
  }

  @override
  void purgeRef(String id) {
    // TODO: implement purgeRef
  }
}
