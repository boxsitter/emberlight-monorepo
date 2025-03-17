import 'package:get/get_state_manager/src/rx_flutter/rx_disposable.dart';

class PathService extends GetxService {
  String workingDirectory  = '';

  // You could add methods to update this path based on context changes.
  bool updateSessionPath(String newPath) {
    // Check if newPath contains the "/sessions/" segment.
    if (!newPath.contains('sessions')) {
      return false;
    }

    // Split the path by "/" and remove any empty segments.
    final segments = newPath.split('/').where((s) => s.isNotEmpty).toList();

    // Expecting at least: organizations, orgId, branches, branchId, seasons, seasonId, sessions, sessionId.
    if (segments.length < 8) {
      return false;
    }

    // Check that the second-to-last segment is "sessions"
    // and that the last segment starts with "session".
    if (segments[segments.length - 2] == 'sessions' &&
        segments.last.startsWith('session')) {
      workingDirectory = newPath;
      return true;
    }

    return false;
  }
}