import 'package:bessie/data/abstract/bess_object.dart';

class Organization extends BessObject {
  final String name;

  Organization({
    required this.name,
    super.id,
    super.createdAt,
    super.updatedAt,
  })  : super(
          domain: 'rot',
          type: 'organization',
          idTag: name,
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

  factory Organization.fromJson(Map<String, dynamic> json,
      [bool clone = false]) {
    final org = Organization(
      name: json['name'] as String,
    );
    org.overwriteBessObjectFromJson(json);
    return org;
  }
}
