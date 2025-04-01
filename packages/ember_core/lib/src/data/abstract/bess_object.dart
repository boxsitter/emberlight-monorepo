import 'package:bessie/common/utils/helpers/bess_id_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../common/utils/formatters/formatter.dart';

typedef BessObjectObjId = String;

abstract class BessObject {
  BessObjectObjId objId;
  DateTime createdAt;
  DateTime updatedAt;

  final String domain;
  final String type;
  final String idTag;

  BessObject({
    required this.domain,
    required this.type,
    required this.idTag,
    String? objId,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : objId = objId ?? BessIdFunctions.generateBessId('obj', domain, type, idTag),
        createdAt = (createdAt ?? DateTime.now()).toUtc(),
        updatedAt = (updatedAt ?? DateTime.now()).toUtc();

  String get formattedCreatedAt => BessFormatter.formatDate(createdAt.toLocal());
  String get formattedUpdatedAt => BessFormatter.formatDate(updatedAt.toLocal());

  String bessToString();
  Map<String, dynamic> toJson();
  void purgeRef(String ref);

  Map<String, dynamic> toJsonSuper() {
    return {
      'objId': objId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  void overwriteBessObjectFromJson(Map<String, dynamic> json) {
    objId = json['objId'] as String;
    // Convert any Timestamp to a DateTime in UTC; default to now (UTC) if missing or invalid.
    createdAt = (json['createdAt'] is Timestamp) ? (json['createdAt'] as Timestamp).toDate().toUtc() : DateTime.now().toUtc();
    updatedAt = (json['updatedAt'] is Timestamp) ? (json['updatedAt'] as Timestamp).toDate().toUtc() : DateTime.now().toUtc();
  }

  String toStringSuper() {
    return '[$objId]';
  }

  void updateTimestamp() {
    updatedAt = DateTime.now().toUtc();
  }
}
