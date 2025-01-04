import 'package:bessie/common/data/abstract/bess_object.dart';
import 'package:bessie/common/data/models/roster.dart';

import 'cabin.dart';

class Session extends BessObject{
  String name;
  Roster sessionRoster;
  final Map<String, Cabin> cabins;

  Session({required this.name}) : sessionRoster = Roster(title: 'Session Master'), cabins = {}, super('Session-$name');

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

  Cabin? getCabinByName(String cabinName) {
    for (Cabin cabin in cabins.values) {
      if (cabin.name.toLowerCase() == cabinName.toLowerCase()) {
        return cabin;
      }
    }
    return null;
  }

}