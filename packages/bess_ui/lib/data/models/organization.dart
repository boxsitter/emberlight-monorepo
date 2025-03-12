import 'package:bessie/data/abstract/bess_object.dart';

import 'branch.dart';

class Organization extends BessObject{
  String name;
  final Map<String, Branch> branches;

  Organization({
    required this.name,
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : branches = {},
        super(
        idTitle: 'organization-$name',
        id: id,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

  @override
  String bessToString() {
    return 'Organization: $name, Branches: ${branches.length}';
  }

  @override
  Map<String, dynamic> toJson() {
    final json = toJsonSuper();
    json.addAll({
      'name': name,
      'branches': branches.map((key, branch) => MapEntry(key, branch.toJson())),
    });
    return json;
  }

  factory Organization.fromJson(Map<String, dynamic> json) {
    final org = Organization(
      name: json['name'] as String,
      id: json['id'] as String,
      createdAt: DateTime.tryParse(json['createdAt'] as String),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String),
    );
    if (json.containsKey('branches')) {
      final branchesJson = json['branches'] as Map<String, dynamic>;
      branchesJson.forEach((key, branchJson) {
        org.branches[key] =
            Branch.fromJson(branchJson as Map<String, dynamic>);
      });
    }
    return org;
  }

}