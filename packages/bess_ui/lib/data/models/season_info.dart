import 'package:bessie/data/abstract/bess_object.dart';
import 'package:bessie/data/models/session_info.dart';

class SeasonInfo extends BessObject{
  String name;
  Map<String, SessionInfo> sessions;

  SeasonInfo({
    required this.name,
  }) : sessions = {}, super(idTitle: 'Season-$name');

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