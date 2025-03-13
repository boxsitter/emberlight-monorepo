import 'package:get/get_state_manager/src/rx_flutter/rx_disposable.dart';

class PathService extends GetxService {
  String workingDirectory  = '/organizations/organization-ygs-13e1e95e-1fe3-426f-88d4-6ed23c5e5fa5/'
      'branches/branch-colman-367cf135-575a-49f6-b4e4-e9e79f4d0206/'
      'seasons/season-2025-eca96abe-d45e-47e0-8151-9953e8712f3f/'
      'sessions/session-test-session-64da8fcd-ade0-486e-b175-6c2ddb3b58a5';

  // You could add methods to update this path based on context changes.
  bool updateSessionPath(String newPath) {
    // Check if newPath contains the "/sessions/" segment.
    if (!newPath.contains('/sessions/')) {
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