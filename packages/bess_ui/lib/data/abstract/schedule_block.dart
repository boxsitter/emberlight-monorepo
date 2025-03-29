import 'package:bessie/data/abstract/bess_object.dart';

abstract class ScheduleBlock extends BessObject {
  final String name;

  ScheduleBlock({
    required this.name,
    required super.idTitle,
    super.id,
    super.createdAt,
    super.updatedAt,
  }) : super();

}