import 'package:bessie/data/abstract/bess_object.dart';

class Branch extends BessObject {
  final String name;
  final Set<String> seasons;

  Branch({
    required this.name,
    Set<String>? seasons,
    super.id,
    super.createdAt,
    super.updatedAt,
  })  : seasons = seasons ?? {},
        super(idTitle: 'branch-$name');

  @override
  String bessToString() {
    return 'Branch: $name';
  }

  @override
  Map<String, dynamic> toJson() {
    final json = toJsonSuper();
    json.addAll({
      'name': name,
      'seasons': seasons.toList(),
    });
    return json;
  }

  factory Branch.fromJson(Map<String, dynamic> json, [bool clone = false]) {
    final branch = Branch(
      name: json['name'] as String,
      seasons: (json['seasons'] as List?)?.cast<String>().toSet() ?? <String>{},
    );
    branch.overwriteBessObjectFromJson(json, clone);
    return branch;
  }
}
