import 'package:bessie/data/abstract/bess_object.dart';

import 'branch_info.dart';

class OrganizationInfo extends BessObject{
  String name;
  Map<String, BranchInfo> branches;

  OrganizationInfo({
    required this.name
  }) : branches = {}, super(idTitle: 'Organization-$name');

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