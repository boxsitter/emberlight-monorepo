import 'package:bessie/common/data/abstract/bess_object.dart';

abstract class ScheduleBlock extends BessObject {
  String name;

  ScheduleBlock(final String idTitle, {required this.name}) : super('$idTitle-');
}