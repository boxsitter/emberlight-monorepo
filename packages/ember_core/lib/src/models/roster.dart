import '../../ember_core_debug.dart';
import 'enums/roster_field.dart';
import 'interfaces/rosterable.dart';

typedef RosterableId = String;

class Roster {
  String title;
  Set<RosterableId> _members = {};
  Type? memberType;


  Roster({
    this.title = 'Roster',
    this.activeFields = const {},
  });

  void addMember(Rosterable member) {
    if (_members.isEmpty) {
      _members.add(member.id);
    }
    if(member is! memberType) {

    }
  }

}