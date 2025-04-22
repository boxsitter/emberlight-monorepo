// listens to the core for any asynchronous messages to display to the user

import 'dart:async';

import 'package:bessie/common/widgets/popups/depreciated.dart';
import 'package:ember_core/ember_core_frontend.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_disposable.dart';

class MessageListener extends GetxService {
  late final StreamSubscription<CoreMessage> _sub;

  @override
  void onInit() {
    super.onInit();
    // Start listening:
    _sub = MessageBus.stream.listen((CoreMessage msg) {
      if (msg is CoreBroadcast) {
        _handleBroadcast(msg);
      } else if (msg is CoreInquiry) {
        _handleInquiry(msg);
      }
    });
  }

  void _handleBroadcast(CoreBroadcast broadcast) {
    // TODO: properly handle displaying errors/info to user with various severity levels
    // e.g. show a Snackbar, a toast, or log
    print('Broadcast: ${broadcast.title} => ${broadcast.content}');
  }

  void _handleInquiry(CoreInquiry inquiry) async {
    bool confirmed = await depreciated(inquiry);
    respondToConfirmationInquiry(inquiry, confirmed);
  }

  void respondToConfirmationInquiry (CoreInquiry inquiry, bool userConfirmed) {
    if (inquiry.type != InquiryType.confirmation) {
      throw ArgumentError('Inquiry must be of type "confirmation" to confirm it');
    }

    MessageBus.respondToInquiry(InquiryResponse(
      inquiryId: inquiry.inquiryId,
      type: inquiry.type,
      userConfirmed: userConfirmed,
    ));
  }

  @override
  void onClose() {
    _sub.cancel();
    super.onClose();
  }
}