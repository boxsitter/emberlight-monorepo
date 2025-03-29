import 'dart:async';

import 'package:bessie/common/services/cabins_service.dart';
import 'package:bessie/common/services/client_context_service.dart';
import 'package:bessie/data/models/camper_preference.dart';
import 'package:bessie/data/models/schedule/schedule.dart';
import 'package:bessie/pages/console/controller/console_controller.dart';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';

import '../../data/models/camper.dart';
import '../../data/models/session.dart';
import '../../data/repositories/bess_object_repository.dart';

class SessionRosterService extends GetxService { //TODO: Consider refactoring all service operations as their own object subclassing an operation object that handles permissions and error logging
  BessObjectRepository bessObjectRepo = Get.find<BessObjectRepository>();
  CabinsService cabinsService = Get.find<CabinsService>();
  ClientContextService clientContextService = Get.find<ClientContextService>();
  ConsoleController consoleController = Get.find<ConsoleController>();

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
    String? cabinId;
    // need to fetch cabin by name from the active cabins for the selected session
    if (cabinName.isNotEmpty) {
      cabinId = await cabinsService.getCabinIdByName(cabinName);
      if (cabinId == null) {
        consoleController.error('Cabin $cabinName not found');
        return null;
      }
    }

    // TODO: Error checking here, validate stuff
    Camper camperToAdd = Camper(
      firstName: firstName,
      lastName: lastName,
      preferredName: preferredName,
      gender: gender,
      age: age,
      cabinId: cabinId,
      note: note,
    );

    await initCamperPreference(camperToAdd);

    // Add camper to master session roster
    bessObjectRepo.addIdToSet(clientContextService.sessionId, 'registeredCamperIds', camperToAdd.id);
    bessObjectRepo.pushObject(camperToAdd);
    if (camperToAdd.cabinId != null) {
      cabinsService.addCamperToCabin(cabinId!, camperToAdd.id);
    }
    consoleController.success('${camperToAdd.bessToString()}\n created!');
    return camperToAdd;
  }

  Future<void> initCamperPreference(Camper camper) async {
    CamperPreference camperPreference = CamperPreference(camperId: camper.id, camperName: camper.name);
    camper.camperPreferenceId = camperPreference.id;
    Schedule schedule = await clientContextService.schedule;
    for (ActivityTypeId uniqueActivityTypeId in schedule.uniqueActivityTypeIds) {
      camperPreference.preferences[uniqueActivityTypeId] = null;
      camperPreference.preferenceWeights[uniqueActivityTypeId] = 0;
    }
    Session session = await clientContextService.session;
    session.camperIdToPreferenceId[camper.id] = camperPreference.id;
    await bessObjectRepo.pushObject(session);
    await bessObjectRepo.pushObject(camperPreference);
  }

  Future<void> deleteCamper(String id) async{
    Camper camperToDelete = await bessObjectRepo.getObject(id, Camper.fromJson);
    if (camperToDelete.cabinId != null) {
      bessObjectRepo.purgeReferencesTo(camperToDelete.cabinId!, camperToDelete.id);
    }
    bessObjectRepo.purgeReferencesTo(clientContextService.sessionId, camperToDelete.id);
    if (camperToDelete.camperPreferenceId != null) {
      bessObjectRepo.deleteDocument(camperToDelete.camperPreferenceId!);
    }
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

  Future<void> importFromCsv() async {
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
            consoleController.error('CSV file is empty.');
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
            consoleController.error('CSV file must contain "First Name", "Last Name", and "Age" columns.');
            return;
          }

          // Iterate through data rows and create campers
          for (var row in rows.skip(1)) {
            // Skip the header row
            if (row.length < headers.length) {
              //ConsoleController()
               //   .error('Row has fewer columns than expected: $row');
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
              consoleController.error('Invalid data in row: $row');
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

          consoleController.log('CSV Import completed successfully.\n');
          consoleController.writePrompt();
        }
      }
    } catch (e) {
      consoleController.error('Error importing CSV: $e');
    }
  }
}
