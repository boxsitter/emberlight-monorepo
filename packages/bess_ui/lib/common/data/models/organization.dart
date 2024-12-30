import 'package:bessie/common/data/abstract/bess_object.dart';

import 'branch.dart';

class Organization extends BessObject{
  String name;
  Map<String, Branch> branches;

  Organization({required this.name}) : branches = {}, super('Organization-$name');

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

  /// Add a branch to the map
  void addBranch(Branch branch) {
    branches[branch.id] = branch;
  }

  /// Retrieve a branch by id
  Branch? getBranchById(String id) {
    return branches[id];
  }

}