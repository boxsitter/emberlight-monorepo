import 'branch.dart';
import 'organization.dart';
import 'season.dart';
import 'session.dart';

class LocalData {
  Organization? organization;
  Branch? branch;
  Season? season;
  Session? session;

  // empty constructor
  LocalData();

  void populateForTesting () {
    organization = Organization(
        name: 'YGS'
    );

    branch = Branch(
        name: 'Camp Colman'
    );
    organization?.addBranch(branch!);

    season = Season(
        name: '2025'
    );
    branch?.addSeason(season!);

    session = Session(
        name: 'Test Session'
    );
    season?.addSession(session!);

  }
}