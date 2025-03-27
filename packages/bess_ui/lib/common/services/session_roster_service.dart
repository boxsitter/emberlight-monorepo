import 'dart:async';
import 'dart:io';

import 'package:bessie/common/services/cabins_service.dart';
import 'package:bessie/common/services/client_context_service.dart';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';

import '../../data/models/cabin.dart';
import '../../data/models/camper.dart';
import '../../data/models/session.dart';
import '../../data/repositories/bess_object_repository.dart';
import '../../pages/console/controller/console_controller.dart';

class SessionRosterService extends GetxService {
  BessObjectRepository bessObjectRepo = Get.find<BessObjectRepository>();
  CabinsService cabinsService = Get.find<CabinsService>();
  ClientContextService clientContextService = Get.find<ClientContextService>();

  Future<Set<String>> get sessionRoster async => await bessObjectRepo.getSetField(clientContextService.sessionId, 'registeredCamperIds');
  Future<Set<Camper>> get registeredCampers async => await bessObjectRepo.getObjects(await sessionRoster, Camper.fromJson);

  Future<Camper?> registerCamper({
    String firstName = '',
    String lastName = '',
    String preferredName = '',
    String gender = '',
    int age = 0,
    String cabinName = '',
    String note = '',
  }) async {
    // need to fetch cabin by name from the active cabins for the selected session
    Cabin? cabin;
    if (cabinName.isNotEmpty) {
      String? cabinId = await cabinsService.getCabinIdByName(cabinName);
      if (cabinId == null) {
        ConsoleController().error('Cabin $cabinName not found');
        return null;
      }
      cabin = await bessObjectRepo.getObject(cabinId, Cabin.fromJson);
    }
    if (cabin == null) {
      ConsoleController().error('Cabin $cabinName not found');
      return null;
    }

    // TODO: Error checking here, validate stuff
    Camper camperToAdd = Camper(
      firstName: firstName,
      lastName: lastName,
      preferredName: preferredName,
      gender: gender,
      age: age,
      note: note,
    );

    // // initializes the camper preference objects for new campers added when a schedule already contains assignable activities
    // if(localData.session!.schedule.blocks.isNotEmpty) {
    //   for (ScheduleBlock block in localData.session!.schedule.blocks.values) {
    //     if (block is AssignableActivityBlock) {
    //       AssignableActivityBlock assignableActivityBlock = block;
    //       camperToAdd.activityPreferences[block] = CamperPreference(camper: camperToAdd, block: block);
    //       for (Activity activity in assignableActivityBlock.activities.values) {
    //         camperToAdd.activityPreferences[assignableActivityBlock]!.preferences[activity] = null;
    //       }
    //     }
    //   }
    // }

    // Add camper to master session roster
    bessObjectRepo.addIdToSet(clientContextService.sessionId, 'registeredCamperIds', camperToAdd.id);
    bessObjectRepo.pushObject(camperToAdd);
    cabinsService.addCamperToCabin(cabin.id, camperToAdd.id);
    ConsoleController().log('${camperToAdd.bessToString()}\n created!');
    return camperToAdd;
  }

  Future<void> deleteCamper(String id) async{
    Camper camperToDelete = await bessObjectRepo.getObject(id, Camper.fromJson);
    if (camperToDelete.cabinId != null) {
      bessObjectRepo.purgeReferencesTo(camperToDelete.cabinId!, camperToDelete.id);
    }
    bessObjectRepo.purgeReferencesTo(clientContextService.sessionId, camperToDelete.id);
    bessObjectRepo.deleteDocument(id);
    // TODO: Remove them from all activity rosters!
  }

  Future<void> deleteAllCampersInSession() async {
    // TODO: THERE NEEDS TO BE A BIG FAT WARNING FOR THIS
    for (String id in await sessionRoster) {
      deleteCamper(id);
    }
  }

  Future<bool> isCamperDuplicate(String firstName, String lastName, int age, Set<Camper> registeredCampers) async {
    for (Camper camper in registeredCampers) {
      if (camper.firstName == firstName && camper.lastName == lastName && camper.age == age) {
        return true;
      }
    }
    return false;
  }

  void importFromCsv() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result != null) {
        // For web, you'll get bytes, so convert them to a string.
        final bytes = result.files.first.bytes;
        if (bytes != null) {
          final csvContent = String.fromCharCodes(bytes);

          Set<Camper> registeredCampers = await this.registeredCampers;

          // Read the CSV file
          final rows = const CsvToListConverter().convert(csvContent, eol: '\n');

          if (rows.isEmpty) {
            ConsoleController().error('CSV file is empty.');
            return;
          }

          // Parse header row to determine column indices
          // TODO: Check this against ultracamp exported CSVs
          final headers = rows.first
              .map((header) => header.toString().toLowerCase().trim())
              .toList();
          final firstNameIndex = headers.indexOf('first name');
          final lastNameIndex = headers.indexOf('last name');
          final preferredNameIndex = headers.indexOf('preferred name');
          final genderIndex = headers.indexOf('gender');
          final ageIndex = headers.indexOf('age');
          final cabinIndex = headers.indexOf('cabin');

          // Validate required columns
          if (firstNameIndex == -1 || lastNameIndex == -1 || ageIndex == -1) {
            ConsoleController().error(
                'CSV file must contain "First Name", "Last Name", and "Age" columns.');
            return;
          }

          // Iterate through data rows and create campers
          for (var row in rows.skip(1)) {
            // Skip the header row
            if (row.length < headers.length) {
              ConsoleController()
                  .error('Row has fewer columns than expected: $row');
              continue;
            }

            final firstName = row.length > firstNameIndex
                ? row[firstNameIndex]?.toString() ?? ''
                : '';
            final lastName = row.length > lastNameIndex
                ? row[lastNameIndex]?.toString() ?? ''
                : '';
            final preferredName = row.length > preferredNameIndex
                ? row[preferredNameIndex]?.toString() ?? ''
                : '';
            final gender =
            row.length > genderIndex ? row[genderIndex]?.toString() ?? '' : '';
            final age = row.length > ageIndex
                ? int.tryParse(row[ageIndex]?.toString() ?? '') ?? 0
                : 0;
            final cabinName = row.length > cabinIndex
                ? row[cabinIndex]?.toString().trim() ?? ''
                : '';

            if (firstName.isEmpty || lastName.isEmpty || age <= 0) {
              ConsoleController().error('Invalid data in row: $row');
              continue;
            }

            if (await isCamperDuplicate(firstName, lastName, age, registeredCampers)) {
              // TODO: add some kind of confirmation to a allow the user to import duplicates
              print('Skipping duplicate camper: $firstName');
              continue;
            }

            Camper? camper = await registerCamper(
              firstName: firstName,
              lastName: lastName,
              preferredName: preferredName,
              gender: gender,
              age: age,
              cabinName: cabinName,
            );
            registeredCampers.add(camper!); // TODO: Fix null check
          }

          ConsoleController().log('CSV Import completed successfully.\n');
          ConsoleController().writePrompt();
        }
      }
    } catch (e) {
      ConsoleController().error('Error importing CSV: $e');
    }
  }
}
