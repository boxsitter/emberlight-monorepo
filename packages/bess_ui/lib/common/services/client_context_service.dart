import 'package:get/get.dart';

class ClientContextService extends GetxService {
  String currentSession = '/organizations/organization-ygs-13e1e95e-1fe3-426f-88d4-6ed23c5e5fa5/'
                          'branches/branch-colman-367cf135-575a-49f6-b4e4-e9e79f4d0206/'
                          'seasons/season-2025-eca96abe-d45e-47e0-8151-9953e8712f3f/'
                          'sessions/session-test-session-64da8fcd-ade0-486e-b175-6c2ddb3b58a5';

  void changeContext(String newPath){
    currentSession = newPath;
  }

  void setDefaultContext()
}