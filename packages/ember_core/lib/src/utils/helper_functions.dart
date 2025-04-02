

// class BessHelperFunctions {
//   // TODO: fix this, don't use timestamp anymore
//   static DateTime parseDate(dynamic value) {
//     if (value is Timestamp) {
//       return value.toDate();
//     } else if (value is String) {
//       return DateTime.parse(value);
//     }
//     throw Exception("Invalid date type: ${value.runtimeType}");
//   }
//
//   static void updateDocumentTimestamp(Map<String, dynamic> json) {
//     json['updatedAt'] = Timestamp.fromDate(DateTime.now().toUtc());
//   }
//}
