import 'dart:math';

import 'package:bessie/data/helper_objects/push_request.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_disposable.dart';

import '../../data/abstract/bess_object.dart';
import '../widgets/popups/confirm_operation.dart';

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
      bool confirmed = await showConfirmationDialog( // TODO: Give the user details about operation
        title: 'Confirm Action',
        message: pushRequest.confirmationMessage,
      );
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