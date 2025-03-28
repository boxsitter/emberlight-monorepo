import 'package:bessie/common/utils/helpers/bess_id_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../common/utils/formatters/formatter.dart';

typedef BessObjectId = String;

abstract class BessObject {
  BessObjectId id; // TODO: Add chld- and ref- prefixes to reference ids
  DateTime createdAt;
  DateTime updatedAt;
  //String organizationId;
  //String branchId;
  //Role minRoleRead;
  //Role minRoleWrite;

  final String idTitle;

  BessObject({
    required this.idTitle,
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? BessIdFunctions.getBessId(idTitle),
        createdAt = (createdAt ?? DateTime.now()).toUtc(),
        updatedAt = (updatedAt ?? DateTime.now()).toUtc();

  String get formattedCreatedAt => BessFormatter.formatDate(createdAt.toLocal());
  String get formattedUpdatedAt => BessFormatter.formatDate(updatedAt.toLocal());

  String bessToString();
  Map<String, dynamic> toJson();
  //List<String> getSubObjectIds(); // return the ids of every BessObject that this object CONTAINS
  //void replaceReferencesToId(String idToReplace, String newReferenceId); // any references to BessObjects should be checked. If matching idToReplace, replace with new reference

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
    // Convert any Timestamp to a DateTime in UTC; default to now (UTC) if missing or invalid.
    createdAt = (json['createdAt'] is Timestamp) ? (json['createdAt'] as Timestamp).toDate().toUtc() : DateTime.now().toUtc();
    updatedAt = (json['updatedAt'] is Timestamp) ? (json['updatedAt'] as Timestamp).toDate().toUtc() : DateTime.now().toUtc();
  }

  String toStringSuper() {
    return '[$id]';
  }

  void updateTimestamp() {
    updatedAt = DateTime.now().toUtc();
  }
}
