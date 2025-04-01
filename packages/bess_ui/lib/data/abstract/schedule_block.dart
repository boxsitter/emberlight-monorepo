import 'package:bessie/data/abstract/bess_object.dart';

abstract class ScheduleBlock extends BessObject {
  final String name;

  ScheduleBlock({
    required this.name,
    required super.domain,
    required super.type,
    required super.idTag,
    super.objId,
    super.createdAt,
    super.updatedAt,
  }) : super();

}