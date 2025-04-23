
import 'package:ember_core/ember_core_frontend.dart';
import 'package:ember_core/ember_core_models.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_disposable.dart';


class CommitService extends GetxService{
  Future<bool> disarmCommit(Commit commit) async {
    if (!commit.armed) {
      return true;
    }
    if (commit.disarmRequirementsLevel == 0) {
      commit.disarm();
      return true;
    }
    if (commit.disarmRequirementsLevel == 1) {
      // TODO: Give the user details about operation
      bool confirmed = (await MessageBus.poseInquiry(
        CoreInquiry(
            type: InquiryType.confirmation,
            title: 'Confirm Action',
            content: commit.confirmationMessage
        ))).userConfirmed!;

      if (confirmed) {
        commit.disarm();
        return true;
      } else {
        return false;
      }
    }
    return false;
  }


}