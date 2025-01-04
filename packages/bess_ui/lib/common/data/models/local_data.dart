import 'branch.dart';
import 'cabin.dart';
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

  void initializeForTesting () {
    // Organization initialization
    organization = Organization(
        name: 'YGS'
    );

    // Branch initialization
    branch = Branch(
        name: 'Camp Colman'
    );
    organization?.addBranch(branch!);

    // Season initialization
    season = Season(
        name: '2025'
    );
    branch?.addSeason(season!);

    // Session initialization
    session = Session(
        name: 'Test Session'
    );
    season?.addSession(session!);

    Cabin cabin1 = Cabin(name: "Henderson", capacity: 12);
    Cabin cabin2 = Cabin(name: "Leckenby", capacity: 12);
    Cabin cabin3 = Cabin(name: "Yarrow", capacity: 12);
    Cabin cabin4 = Cabin(name: "Freeman 1", capacity: 14);

    session?.cabins.addAll({
      cabin1.id: cabin1,
      cabin2.id: cabin2,
      cabin3.id: cabin3,
      cabin4.id: cabin4,
    });
  }
}