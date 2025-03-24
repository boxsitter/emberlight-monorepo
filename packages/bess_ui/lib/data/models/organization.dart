import 'package:bessie/data/abstract/bess_object.dart';

import 'branch.dart';

class Organization extends BessObject{
  final String name;
  final Set<String> branches;

  Organization({
    required this.name,
    this.branches = const {},
    super.id,
    super.createdAt,
    super.updatedAt,
  }) : super(idTitle: 'organization-$name');

  @override
  String bessToString() {
    return 'Organization: $name';
  }

  @override
  Map<String, dynamic> toJson() {
    final json = toJsonSuper();
    json.addAll({
      'name': name,
      'branches': branches.toList(),
    });
    return json;
  }

  factory Organization.fromJson(Map<String, dynamic> json, [bool clone = false]) {
    final org = Organization(
      name: json['name'] as String,
      branches: (json['branches'] as List?)?.cast<String>().toSet() ?? <String>{},
    );
    org.overwriteBessObjectFromJson(json, clone);
    return org;
  }

}