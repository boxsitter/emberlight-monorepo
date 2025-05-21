import 'package:ember_core/src/models/interfaces/time_interval.dart';

import '../../../ember_core_models.dart';

typedef BlockId = String;

abstract class ScheduleBlock extends CoreObject implements TimeInterval{
  ScheduleBlock({required super.domain, required super.type, required super.idTag});

  String get name;
  bool get isTemplate;
}