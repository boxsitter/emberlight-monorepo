import 'dart:math';

import 'package:ember_core/ember_core_models.dart';

class PushRequest {
  bool _armed;
  int _disarmRequirementsLevel;
  Set<CoreObject> objectsToPush;
  String confirmationMessage;

  bool get armed => _armed;
  int get disarmRequirementsLevel => _disarmRequirementsLevel;

  void disarm() {
    if (disarmRequirementsLevel > 2) {
      _armed = false;
    } else {
      throw Exception('This operation cannot be completed.'); // TODO: make a better error system please
    }
  }

  // Constructor for initialization
  PushRequest({
    required int disarmRequirementsLevel,
    this.confirmationMessage = '',
    Set<CoreObject>? objectsToPush,
  })  : _armed = disarmRequirementsLevel > 0,
        _disarmRequirementsLevel = disarmRequirementsLevel,
        objectsToPush = objectsToPush ?? {};

  void add (PushRequest pushRequest, [bool? inheritNewMessage]) {
    _disarmRequirementsLevel = max(disarmRequirementsLevel, pushRequest.disarmRequirementsLevel);
    objectsToPush = {...objectsToPush, ...pushRequest.objectsToPush};
    if (inheritNewMessage != null && inheritNewMessage) {
      confirmationMessage = pushRequest.confirmationMessage;
    }
  }
}