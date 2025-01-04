// import 'dart:async';
//
// import 'package:get/get_state_manager/src/rx_flutter/rx_disposable.dart';
//
// class LoggingService extends GetxService {
//   final _logStreamController = StreamController<String>.broadcast();
//
//   void log(String message) {
//     final adjustedText = message.replaceAll('\n', '\r\n ');
//     _logStreamController.add('\r\n\x1B[96m $adjustedText\x1B[0m');
//   }
//
//   void error(String message) {
//     final adjustedText = message.replaceAll('\n', '\r\n ');
//     _logStreamController.add('\r\n\x1B[91m $adjustedText\x1B[0m');
//   }
//
//   Stream<String> get logStream => _logStreamController.stream;
//
//   @override
//   void onClose() {
//     _logStreamController.close(); // Clean up resources
//     super.onClose();
//   }
// }

