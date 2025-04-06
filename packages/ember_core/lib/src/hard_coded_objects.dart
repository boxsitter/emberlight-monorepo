import 'package:ember_core/ember_core_models.dart';
import 'package:get/get.dart';

import '../ember_core_backend.dart';

class HardcodedObjects {

  static final Organization ygs = Organization(
    name: 'YMCA Of Greater Seattle',
    createdAt: DateTime.parse('2025-03-17T04:58:08.000Z').toUtc(),
  );

  static final Branch colman = Branch(
    name: 'Colman',
    createdAt: DateTime.parse('2025-03-17T05:10:29.000Z').toUtc(),
  );

  static final Season season = Season(
    name: '2025',
    createdAt: DateTime.parse('2025-03-17T05:19:16.000Z').toUtc(),
    startDate: DateTime(2025, 1, 1).toUtc(),
    endDate: DateTime(2026, 1, 1).toUtc(),
  );

  static final Session session = Session(
    name: 'Test Session',
    createdAt: DateTime.parse('2025-03-17T05:35:01.000Z').toUtc(),
    startDate: DateTime(2025, 1, 1).toUtc(),
    endDate: DateTime(2026, 1, 1).toUtc(),
  );

  static final Schedule schedule = Schedule();

  static final PrincipalCabin henderson = PrincipalCabin(
    name: 'Henderson',
    capacity: 12,
  );

  static final PrincipalCabin leckenby = PrincipalCabin(
    name: 'Leckenby',
    capacity: 12,
  );

  static final PrincipalCabin yarrow = PrincipalCabin(
    name: 'Yarrow',
    capacity: 12,
  );

  static final PrincipalCabin freeman1 = PrincipalCabin(
    name: 'Freeman 1',
    capacity: 14,
  );

  static final Set<CoreObject> hardcodedObjects = {
    ygs,
    colman,
    season,
    session,
    schedule,
    henderson,
    leckenby,
    yarrow,
    freeman1,
  };
}