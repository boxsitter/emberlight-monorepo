import 'package:bessie/common/data/abstract/bess_object.dart';
import 'package:bessie/features/console/controller/console_controller.dart';

import 'camper.dart';

class Roster extends BessObject {
  String title;
  final Map<String, Camper> _campers;
  int size = 0;

  Roster({required this.title}) : _campers = {}, super('Roster-$title-');

  @override
  String bessToString() {
    // Calculate maximum widths for each field
    int maxIdWidth = _campers.values.map((c) => c.toStringSuper().length).reduce((a, b) => a > b ? a : b);
    int maxNameWidth = _campers.values.map((c) => c.fullName.length).reduce((a, b) => a > b ? a : b);

    // Define column headers
    String idHeader = 'ID'.padRight(maxIdWidth + 3);
    String nameHeader = 'Name'.padRight(maxNameWidth + 3);
    String genderHeader = 'Gender'.padRight(10);
    String ageHeader = 'Age'.padRight(10);
    String cabinHeader = 'Cabin'.padRight(10);

    // Create the header row
    final headerRow = '$idHeader$nameHeader$genderHeader$ageHeader$cabinHeader';

    // Build camper strings with dynamic spacing
    final camperStrings = _campers.values.map((camper) {
      String idField = camper.toStringSuper().padRight(maxIdWidth + 3);
      String nameField = camper.fullName.padRight(maxNameWidth + 3);
      String genderField = camper.gender.padRight(10);
      String ageField = '${camper.age}'.padRight(10);
      String cabinField = (camper.cabin?.name ?? "none").padRight(10);

      return '$idField$nameField$genderField$ageField$cabinField';
    }).join('\n');

    // Combine header, column headers, and camper rows
    return 'Roster Size: $size\nCampers:\n$headerRow\n$camperStrings';
  }


  @override
  Map<String, dynamic> toJson() {
    // TODO: implement toJson
    throw UnimplementedError();
  }

  void addCamper(Camper camper) {
    // TODO: Error handling for duplicate keys
    _campers[camper.id] = camper;
    size++;
  }

  void removeCamper(Camper camper) {
    if (_campers.containsKey(camper.id)) {
      _campers.remove(camper.id);
    } else {
      ConsoleController().error('Camper can\'t be removed from roster: $title because they are not on the roster');
    }

  }

  Camper? getCamperById(String id) {
    return _campers[id];
  }

  void removeCamperById(String id) {
    _campers.remove(id);
    size--;
  }

  bool containsCamper(Camper camper) {
      return _campers.containsKey(camper.id);
  }

}