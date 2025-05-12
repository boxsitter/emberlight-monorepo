import 'package:ember_core/ember_core_models.dart';
import 'package:ember_core/src/models/core_objects/schedule_day.dart';


class HardcodedObjects {

  static final Organization ygs = Organization(
    id: 'ymca_of_greater_seattle-organization-rot-iezbojy',
    name: 'YMCA Of Greater Seattle',
    createdAt: DateTime.parse('2025-03-17T04:58:08.000Z').toUtc(),
  );

  static final Branch colman = Branch(
    id: 'colman-branch-org-ewuc68e',
    name: 'Colman',
    createdAt: DateTime.parse('2025-03-17T05:10:29.000Z').toUtc(),
  );

  static final Season season = Season(
    name: '2025',
    createdAt: DateTime.parse('2025-03-17T05:19:16.000Z').toUtc(),
    start: DateTime(2025, 1, 1).toUtc(),
    end: DateTime(2026, 1, 1).toUtc(),
  );

  static final session = Session(
    name: 'Test Session',
    createdAt: DateTime.parse('2025-03-17T05:35:01.000Z').toUtc(),
    start: DateTime(2025, 1, 1).toUtc(),
    end: DateTime(2026, 1, 1).toUtc(),
  );

  static final Schedule schedule = Schedule();

  static final PrincipalCabin henderson = PrincipalCabin(
    name: 'Henderson',
    capacity: 12,
  );

  static final PrincipalCabin leckenby = PrincipalCabin(
    name: 'Leckenby',
    capacity: 12,
  );

  static final PrincipalCabin yarrow = PrincipalCabin(
    name: 'Yarrow',
    capacity: 12,
  );

  static final PrincipalCabin freeman1 = PrincipalCabin(
    name: 'Freeman 1',
    capacity: 14,
  );

  static final PrincipalActivity gagaBall = PrincipalActivity(
    name: 'Gaga Ball',
    capacity: 24,
    description: 'Gaga Ball is a super fast-paced game played in a walled pit where everyone tries to hit a '
        'soft ball at other players\' legs, below the knees. If the ball touches you below the knees, you\'re'
        'out, and the last player left in the pit wins the round!',
    isSkillsRec: false,
  );

  static final PrincipalActivity boating = PrincipalActivity(
    name: 'Boating',
    capacity: 12,
    description: 'Grab a paddle and hop into a boat to explore the lagoon with your friends!',
    isSkillsRec: false,
  );

  static final PrincipalActivity climbing = PrincipalActivity(
    name: 'Climbing Wall',
    capacity: 12,
    description: 'Clip into a safety harness and see how high you can climb up the rock wall!',
    isSkillsRec: false,
  );

  static final PrincipalActivity artsAndCrafts = PrincipalActivity(
    name: 'Arts and Crafts',
    capacity: 20,
    description: 'Get creative with paint, paper, glue, and lots of other cool supplies to make '
        'your own awesome projects! You can draw, build, or design something totally unique to '
        'take home.',
    isSkillsRec: false,
  );

  static final PrincipalActivity tieDye = PrincipalActivity(
    name: 'Tie Dye',
    capacity: 16,
    description: 'Twist, fold, and tie up a t-shirt or other fabric using rubber bands. Don\'t '
        'forget to bring something white to dye!!!',
    isSkillsRec: false,
  );

  static final PrincipalActivity archery = PrincipalActivity(
    name: 'Archery',
    capacity: 16,
    description: 'Take aim at the target, draw back the string, and see if you can hit a bullseye!',
    isSkillsRec: false,
  );

  static final PrincipalActivity soccer = PrincipalActivity(
    name: 'Soccer',
    capacity: 18,
    description: 'Hit the ball field, practice your kicks and passes, and work with your team to score!',
    isSkillsRec: true,
  );

  static final PrincipalActivity cardGames = PrincipalActivity(
    name: 'Card Games',
    capacity: 20,
    description: 'Grab a deck of cards and gather around a table with friends for some fun games!',
    isSkillsRec: true,
  );

  static final ScheduleDay day1 = ScheduleDay(
    start: DateTime.now(),
    end: DateTime.now(),
    dayIndex: 0,
  );

  static final AMABlock choiceActivity = AMABlock(
    name: 'Choice Activity 1',
    isTemplate: false,
    start: DateTime.now(),
    end: DateTime.now(),
    isSkillsRec: false,
  );

  static final Set<CoreObject> hardcodedObjects = {
    ygs,
    colman,
    season,
    session,
    schedule,
    henderson,
    leckenby,
    yarrow,
    freeman1,
    gagaBall,
    boating,
    climbing,
    artsAndCrafts,
    tieDye,
    archery,
    soccer,
  };
}