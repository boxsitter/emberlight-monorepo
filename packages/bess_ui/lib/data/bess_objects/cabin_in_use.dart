import '../abstract/bess_object.dart';

class CabinInUse extends BessObject {
  final String name;
  final int capacity;
  final Set<String> camperRefs;
  int campersWithPreferencesCount;

  CabinInUse({
    required this.name,
    required this.capacity,
    Set<String>? camperRefs,
    this.campersWithPreferencesCount = 0,
    super.id,
    super.createdAt,
    super.updatedAt,
  })  : camperRefs = camperRefs ?? {},
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
  Map<String, dynamic> toJson() {
    final json = toJsonSuper();
    json.addAll({
      'name': name,
      'capacity': capacity,
      'camperRefs': camperRefs.toList(),
      'campersWithPreferencesCount': campersWithPreferencesCount,
    });
    return json;
  }

  factory CabinInUse.fromJson(Map<String, dynamic> json) {
    final cabinInUse = CabinInUse(
      name: json['name'] as String,
      capacity: json['capacity'] as int,
      camperRefs: (json['camperRefs'] as List?)?.cast<String>().toSet() ?? <String>{},
      campersWithPreferencesCount: json['campersWithPreferencesCount'] as int,
    );
    cabinInUse.overwriteBessObjectFromJson(json);
    return cabinInUse;
  }
}
