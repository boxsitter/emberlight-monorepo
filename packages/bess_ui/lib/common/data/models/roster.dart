import 'package:bessie/common/data/abstract/bess_object.dart';

import 'camper.dart';

class Roster extends BessObject {
  String title;
  Map<String, Camper> campers;
  int size = 0;

  Roster({this.title = ''}) : campers = {}, super('Roster-$title-');

  @override
  String bessToString() {
    // Calculate maximum widths for each field
    int maxIdWidth = campers.values.map((c) => c.toStringSuper().length).reduce((a, b) => a > b ? a : b);
    int maxNameWidth = campers.values.map((c) => c.fullName.length).reduce((a, b) => a > b ? a : b);

    // Define column headers
    String idHeader = 'ID'.padRight(maxIdWidth + 2);
    String nameHeader = 'Name'.padRight(maxNameWidth + 2);
    String ageHeader = 'Age'.padRight(10);
    String cabinHeader = 'Cabin'.padRight(15);

    // Create the header row
    final headerRow = '$idHeader$nameHeader$ageHeader$cabinHeader';

    // Build camper strings with dynamic spacing
    final camperStrings = campers.values.map((camper) {
      String idField = camper.toStringSuper().padRight(maxIdWidth + 2);
      String nameField = camper.fullName.padRight(maxNameWidth + 2);
      String ageField = 'Age: ${camper.age}'.padRight(10);
      String cabinField = 'Cabin: ${camper.cabin?.name ?? "none"}'.padRight(15);

      return '$idField$nameField$ageField$cabinField';
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
    campers[camper.id] = camper;
    size++;
  }

  Camper? getCamperById(String id) {
    return campers[id];
  }

  void removeCamper(String id) {
    campers.remove(id);
    size--;
  }

}