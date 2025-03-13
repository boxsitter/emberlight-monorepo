// import 'package:firebase_crashlytics/firebase_crashlytics.dart';
// import 'package:firebase_analytics/firebase_analytics.dart';
//
// class LoggingService {
//   // Singleton instance
//   static final LoggingService _instance = LoggingService._internal();
//   factory LoggingService() => _instance;
//   LoggingService._internal();
//
//   // Instances of Firebase services
//   final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
//   String userId = 'null';
//
//   /// Logs a custom user action.
//   ///
//   /// [accountId] - The unique identifier for the user.
//   /// [deviceId] - Identifier for the device the user is on.
//   /// [message] - A custom message describing the action.
//   void logAction({
//     required String message,
//   }) {
//     final logMessage = '[$userId] - $message';
//
//     // Log to Firebase Analytics as a custom event
//     _analytics.logEvent(
//       name: 'user_action',
//       parameters: {
//         'accountId': userId,
//         'message': message,
//       },
//     );
//
//     // Also log the message to Crashlytics for context
//     FirebaseCrashlytics.instance.log(logMessage);
//   }
// }
