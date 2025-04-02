import 'package:ember_core/ember_core_models.dart';

class PushRequest {
  bool _armed;
  final int disarmRequirementsLevel;
  Set<BessObject> objectsToPush;
  String confirmationMessage;

  bool get armed => _armed;

  void disarm() {
    if (disarmRequirementsLevel > 2) {
      _armed = false;
    } else {
      throw Exception('This operation cannot be completed.'); // TODO: make a better error system please
    }
  }

  // Constructor for initialization
  PushRequest({
    required this.disarmRequirementsLevel,
    this.confirmationMessage = '',
    Set<BessObject>? objectsToPush,
  })  : _armed = disarmRequirementsLevel > 0,
        objectsToPush = objectsToPush ?? {};
}