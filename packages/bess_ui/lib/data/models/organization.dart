import 'package:bessie/data/abstract/bess_object.dart';

import 'branch.dart';

class Organization extends BessObject{
  String name;

  Organization({
    required this.name,
    super.id,
    super.createdAt,
    super.updatedAt,
  }) : super(
    idTitle: 'organization-$name',
  );

  @override
  String bessToString() {
    return 'Organization: $name';
  }

  @override
  Map<String, dynamic> toJson() {
    final json = toJsonSuper();
    json.addAll({
      'name': name,
    });
    return json;
  }

  factory Organization.fromJson(Map<String, dynamic> json, [bool clone = false]) {
    final org = Organization(
      name: json['name'] as String,
    );
    org.overwriteBessObjectFromJson(json, clone);
    return org;
  }

}