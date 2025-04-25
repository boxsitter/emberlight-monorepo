import 'package:ember_core/ember_core_utils.dart';

import '../../../ember_core_models.dart';
import '../core_objects/domain/branch.dart';
import '../core_objects/domain/organization.dart';
import '../core_objects/domain/season.dart';
import '../core_objects/domain/session.dart';

typedef CoreObjectObjId = String;
typedef JsonFactory<T> = T Function(Map<String, dynamic> json);

abstract class CoreObject{
  CoreObjectObjId id;
  DateTime createdAt;
  DateTime updatedAt;

  final String domain;
  final String type;
  final String idTag;

  CoreObject({
    required this.domain,
    required this.type,
    required this.idTag,
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? IdFunctions.generateCoreId( domain, type, idTag),
        createdAt = (createdAt ?? DateTime.now()).toUtc(),
        updatedAt = (updatedAt ?? DateTime.now()).toUtc();

  @override
  bool operator == (Object other) => identical(this, other) || (other is CoreObject && runtimeType == other.runtimeType && id == other.id);

  @override
  int get hashCode => id.hashCode;

  String get formattedCreatedAt => CoreFormatter.formatDate(createdAt.toLocal());
  String get formattedUpdatedAt => CoreFormatter.formatDate(updatedAt.toLocal());

  String coreToString();
  Map<String, dynamic> toJson();
  void purgeRef(String id);

  Map<String, dynamic> toJsonSuper() {
    return {
      'id': id,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  void overwriteCoreObjectFromJson(Map<String, dynamic> json) {
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

  static final Map<Type, JsonFactory> fromJsons = {
    CabinDependent: (json) => CabinDependent.fromJson(json),
    ActivityDependent: (json) => ActivityDependent.fromJson(json),

    Branch: (json) => Branch.fromJson(json),
    Organization: (json) => Organization.fromJson(json),
    Season: (json) => Season.fromJson(json),
    Session: (json) => Session.fromJson(json),

    PrincipalActivity: (json) => PrincipalActivity.fromJson(json),
    PrincipalCabin: (json) => PrincipalCabin.fromJson(json),

    AMABlock: (json) => AMABlock.fromJson(json),
    Camper: (json) => Camper.fromJson(json),
    Schedule: (json) => Schedule.fromJson(json),
  };

  static T fromJson<T>(Map<String, dynamic> json) {
    JsonFactory<dynamic>? fromJsonFunction = fromJsons[T];
    if (fromJsonFunction == null) {
      throw StateError('NEED TO ADD ${json['id']} TO FROMJSONS LIST IN COREOBJECT!');
    }
    return fromJsonFunction(json) as T;
  }
}
