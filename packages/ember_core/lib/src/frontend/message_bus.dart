// bus for sending messages to the frontend to be displayed to the user

import 'dart:async';
import 'core_messages.dart';

class MessageBus {
  // A single broadcast controller that can emit any CoreMessage.
  static final StreamController<CoreMessage> _controller =
  StreamController<CoreMessage>.broadcast();

  // Expose the stream so the UI can listen.
  static Stream<CoreMessage> get stream => _controller.stream;

  // This map holds a Completer for each "inquiry" that the core side is waiting on.
  static final Map<String, Completer<InquiryResponse>> _pendingInquiries = {};

  // ============== BROADCAST (no response) ============== //

  /// Post a simple broadcast that doesn't require any UI response.
  static void broadcast(CoreBroadcast broadcast) {
    if (!_controller.isClosed) {
      _controller.add(broadcast);
    }
  }

  // ============== INQUIRY (needs response) ============== //
  // TODO: Add some method of confirming that an inquiry was at least received by a listening frontend
  // TODO: If not, throw a warning stating that the action likely won't complete successfully since nobody is listening to disarm it
  // TODO: That error should probably be handled in the disarm method but postInquiry's job is to alert if it is unlikely that anyone is listening

  /// Posts an inquiry that the core will `await` for the user’s response.
  static Future<InquiryResponse> poseInquiry(CoreInquiry inquiry) {
    final completer = Completer<InquiryResponse>();
    _pendingInquiries[inquiry.inquiryId] = completer;

    if (!_controller.isClosed) {
      _controller.add(inquiry);
    }

    // Return a Future<InquiryResponse> that completes once the UI calls respondToInquiry().
    return completer.future;
  }

  /// Called by the UI when the user has answered an inquiry (e.g. tapped OK or Cancel).
  static void respondToInquiry(InquiryResponse response) {
    final completer = _pendingInquiries.remove(response.inquiryId);
    if (completer != null && !completer.isCompleted) {
      completer.complete(response);
    }
    // If there's no matching inquiryId, either the inquiry was never posted or was already completed.
  }
}