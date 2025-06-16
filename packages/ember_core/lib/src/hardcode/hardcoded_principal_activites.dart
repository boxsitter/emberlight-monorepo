import '../../ember_core_models.dart';

class HardcodedPrincipalActivities {
  static final Set<PrincipalActivity> list = <PrincipalActivity>{
    gagaBall,
    boating,
    climbing,
    artsAndCrafts,
    tieDye,
    archery,
    soccer,
    cardGames,
  };

  static final PrincipalActivity gagaBall = PrincipalActivity(
    id: 'gaga_ball-principal_activity-brn-Cs4UhTi',
    name: 'Gaga Ball',
    capacity: 24,
    description: 'Gaga Ball is a super fast-paced game played in a walled pit where everyone tries to hit a '
        'soft ball at other players\' legs, below the knees. If the ball touches you below the knees, you\'re'
        'out, and the last player left in the pit wins the round!',
    isSkillsRec: false,
  );

  static final PrincipalActivity boating = PrincipalActivity(
    id: 'boating-principal_activity-brn-Cs4OhTi',
    name: 'Boating',
    capacity: 12,
    description: 'Grab a paddle and hop into a boat to explore the lagoon with your friends!',
    isSkillsRec: false,
  );

  static final PrincipalActivity climbing = PrincipalActivity(
    id: 'climbing_wall-principal_activity-brn-Cs4OhTi',
    name: 'Climbing Wall',
    capacity: 12,
    description: 'Clip into a safety harness and see how high you can climb up the rock wall!',
    isSkillsRec: false,
  );

  static final PrincipalActivity artsAndCrafts = PrincipalActivity(
    id: 'arts_and_crafts-principal_activity-brn-6QeyXQW',
    name: 'Arts and Crafts',
    capacity: 20,
    description: 'Get creative with paint, paper, glue, and lots of other cool supplies to make '
        'your own awesome projects! You can draw, build, or design something totally unique to '
        'take home.',
    isSkillsRec: false,
  );

  static final PrincipalActivity tieDye = PrincipalActivity(
    id: 'tie_dye-principal_activity-brn-09rnYJR',
    name: 'Tie Dye',
    capacity: 16,
    description: 'Twist, fold, and tie up a t-shirt or other fabric using rubber bands. Don\'t '
        'forget to bring something white to dye!!!',
    isSkillsRec: false,
  );

  static final PrincipalActivity archery = PrincipalActivity(
    id: 'archery-principal_activity-brn-AkmWEg4',
    name: 'Archery',
    capacity: 16,
    description: 'Take aim at the target, draw back the string, and see if you can hit a bullseye!',
    isSkillsRec: false,
  );

  static final PrincipalActivity soccer = PrincipalActivity(
    id: 'soccer-principal_activity-brn-l7g5Kwm',
    name: 'Soccer',
    capacity: 18,
    description: 'Hit the ball field, practice your kicks and passes, and work with your team to score!',
    isSkillsRec: true,
  );

  static final PrincipalActivity cardGames = PrincipalActivity(
    id: 'card_games-principal_activity-brn-3SObvwL',
    name: 'Card Games',
    capacity: 20,
    description: 'Grab a deck of cards and gather around a table with friends for some fun games!',
    isSkillsRec: true,
  );
}