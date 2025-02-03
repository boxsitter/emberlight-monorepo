import 'package:bessie/data/abstract/bess_object.dart';

import 'branch.dart';

class Organization extends BessObject{
  String name;
  Map<String, Branch> branches;

  Organization({
    required BessObject dataParent,
    required this.name
  }) : branches = {}, super('Organization-$name', dataParent);

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