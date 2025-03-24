import 'package:bessie/data/models/branch.dart';
import 'package:get/get.dart';

import 'common/constants/catppuccin_base.dart';
import 'common/routes/routes.dart';
import 'data/models/organization.dart';
import 'data/models/season.dart';
import 'data/models/session.dart';
import 'data/repositories/firebase_repository.dart';

class AppConfig {
  static Flavor theme = catppuccin.latte;

  static const double minWindowWidth = 640;
  static const double minWindowHeight = 480;

  static const Transition defaultTransitionAnimation = Transition.noTransition;

  static const String homePage = BessRoutes.home;

  static const bool updateHardCodedDataOnRun = false;
}

class HardcodedObjectConfigs {
  FirebaseRepository firebaseRepo = Get.find<FirebaseRepository>();

  final Map<String, dynamic> ygsJson = {
    'id': 'organization-ymca_of_greater_seattle-00f1d57b-8735-43ea-b131-a865c970dcc7',
    'name': 'YMCA Of Greater Seattle',
    'createdAt': DateTime.parse('2025-03-17T04:58:08.000Z'),
  };

  final Map<String, dynamic> colmanJson = {
    'id': 'branch-colman-ebc16a28-f210-410b-80f9-fd4b7a09049b',
    'name': 'Colman',
    'createdAt': DateTime.parse('2025-03-17T05:10:29.000Z'),
  };

  final Map<String, dynamic> seasonJson = {
    'id': 'season-2025-e932c367-e83d-4d75-95b6-87f0afbbcf23',
    'name': '2025',
    'createdAt': DateTime.parse('2025-03-17T05:19:16.000Z'),
    'startDate': DateTime(2025, 1, 1),
    'endDate': DateTime(2026, 1, 1),
  };

  final Map<String, dynamic> sessionJson = {
    'id': 'session-test_session-6a23c837-3136-4b16-9837-601abcaa9819',
    'name': 'Test Session',
    'createdAt': DateTime.parse('2025-03-17T05:35:01.000Z'),
    'startDate': DateTime(2025, 1, 1),
    'endDate': DateTime(2026, 1, 1),
  };

  Future<void> updateObjects() async {
    await firebaseRepo.updateDocument(ygsJson);
    await firebaseRepo.updateDocument(colmanJson,);
    await firebaseRepo.updateDocument(seasonJson,);
    await firebaseRepo.updateDocument(sessionJson,);
  }
}