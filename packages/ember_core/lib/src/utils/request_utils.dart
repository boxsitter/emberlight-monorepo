import 'dart:math';

import '../../ember_core_models.dart';

class RequestUtils {
  static PushRequest mergeRequests(PushRequest pushRequest1, PushRequest pushRequest2, int keepMessageFrom) {
    String message;
    if (keepMessageFrom == 2) {
      message = pushRequest2.confirmationMessage;
    } else {
      message = pushRequest1.confirmationMessage;
    }

    return PushRequest(
      disarmRequirementsLevel: max(pushRequest1.disarmRequirementsLevel, pushRequest2.disarmRequirementsLevel),
      objectsToPush: {...pushRequest1.objectsToPush, ...pushRequest2.objectsToPush},
      confirmationMessage: message,
    );
  }
}