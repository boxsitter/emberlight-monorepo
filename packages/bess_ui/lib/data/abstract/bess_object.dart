import 'package:bessie/common/utils/helpers/bess_id_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../common/constants/enums.dart';
import '../../common/utils/formatters/formatter.dart';

abstract class BessObject {
  String id; // TODO: Add chld- and ref- prefixes to reference ids
  DateTime createdAt;
  DateTime updatedAt;
  //String organizationId;
  //String branchId;
  //Role minRoleRead;
  //Role minRoleWrite;

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
