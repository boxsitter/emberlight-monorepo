

import 'package:ember_core/ember_core_models.dart';

import '../../abstract/domain.dart';

class Branch extends CoreObject implements Domain{
  final String name;
   // TODO: refactor to session, ensure only principal objects are above session, handle their deletion differently

  Branch({
    required this.name,
    super.id,
    super.createdAt,
    super.updatedAt,
  })  : super(
          domain: 'org',
          type: 'branch',
          idTag: name,
        );

  @override
  String coreToString() {
    return 'Branch: $name';
  }

  @override
  void purgeRef(String id) {
    print('unnecessary purge');
    return;
  }

  @override
  Map<String, dynamic> toJson() {
    final json = toJsonSuper();
    json.addAll({
      'name': name,
    });
    return json;
  }

  factory Branch.fromJson(Map<String, dynamic> json) {
    final branch = Branch(
      name: json['name'] as String,
    );
    branch.overwriteCoreObjectFromJson(json);
    return branch;
  }
}
