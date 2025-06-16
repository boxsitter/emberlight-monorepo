import '../../ember_core_models.dart';

class HardcodedPrincipalCabins {
  static final PrincipalCabin henderson = PrincipalCabin(
    id: 'henderson-principal_cabin-brn-xiqhypN',
    name: 'Henderson',
    capacity: 12,
  );

  static final PrincipalCabin leckenby = PrincipalCabin(
    id: 'leckenby-principal_cabin-brn-1m40N8w',
    name: 'Leckenby',
    capacity: 12,
  );

  static final PrincipalCabin yarrow = PrincipalCabin(
    id: 'yarrow-principal_cabin-brn-uDItpQL',
    name: 'Yarrow',
    capacity: 12,
  );

  static final PrincipalCabin freeman1 = PrincipalCabin(
    id: 'freeman_1-principal_cabin-brn-eb5Kxyo',
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