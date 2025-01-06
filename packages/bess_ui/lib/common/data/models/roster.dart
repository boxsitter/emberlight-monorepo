import 'package:bessie/common/data/abstract/bess_object.dart';

import 'camper.dart';

class Roster extends BessObject {
  String title;
  final Map<String, Camper> campers;

  Roster({required this.title}) : campers = {}, super('Roster-$title-');

  int get length => campers.length;
  Iterable<Camper> get values => campers.values;

  @override
  String bessToString() {
    // Calculate maximum widths for each field
    int maxIdWidth = campers.values.map((c) => c.toStringSuper().length).reduce((a, b) => a > b ? a : b);
    int maxNameWidth = campers.values.map((c) => c.fullName.length).reduce((a, b) => a > b ? a : b);

    // Define column headers
    String idHeader = 'ID'.padRight(maxIdWidth + 3);
    String nameHeader = 'Name'.padRight(maxNameWidth + 3);
    String genderHeader = 'Gender'.padRight(10);
    String ageHeader = 'Age'.padRight(10);
    String cabinHeader = 'Cabin'.padRight(10);

    // Create the header row
    final headerRow = '$idHeader$nameHeader$genderHeader$ageHeader$cabinHeader';

    // Build camper strings with dynamic spacing
    final camperStrings = campers.values.map((camper) {
      String idField = camper.toStringSuper().padRight(maxIdWidth + 3);
      String nameField = camper.fullName.padRight(maxNameWidth + 3);
      String genderField = camper.gender.padRight(10);
      String ageField = '${camper.age}'.padRight(10);
      String cabinField = (camper.cabin?.name ?? "none").padRight(10);

      return '$idField$nameField$genderField$ageField$cabinField';
    }).join('\n');

    // Combine header, column headers, and camper rows
    return '$title\nRoster Size: ${campers.length}\nCampers:\n$headerRow\n$camperStrings';
  }

  @override
  Map<String, dynamic> toJson() {
    // TODO: implement toJson
    throw UnimplementedError();
  }

}