import '../../../ember_core_models.dart';
import '../../../ember_core_utils.dart';
import '../core_objects/schedule_day.dart';

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

  String get formattedCreatedAt => DateTimeHelpers.formatDate(createdAt.toLocal(), true);
  String get formattedUpdatedAt => DateTimeHelpers.formatDate(updatedAt.toLocal(), true);

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

  static final Map<String, JsonFactory> _fromJsons = {
    'cabin_dependent': (json) => CabinDependent.fromJson(json),
    'activity_dependent': (json) => ActivityDependent.fromJson(json),

    'branch': (json) => Branch.fromJson(json),
    'organization': (json) => Organization.fromJson(json),
    'season': (json) => Season.fromJson(json),
    'session': (json) => Session.fromJson(json),

    'principal_activity': (json) => PrincipalActivity.fromJson(json),
    'principal_cabin': (json) => PrincipalCabin.fromJson(json),

    'ama_block': (json) => AMABlock.fromJson(json),
    'camper': (json) => Camper.fromJson(json),
    'schedule': (json) => Schedule.fromJson(json),
    'schedule_day': (json) => ScheduleDay.fromJson(json),
    'core_user': (json) => CoreUser.fromJson(json),
  };

  static T fromJson<T>(Map<String, dynamic> json) {
    JsonFactory<dynamic>? fromJsonFunction = _fromJsons[IdFunctions.getIdPart(json['id'], 1)];
    if (fromJsonFunction == null) {
      throw StateError('NEED TO ADD ${json['id']} TO FROMJSONS LIST IN COREOBJECT!');
    }
    return fromJsonFunction(json) as T;
  }
}
