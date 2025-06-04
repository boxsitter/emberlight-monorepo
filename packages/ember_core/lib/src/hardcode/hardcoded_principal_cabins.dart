import '../../ember_core_models.dart';

class HardcodedPrincipalCabins {
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

  static final Set<PrincipalCabin> list = <PrincipalCabin>{
    henderson,
    leckenby,
    yarrow,
    freeman1,
  };
}