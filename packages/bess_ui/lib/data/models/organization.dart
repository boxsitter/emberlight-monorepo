import 'package:bessie/data/abstract/bess_object.dart';

import 'branch.dart';

class Organization extends BessObject{
  String name;

  Organization({
    required this.name
  }) : super(idTitle: 'organization-$name');

  @override
  String bessToString() {
    // TODO: implement bessToString
    throw UnimplementedError();
  }

  @override
  Map<String, dynamic> toJson() {
    // TODO: implement toJson
    throw UnimplementedError();
  }

}