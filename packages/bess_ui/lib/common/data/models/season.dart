import 'package:bessie/common/data/abstract/bess_object.dart';
import 'package:bessie/common/data/models/session.dart';

class Season extends BessObject{
  String name;
  Map<String, Session> sessions;

  Season({required this.name}) : sessions = {}, super('Season-$name');

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

  /// Add a session to the map
  void addSession(Session session) {
    sessions[session.id] = session;
  }

  /// Retrieve a session by id
  Session? getSessionById(String id) {
    return sessions[id];
  }
}