import 'package:ember_core/ember_core_utils.dart';

import '../../../ember_core_models.dart';

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

  String get formattedCreatedAt => Formatter.formatDate(createdAt.toLocal());
  String get formattedUpdatedAt => Formatter.formatDate(updatedAt.toLocal());

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

  static final Map<String, JsonFactory> fromJsons = {
    'cabin_dependant': (json) => CabinDependant.fromJson(json),
    'activity_dependant': (json) => ActivityDependant.fromJson(json),

    'branch': (json) => Branch.fromJson(json),
    'organization': (json) => Organization.fromJson(json),
    'season': (json) => Season.fromJson(json),
    'session': (json) => Session.fromJson(json),

    //'activity_principal': (json) => ActivityPrincipal.fromJson(json),
    //'branch_principal': (json) => BranchPrincipal.fromJson(json),

    'AMA_Block': (json) => AssignedMultiActivityBlock.fromJson(json),
    'camper': (json) => Camper.fromJson(json),
    'camper_preference': (json) => CamperPreference.fromJson(json),
    'schedule': (json) => Schedule.fromJson(json),
    // Add other types as needed.
  };

  static T fromJson<T>(Map<String, dynamic> json) {
    return fromJsons[IdFunctions.getIdPart(json['id'], 1)]!(json) as T;
  }
}
