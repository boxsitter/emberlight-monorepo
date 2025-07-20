import 'package:ember_core/ember_core.dart';

class PreferenceChoice {
  final CamperId camperId;
  Map<PrincipalActivityId, double?> preferences;

  PreferenceChoice(this.camperId, this.preferences);
}