import 'package:bessie/common/utils/helpers/bess_id_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../common/utils/formatters/formatter.dart';

abstract class BessObject {
  String id;
  DateTime createdAt;
  DateTime updatedAt;
  final String idTitle;
  bool isUpdating = false;

  BessObject({
    required this.idTitle,
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? BessIdFunctions.getBessId(idTitle),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  String get formattedCreatedAt => BessFormatter.formatDate(createdAt);
  String get formattedUpdatedAt => BessFormatter.formatDate(updatedAt);

  String bessToString();
  Map<String, dynamic> toJson();

  Map<String, dynamic> toJsonSuper() {
    return {
      'id': id,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  void overwriteBessObjectFromJson(Map<String, dynamic> json, bool clone) {
    if (!clone) {
      id = json['id'] as String;
    }
    createdAt = json['createdAt'] is Timestamp ? (json['createdAt'] as Timestamp).toDate() : DateTime.now();
    updatedAt = json['updatedAt'] is Timestamp ? (json['updatedAt'] as Timestamp).toDate() : DateTime.now();
  }

  String toStringSuper() {
    return '[$id]';
  }

  void updateTimestamp() {
    if (isUpdating) {
      return;
    }
    isUpdating = true;
    updatedAt = DateTime.now();
    Future.delayed(const Duration(milliseconds: 30), () {
      isUpdating = false;
    });
  }
}
