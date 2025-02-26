import 'dart:io';

import 'package:bessie/data/abstract/schedule_block.dart';
import 'package:bessie/data/models/camper_preference.dart';
import 'package:bessie/data/models/schedule/activity.dart';
import 'package:bessie/data/models/schedule/assignable_activity_block.dart';
import 'package:csv/csv.dart';
import 'package:get/get.dart';

import '../../data/models/cabin.dart';
import '../../data/models/camper.dart';
import '../../data/models/local_data.dart';
import '../../data/models/roster.dart';
import '../feature_utils/session_roster_utils.dart';
import '../feature_utils/session_utils.dart';
import '../../pages/console/controller/console_controller.dart';

class SessionRosterService extends GetxService {
  final LocalData localData = Get.find<LocalData>();

  Roster get roster => localData.session!.sessionRoster;

  void createCamper({
    String firstName = '',
    String lastName = '',
    String preferredName = '',
    String gender = '',
    int age = 0,
    String cabinName = '',
  }) {
    // need to fetch cabin by name from the active cabins for the selected session
    Cabin? cabin;
    if (cabinName.isNotEmpty) {
      cabin = SessionUtils.getCabinByNameFromSession(localData.session!, cabinName);
    } 
    if (cabin == null) {
      ConsoleController().error('Cabin $cabinName not found');
      return;
    }
    // TODO: Error checking here, validate stuff
    Camper camperToAdd = Camper(
      dataParent: roster,
      firstName: firstName,
      lastName: lastName,
      preferredName: preferredName,
      gender: gender,
      age: age,
    );
    roster.campers[camperToAdd.id] = camperToAdd;
    roster.updateTimestamp();
    SessionRosterUtils.addCamperToCabin(cabin, camperToAdd);

    // initializes the camper preference objects for new campers added when a schedule already contains assignable activities
    if(localData.session!.schedule.blocks.isNotEmpty) {
      for (ScheduleBlock block in localData.session!.schedule.blocks.values) {
        if (block is AssignableActivityBlock) {
          AssignableActivityBlock assignableActivityBlock = block;
          camperToAdd.activityPreferences[block] = CamperPreference(dataParent: camperToAdd, camper: camperToAdd, block: block);
          camperToAdd.updateTimestamp();
          for (Activity activity in assignableActivityBlock.activities.values) {
            camperToAdd.activityPreferences[assignableActivityBlock]!.preferences[activity] = null;
            camperToAdd.activityPreferences[assignableActivityBlock]!.updateTimestamp();
          }
        }
      }
    }

    ConsoleController().log('${camperToAdd.bessToString()}\n created and added to session: ${localData.session!.name}');
  }

  void importFromCsv(File csvFile) async {
    try {
      // Read the CSV file
      final csvContent = await csvFile.readAsString();
      final rows = const CsvToListConverter().convert(csvContent, eol: '\n');

      if (rows.isEmpty) {
        ConsoleController().error('CSV file is empty.');
        return;
      }

      // Parse header row to determine column indices
      // TODO: Check this against ultracamp exported CSVs
      final headers = rows.first.map((header) => header.toString().toLowerCase().trim()).toList();
      final firstNameIndex = headers.indexOf('first name');
      final lastNameIndex = headers.indexOf('last name');
      final preferredNameIndex = headers.indexOf('preferred name');
      final genderIndex = headers.indexOf('gender');
      final ageIndex = headers.indexOf('age');
      final cabinIndex = headers.indexOf('cabin');

      // Validate required columns
      if (firstNameIndex == -1 || lastNameIndex == -1 || ageIndex == -1) {
        ConsoleController().error('CSV file must contain "First Name", "Last Name", and "Age" columns.');
        return;
      }

      // Iterate through data rows and create campers
      for (var row in rows.skip(1)) { // Skip the header row
        if (row.length < headers.length) {
          ConsoleController().error('Row has fewer columns than expected: $row');
          continue;
        }

        final firstName = row.length > firstNameIndex ? row[firstNameIndex]?.toString() ?? '' : '';
        final lastName = row.length > lastNameIndex ? row[lastNameIndex]?.toString() ?? '' : '';
        final preferredName = row.length > preferredNameIndex ? row[preferredNameIndex]?.toString() ?? '' : '';
        final gender = row.length > genderIndex ? row[genderIndex]?.toString() ?? '' : '';
        final age = row.length > ageIndex ? int.tryParse(row[ageIndex]?.toString() ?? '') ?? 0 : 0;
        final cabinName = row.length > cabinIndex ? row[cabinIndex]?.toString().trim() ?? '' : '';

        if (firstName.isEmpty || lastName.isEmpty || age <= 0) {
          ConsoleController().error('Invalid data in row: $row');
          continue;
        }

        createCamper(
          firstName: firstName,
          lastName: lastName,
          preferredName: preferredName,
          gender: gender,
          age: age,
          cabinName: cabinName,
        );
      }

      ConsoleController().log('CSV Import completed successfully.\n');
      ConsoleController().writePrompt();

    } catch (e) {
      ConsoleController().error('Error importing CSV: $e');
    }
  }
}