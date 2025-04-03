// core/lib/messages.dart
import 'package:ember_core/ember_core_utils.dart';

enum BroadcastType { info, warning, error }
enum InquiryType { confirmation }
abstract class CoreMessage{}

// Asynchronous alert or message intended to be displayed to the user
class CoreBroadcast implements CoreMessage{
  final BroadcastType type;
  final String title;
  final String? content;
  final Map<String, List<String>>? foldedSubcontent;

  CoreBroadcast({
    required this.type,
    required this.title,
    this.content,
    this.foldedSubcontent,
  });
}

// Message expecting a response from the UI
class CoreInquiry implements CoreMessage{
  final String inquiryId;
  final InquiryType type;
  final String title;
  final String? content;
  final Map<String, List<String>>? foldedSubcontent;

  CoreInquiry({
    required this.type,
    required this.title,
    this.content,
    this.foldedSubcontent,
  }) : inquiryId = IdFunctions.generateSimpleId('inquiry');
}

class InquiryResponse {
  final String inquiryId;
  final InquiryType type;
  final bool? userConfirmed;

  InquiryResponse({
    required this.inquiryId,
    required this.type,
    this.userConfirmed,
  });
}
