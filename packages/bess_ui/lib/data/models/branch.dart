import 'package:bessie/data/abstract/bess_object.dart';

class Branch extends BessObject{
  String name;

  Branch({
    required this.name,
    super.id,
    super.createdAt,
    super.updatedAt,
  })  : super(
        idTitle: 'branch-$name',
      );

  @override
  String bessToString() {
    return 'Branch: $name';
  }

  @override
  Map<String, dynamic> toJson() {
    final json = toJsonSuper();
    json.addAll({
      'name': name,
    });
    return json;
  }

  factory Branch.fromJson(Map<String, dynamic> json, [bool clone = false]) {
    final branch = Branch(
      name: json['name'] as String,
    );
    branch.overwriteBessObjectFromJson(json, clone);
    return branch;
  }
}