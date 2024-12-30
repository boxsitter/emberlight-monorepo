import 'package:bessie/common/data/abstract/bess_object.dart';
import 'package:bessie/common/data/models/roster.dart';

class Session extends BessObject{
  String name;
  Roster sessionRoster;

  Session({required this.name}) : sessionRoster = Roster(), super('Session-$name');

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