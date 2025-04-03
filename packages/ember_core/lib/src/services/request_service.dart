import 'dart:math';

import 'package:ember_core/ember_core_frontend.dart';
import 'package:ember_core/ember_core_models.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_disposable.dart';


class RequestService extends GetxService{
  Future<bool> disarmRequest(PushRequest pushRequest) async {
    if (!pushRequest.armed) {
      return true;
    }
    if (pushRequest.disarmRequirementsLevel == 0) {
      pushRequest.disarm();
      return true;
    }
    if (pushRequest.disarmRequirementsLevel == 1) {
      // TODO: Give the user details about operation
      bool confirmed = (await MessageBus.poseInquiry(
        CoreInquiry(
            type: InquiryType.confirmation,
            title: 'Confirm Action',
            content: pushRequest.confirmationMessage
        ))).userConfirmed!;

      if (confirmed) {
        pushRequest.disarm();
        return true;
      } else {
        return false;
      }
    }
    return false;
  }

  PushRequest mergeRequests(PushRequest pushRequest1, PushRequest pushRequest2, int keepMessageFrom) {
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