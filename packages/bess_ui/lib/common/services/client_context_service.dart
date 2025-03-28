import 'package:bessie/data/models/schedule/schedule.dart';
import 'package:bessie/data/repositories/bess_object_repository.dart';
import 'package:get/get.dart';

import '../../data/models/branch.dart';
import '../../data/models/camper.dart';
import '../../data/models/season.dart';
import '../../data/models/session.dart';
import '../../data/user_houck_leyton.dart';

class ClientContextService extends GetxService {
  BessObjectRepository bessObjectRepo= Get.find<BessObjectRepository>();

  String organizationId = '';
  String branchId = '';
  String seasonId = '';
  String sessionId = '';

  Future<Session> get session async => await bessObjectRepo.getObject(sessionId, Session.fromJson);
  Future<Schedule> get schedule async => await bessObjectRepo.getObject(await bessObjectRepo.getFieldValue(sessionId, 'scheduleId'), Schedule.fromJson);
  Future<String> get scheduleId async => await bessObjectRepo.getFieldValue(sessionId, 'scheduleId');
  Future<Set<CabinId>> get cabinsInUseIds async => await (bessObjectRepo.getSetField(sessionId, 'cabinsInUseIds'));

  @override
  void onInit() {
    super.onInit();
    // Call setDefaultContext when the service is initialized.
    setDefaultContext();
  }

  // TODO: This is sketchy rn. I will still need to implement robust checks for no assigned orgs/branches and no current or existing seasons or sessions
  Future<void> setDefaultContext() async {
    organizationId = User.organizationId;
    branchId = User.branchId;

    // Retrieve the unique active Season.
    Branch branch = await bessObjectRepo.getObject(branchId, Branch.fromJson);
    seasonId = await bessObjectRepo.getFirstActiveObjectId(branch.seasons);

    // Retrieve the unique active Session.
    Season season = await bessObjectRepo.getObject(seasonId, Season.fromJson);
    sessionId = await bessObjectRepo.getFirstActiveObjectId(season.sessions);
  }
}