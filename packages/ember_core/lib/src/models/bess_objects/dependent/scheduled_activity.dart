import 'package:ember_core/ember_core_models.dart';

class ActivityDependant extends BessObject implements Dependant{
  @override
  final String principalPar;
  final String name;
  final int capacity;
  final Set<String> camperRefs;
  final String blockRef;

  ActivityDependant({
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
          type: 'activity_dependant',
          idTag: name,
        );

  @override
  String bessToString() {
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

  factory ActivityDependant.fromJson(Map<String, dynamic> json) {
    ActivityDependant activity = ActivityDependant(
      principalPar: json['principalPar'] as String,
      name: json['name'] as String,
      capacity: json['capacity'] as int,
      camperRefs: (json['camperRefs'] as List?)?.cast<String>().toSet() ?? <String>{},
      blockRef: json['blockRef'] as String,
    );
    activity.overwriteBessObjectFromJson(json);
    return activity;
  }

  @override
  void purgeRef(String id) {
    // TODO: implement purgeRef
  }
}
