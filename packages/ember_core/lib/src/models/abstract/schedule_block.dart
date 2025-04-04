import 'package:ember_core/ember_core_models.dart';

abstract class ScheduleBlock extends BessObject {
  final String name;

  ScheduleBlock({
    required this.name,
    required super.domain,
    required super.type,
    required super.idTag,
    super.id,
    super.createdAt,
    super.updatedAt,
  }) : super();

}