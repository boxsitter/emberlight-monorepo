import '../../ember_core.dart';

class HardcodedPrincipalActivities {
  static final Set<PrincipalActivity> list = <PrincipalActivity>{
    gagaBall,
    boating,
    climbing,
    artsAndCrafts,
    tieDye,
    archery,
    archerySkillsRec,
    soccer,
    cardGames,
    yogaAndMindfulness,
    creativeWriting,
    music,
    cricket,
    friendshipBracelets,
    nineSquare,
    beachWalk,
    shelterBuilding,
    basketball,
    giantSwing,
    canoeing,
    pickleball,
    volleyball,
    hammockTime,
    lowRopes,
    birdWatching,
    planes,
    origami,
    rockArt,
    parachuteGames,
    painting,
    bingo,
    natureHike,
    fieldGames,
    hidingFromAuthority,
    cardGamesDND,
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
    id: 'boating-principal_activity-brn-Cs4OyTi',
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
    name: 'Arts & Crafts',
    capacity: 20,
    description: 'Get creative with paint, paper, glue, and lots of other cool supplies to make '
        'your own awesome projects! You can draw, build, or design something totally unique to '
        'take home.',
    isSkillsRec: true,
  );

  static final PrincipalActivity tieDye = PrincipalActivity(
    id: 'tie_dye-principal_activity-brn-09rnYJR',
    name: 'Tie Dye',
    capacity: 10,
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

  static final PrincipalActivity archerySkillsRec = PrincipalActivity(
    id: 'archery_skills_rec-principal_activity-brn-AkmWET8',
    name: 'Archery Skills Rec',
    capacity: 16,
    description: 'Learn how to shoot a bow and arrow at a target and try to get a bullseye!',
    isSkillsRec: true,
  );

  static final PrincipalActivity soccer = PrincipalActivity(
    id: 'soccer-principal_activity-brn-l7g5Kwm',
    name: 'Soccer',
    capacity: 20,
    description: 'Practice your dribbling, passing, and shooting skills in this popular team sport.',
    isSkillsRec: true,
  );

  static final PrincipalActivity cardGames = PrincipalActivity(
    id: 'card_games-principal_activity-brn-3SObvwL',
    name: 'Card Games',
    capacity: 20,
    description: 'Grab a deck of cards and gather around a table with friends for some fun games!',
    isSkillsRec: true,
  );

  static final PrincipalActivity yogaAndMindfulness = PrincipalActivity(
    id: 'yoga_&_mindfulness-principal_activity-brn-aBcDeF1',
    name: 'Yoga & Mindfulness',
    capacity: 20,
    description: 'Relax and find your center with some light stretching and mindfulness exercises.',
    isSkillsRec: true,
  );

  static final PrincipalActivity creativeWriting = PrincipalActivity(
    id: 'creative_writing-principal_activity-brn-bCdEfG2',
    name: 'Creative Writing',
    capacity: 20,
    description: 'Let your imagination run wild and write your own stories, poems, or plays.',
    isSkillsRec: true,
  );

  static final PrincipalActivity music = PrincipalActivity(
    id: 'music-principal_activity-brn-cDeFgH3',
    name: 'Music',
    capacity: 20,
    description: 'Learn to play an instrument, sing a song, or just jam out with your friends.',
    isSkillsRec: true,
  );

  static final PrincipalActivity cricket = PrincipalActivity(
    id: 'cricket-principal_activity-brn-dEfGhI4',
    name: 'Cricket',
    capacity: 20,
    description: 'Learn the basics of this classic bat-and-ball game, popular in many parts of the world.',
    isSkillsRec: true,
  );

  static final PrincipalActivity friendshipBracelets = PrincipalActivity(
    id: 'friendship_bracelets-principal_activity-brn-eFgHiJ5',
    name: 'Friendship Bracelets',
    capacity: 20,
    description: 'Weave colorful threads together to make bracelets for you and your friends.',
    isSkillsRec: false,
  );

  static final PrincipalActivity nineSquare = PrincipalActivity(
    id: '9_square-principal_activity-brn-fGhIjK6',
    name: '9 Square',
    capacity: 20,
    description: 'A fun and fast-paced game where you try to get to the center square by hitting a ball into other players\' squares.',
    isSkillsRec: false,
  );

  static final PrincipalActivity beachWalk = PrincipalActivity(
    id: 'beach_walk-principal_activity-brn-gHiJkL7',
    name: 'Beach Walk',
    capacity: 10,
    description: 'Take a relaxing stroll along the beach, look for shells, and enjoy the ocean breeze.',
    isSkillsRec: false,
  );

  static final PrincipalActivity shelterBuilding = PrincipalActivity(
    id: 'shelter_building-principal_activity-brn-hIjKlM8',
    name: 'Shelter Building',
    capacity: 20,
    description: 'Work with your team to build a shelter in the woods using only natural materials.',
    isSkillsRec: false,
  );

  static final PrincipalActivity basketball = PrincipalActivity(
    id: 'basketball-principal_activity-brn-iJkLmN9',
    name: 'Basketball',
    capacity: 20,
    description: 'Shoot some hoops with your friends and play a pickup game.',
    isSkillsRec: false,
  );

  static final PrincipalActivity giantSwing = PrincipalActivity(
    id: 'giant_swing-principal_activity-brn-jKlMnO0',
    name: 'Giant Swing',
    capacity: 16,
    description: 'Get hoisted up high and then swing through the air for an exhilarating ride.',
    isSkillsRec: false,
  );

  static final PrincipalActivity canoeing = PrincipalActivity(
    id: 'canoeing-principal_activity-brn-kLmNoP1',
    name: 'Canoeing',
    capacity: 20,
    description: 'Grab a paddle and a friend and explore the water in a canoe.',
    isSkillsRec: false,
  );

  static final PrincipalActivity pickleball = PrincipalActivity(
    id: 'pickleball-principal_activity-brn-lMnOqR2',
    name: 'Pickleball',
    capacity: 10,
    description: 'A fun paddle sport that combines elements of tennis, badminton, and table tennis.',
    isSkillsRec: false,
  );

  static final PrincipalActivity volleyball = PrincipalActivity(
    id: 'volleyball-principal_activity-brn-mNoPrS3',
    name: 'Volleyball',
    capacity: 10,
    description: 'Bump, set, and spike your way to victory in a friendly game of volleyball.',
    isSkillsRec: false,
  );

  static final PrincipalActivity hammockTime = PrincipalActivity(
    id: 'hammock_time-principal_activity-brn-nOpQrT4',
    name: 'Hammock Time',
    capacity: 10,
    description: 'Relax and swing in a hammock with a good book or good company.',
    isSkillsRec: false,
  );

  static final PrincipalActivity lowRopes = PrincipalActivity(
    id: 'low_ropes-principal_activity-brn-oPqRsU5',
    name: 'Low Ropes',
    capacity: 20,
    description: 'Work with your team to navigate a series of challenges on a low ropes course.',
    isSkillsRec: false,
  );

  static final PrincipalActivity birdWatching = PrincipalActivity(
    id: 'bird_watching-principal_activity-brn-pQrStV6',
    name: 'Bird Watching',
    capacity: 20,
    description: 'Grab some binoculars and see how many different kinds of birds you can spot.',
    isSkillsRec: false,
  );

  static final PrincipalActivity planes = PrincipalActivity(
    id: 'planes-principal_activity-brn-qRsTuW7',
    name: 'Planes',
    capacity: 10,
    description: 'Fold paper airplanes and see whose can fly the farthest or do the coolest tricks.',
    isSkillsRec: false,
  );

  static final PrincipalActivity origami = PrincipalActivity(
    id: 'origami-principal_activity-brn-rStUvX8',
    name: 'Origami',
    capacity: 10,
    description: 'Learn the Japanese art of paper folding to create beautiful and intricate designs.',
    isSkillsRec: false,
  );

  static final PrincipalActivity rockArt = PrincipalActivity(
    id: 'rock_art-principal_activity-brn-sTuVwY9',
    name: 'Rock Art',
    capacity: 20,
    description: 'Find cool rocks and paint them to look like animals, characters, or anything you can imagine.',
    isSkillsRec: false,
  );

  static final PrincipalActivity parachuteGames = PrincipalActivity(
    id: 'parachute_games-principal_activity-brn-tUvWxZ0',
    name: 'Parachute Games',
    capacity: 20,
    description: 'Work together to make waves, play games, and have fun with a giant parachute.',
    isSkillsRec: false,
  );

  static final PrincipalActivity painting = PrincipalActivity(
    id: 'painting-principal_activity-brn-uVwXyA1',
    name: 'Painting',
    capacity: 10,
    description: 'Express your creativity with paints and a canvas to create your own masterpiece.',
    isSkillsRec: false,
  );

  static final PrincipalActivity bingo = PrincipalActivity(
    id: 'bingo-principal_activity-brn-vWxYzB2',
    name: 'Bingo',
    capacity: 10,
    description: 'A classic game of chance where you try to be the first to get five in a row.',
    isSkillsRec: false,
  );

  static final PrincipalActivity natureHike = PrincipalActivity(
    id: 'nature_hike-principal_activity-brn-wXyZaC3',
    name: 'Nature Hike',
    capacity: 20,
    description: 'Explore the trails, learn about local plants and animals, and enjoy the beauty of nature.',
    isSkillsRec: false,
  );

  static final PrincipalActivity fieldGames = PrincipalActivity(
    id: 'field_games-principal_activity-brn-xYzAbD4',
    name: 'Field Games',
    capacity: 10,
    description: 'Play a variety of fun and active games out on the field with your friends.',
    isSkillsRec: false,
  );

  static final PrincipalActivity hidingFromAuthority = PrincipalActivity(
    id: 'hiding_from_authority-principal_activity-brn-yZaBcE5',
    name: 'Hiding From Authority',
    capacity: 10,
    description: 'Camouflage yourself in ivy and sneak around camp. Try not to get spotted by any authority!',
    isSkillsRec: false,
  );

  static final PrincipalActivity cardGamesDND = PrincipalActivity(
    id: 'card_games_dnd-principal_activity-brn-zAbCdF6',
    name: 'Card Games & DND',
    capacity: 20,
    description: 'Play a variety of card games or embark on an adventure in the world of Dungeons and Dragons.',
    isSkillsRec: false,
  );
}