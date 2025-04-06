// import 'package:flutter/cupertino.dart';
// import 'package:get/get.dart';
// import 'package:get/get_core/src/get_main.dart';
// import 'package:shadcn_ui/shadcn_ui.dart';
//
// import '../exceptions/core_exceptions.dart';
//
// class ExceptionHandlerService extends GetxService {
//   /// Handles exceptions by logging and displaying a toast.
//   void handle(dynamic error, [StackTrace? stack]) {
//     // Log every error regardless of type.
//     //coreLogger.logException(error, stack: stack); // TODO: Make CoreLogger
//
//     // Determine the message to display.
//     String message;
//     if (error is AppException && error.alertUser) {
//       message = error.message;
//     } else {
//       message = "An unexpected error occurred.";
//     }
//
//     // Show a toast with the error message.
//     _showToast(message);
//   }
//
//   void _showToast(String message) {
//     // Use Get.context to access the current BuildContext.
//     final context = Get.context;
//     if (context != null) {
//       ShadToaster.of(context).show(
//         ShadToast.destructive(
//           title: const Text('Uh oh! Something went wrong'),
//           description: Text(message),
//         ),
//       );
//     } else {
//       // Fallback if context isn't available
//       Get.snackbar('Error', message);
//     }
//   }
// }