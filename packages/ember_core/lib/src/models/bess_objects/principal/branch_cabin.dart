import 'package:ember_core/ember_core_models.dart';

class BranchCabin extends BessObject {
  final String name;
  final int capacity;

  BranchCabin({
    required this.name,
    required this.capacity,
    super.id,
    super.createdAt,
    super.updatedAt,
  })  :  super(
          domain: 'brn',
          type: 'branch_cabin',
          idTag: name,
        );

  @override
  String bessToString() {
    return 'Branch cabin: $name, Capacity: $capacity}';
  }

  @override
  Map<String, dynamic> toJson() {
    final json = toJsonSuper();
    json.addAll({
      'name': name,
      'capacity': capacity,
    });
    return json;
  }

  factory BranchCabin.fromJson(Map<String, dynamic> json) {
    final branchCabin = BranchCabin(
      name: json['name'] as String,
      capacity: json['capacity'] as int,
    );
    branchCabin.overwriteBessObjectFromJson(json);
    return branchCabin;
  }

  @override
  void purgeRef(String id) {
    // TODO: implement purgeRef
  }
}
