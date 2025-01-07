import 'package:bessie/common/data/abstract/bess_object.dart';
import 'package:bessie/common/data/models/session.dart';

class Season extends BessObject{
  String name;
  Map<String, Session> sessions;

  Season({
    required BessObject dataParent,
    required this.name,
  }) : sessions = {}, super('Season-$name', dataParent);

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