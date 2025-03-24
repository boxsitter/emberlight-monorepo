import 'package:bessie/common/services/path_service.dart';
import 'package:bessie/data/models/organization.dart';
import 'package:bessie/data/repositories/firebase_repository.dart';
import 'package:get/get.dart';

import '../../data/models/season.dart';
import '../../data/models/session.dart';
import '../../data/user_houck_leyton.dart';

class ClientContextService extends GetxService {
  FirebaseRepository firebaseRepo = Get.find<FirebaseRepository>();

  String organizationId = '';
  String branchId = '';
  String seasonId = '';
  String sessionId = '';

  @override
  void onInit() {
    super.onInit();
    // Call setDefaultContext when the service is initialized.
    setDefaultContext();
  }

  // TODO: This is sketchy rn. I will still need to implement robust checks for no assigned orgs/branches and no current or existing seasons or sessions
  Future<bool> setDefaultContext() async {
    organizationId = User.organizationId;
    branchId = User.branchId;

    // TODO: need to get the list of seasons for the user's branch
    // Retrieve the unique active Season.
    Season? currentSeason = await firebaseRepo.getFirstActiveObjectId(basePath, Season.fromJson);
    if (currentSeason == null) {
      return false;
    }

    // Build the season-specific path.
    // Typically, a season's path might be:
    // /organizations/{org}/branches/{branch}/seasons/{seasonId}
    String seasonPath = '$basePath/${currentSeason.id}';

    // Define the sessions collection path within the season.
    String sessionsPath = '$seasonPath/sessions';

    // Retrieve the unique active Session.
    Session? currentSession = await firebaseRepo.getUniqueActiveObject(sessionsPath, Session.fromJson);
    if (currentSession == null) {
      return false;
    }

    // Build the full session path, which must include the "/sessions/" segment.
    String newPath = '$sessionsPath/${currentSession.id}/';

    // Update the working directory using the path service.
    return pathService.updateSessionPath(newPath);
  }

  // returns the path to the current context's branch
  String getBranchPathOfContext() {
    // Get the current working directory from PathService.
    String workingDir = pathService.workingDirectory;

    // Split the path into non-empty segments.
    List<String> segments = workingDir.split('/').where((s) => s.isNotEmpty).toList();

    // Look for the "branches" segment.
    int branchIndex = segments.indexOf("branches");

    // If there's no "branches" segment or no branch id following it, return the original path.
    if (branchIndex == -1 || branchIndex + 1 >= segments.length) {
      return workingDir;
    }

    // Build the branch path: include segments up to and including the branch id.
    List<String> branchSegments = segments.sublist(0, branchIndex + 2);
    return '/${branchSegments.join('/')}';
  }
}