import 'package:bessie/data/abstract/bess_object.dart';

class Branch extends BessObject {
  final String name;
  Map<String, Set<String>> refTracker; // TODO: refactor to session, ensure only principal objects are above session, handle their deletion differently

  Branch({
    required this.name,
    Map<String, Set<String>>? refTracker,
    super.objId,
    super.createdAt,
    super.updatedAt,
  })  : refTracker = refTracker ?? {},
        super(
          domain: 'org',
          type: 'branch',
          idTag: name,
        );

  @override
  String bessToString() {
    return 'Branch: $name';
  }

  @override
  void purgeRef(String ref) {
    print('unnecessary purge');
    return;
  }

  @override
  Map<String, dynamic> toJson() {
    final json = toJsonSuper();
    json.addAll({
      'name': name,
      'refTracker': refTracker.map((key, value) => MapEntry(key, value.toList())),
    });
    return json;
  }

  factory Branch.fromJson(Map<String, dynamic> json) {
    final branch = Branch(
      name: json['name'] as String,
      refTracker: (json['refTracker'] as Map<String, dynamic>?)?.map((key, value) => MapEntry(key, Set<String>.from(value ?? [])),) ?? {},
    );
    branch.overwriteBessObjectFromJson(json);
    return branch;
  }
}
