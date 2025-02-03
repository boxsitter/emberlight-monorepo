import 'package:bessie/data/abstract/bess_object.dart';

import 'branch.dart';
import 'organization.dart';
import 'season.dart';
import 'session.dart';

class LocalData extends BessObject{
  Organization? organization;
  Branch? branch;
  Season? season;
  Session? session;

  LocalData() : super('localdata', null);

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
  // TODO: add updated at
}