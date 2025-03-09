import 'package:bessie/data/abstract/bess_object.dart';

abstract class ScheduleBlock extends BessObject {
  String name;

  ScheduleBlock({
    required super.idTitle,
    required this.name,
  });

}