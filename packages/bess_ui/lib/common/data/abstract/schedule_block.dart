import 'package:bessie/common/data/abstract/bess_object.dart';

abstract class ScheduleBlock extends BessObject {
  String name;

  ScheduleBlock(super.idTitle, BessObject super.dataParent, {
    required this.name
  });
}