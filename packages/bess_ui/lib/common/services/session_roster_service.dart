import 'dart:async';
import 'dart:typed_data';

import 'package:bessie/common/services/cabin_service.dart';
import 'package:bessie/common/services/client_context_service.dart';
import 'package:bessie/common/services/request_service.dart';
import 'package:bessie/common/utils/helpers/bess_id_functions.dart';
import 'package:bessie/data/bess_objects/camper_preference.dart';
import 'package:bessie/data/bess_objects/schedule/schedule.dart';
import 'package:bessie/data/helper_objects/push_request.dart';
import 'package:bessie/pages/console/controller/console_controller.dart';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';

import '../../data/bess_objects/camper.dart';
import '../../data/bess_objects/domains/session.dart';
import '../../data/repositories/pull_repository.dart';

class SessionRosterService extends GetxService { //TODO: Consider refactoring all service operations as their own object subclassing an operation object that handles permissions and error logging
  PullRepository pullRepo = Get.find<PullRepository>();
  CabinService cabinsService = Get.find<CabinService>();
  ClientContextService clientContextService = Get.find<ClientContextService>();
  ConsoleController consoleController = Get.find<ConsoleController>();
  RequestService requestService = Get.find<RequestService>();

  Future<Set<Camper>> get registeredCampers async => await pullRepo.getObjectsInCollection('camper', 'ses', Camper.fromJson);

  Future<PushRequest> registerCamper({
    String firstName = '',
    String lastName = '',
    String preferredName = '',
    String gender = '',
    int age = 0,
    String cabinName = '',
    String note = '',
  }) async {
    String? cabinRef;
    // need to fetch cabin by name from the active cabins for the selected session
    if (cabinName.isNotEmpty) {
      cabinRef = await cabinsService.getCabinRefByName(cabinName);
    }

    // TODO: Error checking here, validate stuff
    Camper camperToAdd = Camper(
      firstName: firstName,
      lastName: lastName,
      preferredName: preferredName,
      gender: gender,
      age: age,
      cabinRef: cabinRef,
      note: note,
    );

    PushRequest pushRequest = PushRequest(disarmRequirementsLevel: 0);

    pushRequest = requestService.mergeRequests(pushRequest, await initCamperPreference(camperToAdd), 1);


    pushRequest.objectsToPush.add(camperToAdd);
    // TODO: merge the push request of add camper to cabin
    // if (camperToAdd.cabinId != null) {
    //   cabinsService.addCamperToCabin(cabinId!, camperToAdd.id);
    // }
    consoleController.success('${camperToAdd.bessToString()}\n created!');
    return pushRequest;
  }

  Future<PushRequest> initCamperPreference(Camper camper) async {
    CamperPreference camperPreference = CamperPreference(camperRef: camper.objId, camperName: camper.name);
    camper.camperPreferenceCmp = BessIdFunctions.objIdToCmp(camperPreference.objId);
    Schedule schedule = await clientContextService.schedule;
    for (ActivityTypeRef uniqueActivityTypeRef in schedule.uniqueActivityTypeRefs) {
      camperPreference.preferencesRefs[uniqueActivityTypeRef] = null;
      camperPreference.preferenceWeightRefs[uniqueActivityTypeRef] = 0;
    }
    Session session = await clientContextService.session;
    session.camperRefToPreferenceRef[camper.objId] = camperPreference.objId;
    PushRequest pushRequest = PushRequest(disarmRequirementsLevel: 0);
    pushRequest.objectsToPush.add(session);
    pushRequest.objectsToPush.add(camperPreference);
    return pushRequest;
  }

  // Future<void> deleteCamper(String id) async{
  //   Camper camperToDelete = await bessObjectRepo.getObject(id, Camper.fromJson);
  //   if (camperToDelete.cabinId != null) {
  //     bessObjectRepo._purgeReferencesTo(camperToDelete.cabinId!, camperToDelete.id);
  //   }
  //   bessObjectRepo._purgeReferencesTo(clientContextService.sessionId, camperToDelete.id);
  //   if (camperToDelete.camperPreferenceId != null) {
  //     bessObjectRepo.deleteDocument(camperToDelete.camperPreferenceId!);
  //   }
  //   bessObjectRepo.deleteDocument(id);
  //   // TODO: Remove them from all activity rosters!
  // }

  // Future<void> deleteAllCampersInSession() async {
  //   // TODO: THERE NEEDS TO BE A BIG FAT WARNING FOR THIS
  //   for (String id in await sessionRoster) {
  //     deleteCamper(id);
  //   }
  // }

  Future<bool> isCamperDuplicate(String firstName, String lastName, int age, Set<Camper> checkAgainst) async {
    for (Camper camper in checkAgainst) {
      if (camper.firstName == firstName && camper.lastName == lastName && camper.age == age) {
        return true;
      }
    }
    return false;
  }

  Future<PushRequest> importFromCsv({
    required String firstNameHeader,
    required String lastNameHeader,
    required String ageHeader,
    String? preferredNameHeader,
    String? genderHeader,
    String? cabinHeader,
  }) async {
    try {
      // 1. Pick the file
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );
      if (result == null) {
        throw StateError('No CSV file selected.');
      }

      // 2. Convert file contents to a String
      final Uint8List? bytes = result.files.first.bytes;
      if (bytes == null) {
        throw StateError('Unable to read CSV data (no bytes found).');
      }
      final csvContent = String.fromCharCodes(bytes);

      // 3. Convert CSV String to a list of rows
      final List<List<dynamic>> rows =
      const CsvToListConverter().convert(csvContent, eol: '\n');
      if (rows.isEmpty) {
        throw ArgumentError('CSV file is empty.');
      }

      // 4. Extract & validate columns from the header row
      final List<String> headers = rows.first
          .map((header) => header.toString().toLowerCase().trim())
          .toList();

      // Locate each column index (throw if required column is missing)
      final int firstNameIndex = _findColumnIndex(
        headers,
        firstNameHeader,
        isRequired: true,
      );
      final int lastNameIndex = _findColumnIndex(
        headers,
        lastNameHeader,
        isRequired: true,
      );
      final int ageIndex = _findColumnIndex(
        headers,
        ageHeader,
        isRequired: true,
      );

      // For optional columns, we allow -1 if not found
      final int preferredIndex = preferredNameHeader == null
          ? -1
          : _findColumnIndex(headers, preferredNameHeader, isRequired: false);
      final int genderIndex = genderHeader == null
          ? -1
          : _findColumnIndex(headers, genderHeader, isRequired: false);
      final int cabinIndex = cabinHeader == null
          ? -1
          : _findColumnIndex(headers, cabinHeader, isRequired: false);

      // 5. Prepare data sets and a PushRequest for bulk creation
      final Set<Camper> alreadyRegistered = await registeredCampers;
      PushRequest combinedRequest = PushRequest(disarmRequirementsLevel: 1, confirmationMessage: 'Are you sure you want to import however many campers you are importing?');

      // 6. Process each row (skip the header)
      for (final row in rows.skip(1)) {
        // If a row doesn’t match the header length, skip it (malformed data)
        if (row.length < headers.length) {
          // consoleController.error('Row has fewer columns than expected: $row');
          continue;
        }

        // Extract fields safely
        final String firstName = _getCellValue(row, firstNameIndex);
        final String lastName = _getCellValue(row, lastNameIndex);
        final String preferredName = _getCellValue(row, preferredIndex);
        final String gender = _getCellValue(row, genderIndex);
        final int age = int.tryParse(_getCellValue(row, ageIndex)) ?? 0;
        final String cabinName = _getCellValue(row, cabinIndex);

        // Basic validation
        if (firstName.isEmpty || lastName.isEmpty || age <= 0) {
          consoleController.error('Invalid data in row: $row');
          continue;
        }

        // Prevent duplicates
        final totalKnownCampers = <Camper>{
          ...combinedRequest.objectsToPush as Set<Camper>,
          ...alreadyRegistered,
        };
        final bool isDuplicate =
        await isCamperDuplicate(firstName, lastName, age, totalKnownCampers);
        if (isDuplicate) {
          // Optionally log the skipped duplicates
          print('Skipping duplicate camper: $firstName $lastName ($age y/o)');
          continue;
        }

        // 7. Create camper & merge into combined request
        final PushRequest newCamperRequest = await registerCamper(
          firstName: firstName,
          lastName: lastName,
          preferredName: preferredName,
          gender: gender,
          age: age,
          cabinName: cabinName,
        );
        combinedRequest =
            requestService.mergeRequests(newCamperRequest, combinedRequest, 2);
      }

      return combinedRequest;
    } catch (e) {
      throw StateError('Error importing CSV: $e');
    }
  }

  /// Returns the index of [columnName] within [headers]. Throws an error if
  /// it’s a required column but not found. Returns -1 if optional and not found.
  int _findColumnIndex(
      List<String> headers,
      String columnName, {
        required bool isRequired,
      }) {
    final int index = headers.indexOf(columnName.toLowerCase().trim());
    if (index == -1 && isRequired) {
      throw ArgumentError('CSV must contain a "$columnName" column.');
    }
    return index;
  }

  /// Simple helper to safely extract the value from [row] at [index] as a String.
  /// Returns an empty string if [index] is -1 or out of range.
  String _getCellValue(List<dynamic> row, int index) {
    if (index < 0 || index >= row.length) return '';
    return row[index]?.toString().trim() ?? '';
  }
}
