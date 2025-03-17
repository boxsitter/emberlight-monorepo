import 'package:bessie/data/abstract/bess_object.dart';
import 'package:get/get.dart';

import '../../common/services/session_roster_service.dart';
import 'camper.dart';

class Roster extends BessObject {
  String title;
  final Map<String, Camper> campers;

  Roster({
    required this.title,
    super.id,
    super.createdAt,
    super.updatedAt,
  }) : campers = {}, super(
    idTitle: 'Roster-$title-',
  );

  int get length => campers.length;
  Iterable<Camper> get values => campers.values;

  @override
  String bessToString() {
    if (campers.isEmpty) {
      return '$title\nRoster Size: ${campers.length}';
    }

    // Calculate maximum widths for each field
    int maxIdWidth = campers.values.map((c) => c.toStringSuper().length).reduce((a, b) => a > b ? a : b);
    int maxNameWidth = campers.values.map((c) => c.fullName.length).reduce((a, b) => a > b ? a : b);

    // Define column headers
    String idHeader = 'ID'.padRight(maxIdWidth + 3);
    String nameHeader = 'Name'.padRight(maxNameWidth + 3);
    String genderHeader = 'Gender'.padRight(10);
    String ageHeader = 'Age'.padRight(10);
    String cabinHeader = 'CabinId'.padRight(10);

    // Create the header row
    final headerRow = '$idHeader$nameHeader$genderHeader$ageHeader$cabinHeader';

    // Build camper strings with dynamic spacing
    final camperStrings = campers.values.map((camper) {
      String idField = camper.toStringSuper().padRight(maxIdWidth + 3);
      String nameField = camper.fullName.padRight(maxNameWidth + 3);
      String genderField = camper.gender.padRight(10);
      String ageField = '${camper.age}'.padRight(10);
      String cabinField = (camper.cabinId ?? "none").padRight(10);

      return '$idField$nameField$genderField$ageField$cabinField';
    }).join('\n');

    // Combine header, column headers, and camper rows
    return '$title\nRoster Size: ${campers.length}\nCampers:\n$headerRow\n$camperStrings';
  }

  @override
  Map<String, dynamic> toJson() {
    final json = toJsonSuper();
    json.addAll({
      'title': title,
      'campers': campers.keys.toList(),
    });
    return json;
  }

  factory Roster.fromJson(Map<String, dynamic> json, [bool clone = false]) {
    final roster = Roster(
      title: json['title'] ?? '',
    );

    // Let BessObject handle id, createdAt, and updatedAt.
    roster.overwriteBessObjectFromJson(json, clone);

    // Deserialize referenced campers using SessionRosterService.
    final List<dynamic> camperIds = json['campers'] as List<dynamic>? ?? [];
    final sessionRosterService = Get.find<SessionRosterService>();

    for (var camperId in camperIds) {
      // Fetch the camper from the master roster.
      final Camper camper = sessionRosterService.fetchCamperById(camperId as String);
      roster.campers[camper.id] = camper;
    }

    return roster;
  }

}