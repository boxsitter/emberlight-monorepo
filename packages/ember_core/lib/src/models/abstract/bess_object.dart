import 'package:ember_core/ember_core_utils.dart';

typedef BessObjectObjId = String;

abstract class BessObject { // TODO: remove timestamp
  BessObjectObjId id;
  DateTime createdAt;
  DateTime updatedAt;

  final String domain;
  final String type;
  final String idTag;

  BessObject({
    required this.domain,
    required this.type,
    required this.idTag,
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? IdFunctions.generateBessId( domain, type, idTag),
        createdAt = (createdAt ?? DateTime.now()).toUtc(),
        updatedAt = (updatedAt ?? DateTime.now()).toUtc();

  String get formattedCreatedAt => Formatter.formatDate(createdAt.toLocal());
  String get formattedUpdatedAt => Formatter.formatDate(updatedAt.toLocal());

  String bessToString();
  Map<String, dynamic> toJson();
  void purgeRef(String id);

  Map<String, dynamic> toJsonSuper() {
    return {
      'id': id,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  void overwriteBessObjectFromJson(Map<String, dynamic> json) {
    id = json['id'] as String;
    createdAt = (json['createdAt'] as DateTime?)?.toUtc() ?? DateTime.now().toUtc();
    updatedAt = (json['updatedAt'] as DateTime?)?.toUtc() ?? DateTime.now().toUtc();
  }

  String toStringSuper() {
    return '[$id]';
  }

  void updateTimestamp() {
    updatedAt = DateTime.now().toUtc();
  }
}
