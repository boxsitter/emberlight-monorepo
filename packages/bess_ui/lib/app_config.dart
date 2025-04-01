import 'package:bessie/data/bess_objects/domains/organization.dart';
import 'package:bessie/data/bess_objects/domains/season.dart';
import 'package:get/get.dart';

import 'common/constants/catppuccin_base.dart';
import 'common/routes/routes.dart';
import 'data/bess_objects/domains/session.dart';
import 'data/repositories/push_repository.dart';

class AppConfig {
  static Flavor theme = catppuccin.latte;

  static const double minWindowWidth = 640;
  static const double minWindowHeight = 480;

  static const Transition defaultTransitionAnimation = Transition.noTransition;

  static const String homePage = BessRoutes.home;

  static const bool updateHardCodedDataOnRun = false;
  static const bool createHardCodedDataOnRun = false;
}

// class HardcodedObjectConfigs {
//   final PushRepository bessObjectRepo= Get.find<PushRepository>();
//
//   final Organization ygs = Organization(
//     id: 'organization-ymca_of_greater_seattle-00f1d57b-8735-43ea-b131-a865c970dcc7',
//     name: 'YMCA Of Greater Seattle',
//     createdAt: DateTime.parse('2025-03-17T04:58:08.000Z').toUtc(),
//     branches: {'branch-colman-ebc16a28-f210-410b-80f9-fd4b7a09049b'},
//   );
//
//   final Branch colman = Branch(
//     id: 'branch-colman-ebc16a28-f210-410b-80f9-fd4b7a09049b',
//     name: 'Colman',
//     createdAt: DateTime.parse('2025-03-17T05:10:29.000Z').toUtc(),
//     seasons: {'season-2025-e932c367-e83d-4d75-95b6-87f0afbbcf23'},
//   );
//
//   final Season season = Season(
//     id: 'season-2025-e932c367-e83d-4d75-95b6-87f0afbbcf23',
//     name: '2025',
//     createdAt: DateTime.parse('2025-03-17T05:19:16.000Z').toUtc(),
//     startDate: DateTime(2025, 1, 1).toUtc(),
//     endDate: DateTime(2026, 1, 1).toUtc(),
//     sessions: {'session-test_session-6a23c837-3136-4b16-9837-601abcaa9819'},
//   );
//
//   final Schedule schedule = Schedule(
//       id: 'schedule-test_schedule-6a23c537-3136-4b16-9837-601abdaa9819'
//   );
//
//   final Cabin henderson = Cabin(
//     name: 'Henderson',
//     capacity: 12,
//     id: 'cabin-henderson-6a23c537-3136-4b16-9837-601rtdaa9819',
//   );
//
//   final Cabin leckenby = Cabin(
//     name: 'Leckenby',
//     capacity: 12,
//     id: 'cabin-leckenby-6a23c537-3126-4b16-9837-601rtdaa9819',
//   );
//
//   final Cabin yarrow = Cabin(
//     name: 'Yarrow',
//     capacity: 12,
//     id: 'cabin-yarrow-6a23c537-3126-4b16-9837-601rtdaa9819',
//   );
//
//   final Cabin freeman1 = Cabin(
//     name: 'Freeman 1',
//     capacity: 14,
//     id: 'cabin-freeman_1-6a23c537-3136-4b16-9837-631utdaa9819',
//   );
//
//   final Session session = Session(
//     id: 'session-test_session-6a23c837-3136-4b16-9837-601abcaa9819',
//     name: 'Test Session',
//     createdAt: DateTime.parse('2025-03-17T05:35:01.000Z').toUtc(),
//     startDate: DateTime(2025, 1, 1).toUtc(),
//     endDate: DateTime(2026, 1, 1).toUtc(),
//     scheduleId: 'schedule-test_schedule-6a23c537-3136-4b16-9837-601abdaa9819',
//   );
//
//   Future<void> createObjects() async {
//     // Each updateDocument call will convert these UTC datetimes to Firestore Timestamps.
//     await bessObjectRepo.pushObject(ygs);
//     await bessObjectRepo.pushObject(colman);
//     await bessObjectRepo.pushObject(season);
//
//     await bessObjectRepo.pushObject(schedule);
//
//     await bessObjectRepo.pushObject(henderson);
//     await bessObjectRepo.pushObject(leckenby);
//     await bessObjectRepo.pushObject(yarrow);
//     await bessObjectRepo.pushObject(freeman1);
//
//     Set<String> cabinsInUse = {};
//     cabinsInUse.add(henderson.id);
//     cabinsInUse.add(leckenby.id);
//     cabinsInUse.add(yarrow.id);
//     cabinsInUse.add(freeman1.id);
//     session.cabinsInUseIds.addAll(cabinsInUse);
//
//     await bessObjectRepo.pushObject(session);
//   }
//
//   Future<void> updateObjects() async {
//     await bessObjectRepo.updateDocument({
//       'id': ygs.id,
//       'name': ygs.name,
//       'branches': ygs.branches.toList(),
//       'createdAt': ygs.createdAt.toUtc(),
//     });
//
//     await bessObjectRepo.updateDocument({
//       'id': colman.id,
//       'name': colman.name,
//       'seasons': colman.seasons.toList(),
//       'activityTypeIds': [],
//       'createdAt': colman.createdAt.toUtc(),
//     });
//
//     await bessObjectRepo.updateDocument({
//       'id': season.id,
//       'name': season.name,
//       'startDate': season.startDate.toUtc(),
//       'endDate': season.endDate.toUtc(),
//       'sessions': season.sessions.toList(),
//       'createdAt': season.createdAt.toUtc(),
//     });
//
//     await bessObjectRepo.updateDocument({
//       'id': schedule.id,
//     });
//
//     for (final cabin in [henderson, leckenby, yarrow, freeman1]) {
//       await bessObjectRepo.updateDocument({
//         'id': cabin.id,
//         'name': cabin.name,
//         'capacity': cabin.capacity,
//       });
//     }
//
//     await bessObjectRepo.updateDocument({
//       'id': session.id,
//       'name': session.name,
//       'startDate': session.startDate.toUtc(),
//       'endDate': session.endDate.toUtc(),
//       'scheduleId': session.scheduleId,
//       'cabinsInUseIds': [
//         henderson.id,
//         leckenby.id,
//         yarrow.id,
//         freeman1.id,
//       ],
//       'createdAt': session.createdAt.toUtc(),
//     });
//   }
// }