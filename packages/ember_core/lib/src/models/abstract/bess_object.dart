import 'package:ember_core/ember_core_utils.dart';

typedef BessObjectObjId = String;

abstract class BessObject { // TODO: remove timestamp
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
  })  : objId = objId ?? IdFunctions.generateBessId('obj', domain, type, idTag),
        createdAt = (createdAt ?? DateTime.now()).toUtc(),
        updatedAt = (updatedAt ?? DateTime.now()).toUtc();

  String get formattedCreatedAt => Formatter.formatDate(createdAt.toLocal());
  String get formattedUpdatedAt => Formatter.formatDate(updatedAt.toLocal());

  String bessToString();
  Map<String, dynamic> toJson();
  void purgeRef(String ref);

  Map<String, dynamic> toJsonSuper() {
    return {
      'objId': objId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  void overwriteBessObjectFromJson(Map<String, dynamic> json) {
    objId = json['objId'] as String;
    createdAt = (json['createdAt'] as DateTime?)?.toUtc() ?? DateTime.now().toUtc();
    updatedAt = (json['updatedAt'] as DateTime?)?.toUtc() ?? DateTime.now().toUtc();
  }

  String toStringSuper() {
    return '[$objId]';
  }

  void updateTimestamp() {
    updatedAt = DateTime.now().toUtc();
  }
}
