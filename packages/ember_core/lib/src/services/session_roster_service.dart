import 'dart:async';
import 'dart:typed_data';

import 'package:csv/csv.dart';
import 'package:ember_core/ember_core_backend.dart';
import 'package:ember_core/ember_core_models.dart';
import 'package:ember_core/ember_core_services.dart';
import 'package:ember_core/ember_core_utils.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';

class SessionRosterService extends GetxService { //TODO: Consider refactoring all service operations as their own object subclassing an operation object that handles permissions and error logging
  static BackendInterface backend = BackendManager.instance;
  CabinService cabinsService = Get.find<CabinService>();
  ClientContextService clientContextService = Get.find<ClientContextService>();
  RequestService requestService = Get.find<RequestService>();

  Future<Set<Camper>> get registeredCampers async => await backend.getObjectsInCollection('camper', 'ses');

  Future<void> registerCamper({
    required PushRequest pushRequest,
    required String firstName,
    required String lastName,
    String preferredName = '',
    String gender = '',
    required int age,
    String cabinName = '',
    String note = '',
  }) async {
    String? cabinRef;
    // need to fetch cabin by name from the active cabins for the selected session
    if (cabinName.isNotEmpty) {
      cabinRef = await cabinsService.getCabinDependentIdByName(cabinName);
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

    initCamperPreference(pushRequest,camperToAdd);
    print('Camper: ${camperToAdd.fullName} added');
    pushRequest.addObject(camperToAdd);

    if (cabinRef != null) {
      await cabinsService.addCamperToCabin(pushRequest, cabinRef, camperToAdd);
    }
  }

  Future<void> initCamperPreference(PushRequest pushRequest, Camper camper) async {
    CamperPreference camperPreference = CamperPreference(camperRef: camper.id, camperName: camper.name);
    camper.camperPreferenceCmp = camperPreference.id;
    Schedule schedule = pushRequest.getObjectOfType() ?? await clientContextService.schedule;

    for (ActivityTypeId uniqueActivityTypeRef in schedule.uniqueActivityTypeRefs) {
      camperPreference.preferencesRefs[uniqueActivityTypeRef] = null;
      camperPreference.preferenceWeightRefs[uniqueActivityTypeRef] = 0;
    }
    Session session = pushRequest.getObjectOfType() ?? await clientContextService.session;

    session.camperRefToPreferenceRef[camper.id] = camperPreference.id;
    pushRequest.addObject(schedule);
    pushRequest.addObject(session);
    pushRequest.addObject(camperPreference);
  }

  // Future<void> deleteCamper(String id) async{
  //   Camper camperToDelete = await coreObjectRepo.getObject(id, Camper.fromJson);
  //   if (camperToDelete.cabinId != null) {
  //     coreObjectRepo._purgeReferencesTo(camperToDelete.cabinId!, camperToDelete.id);
  //   }
  //   coreObjectRepo._purgeReferencesTo(clientContextService.sessionId, camperToDelete.id);
  //   if (camperToDelete.camperPreferenceId != null) {
  //     coreObjectRepo.deleteDocument(camperToDelete.camperPreferenceId!);
  //   }
  //   coreObjectRepo.deleteDocument(id);
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

  Future<void> importFromCsv({
    required PushRequest pushRequest,
    required String firstNameHeader,
    required String lastNameHeader,
    required String ageHeader,
    String? preferredNameHeader,
    String? genderHeader,
    String? cabinHeader,
  }) async {
    try {
      // 1. Pick and Read File Content
      final csvContent = await _pickAndReadCsv();

      // 2. Parse CSV
      final List<List<dynamic>> rows = const CsvToListConverter().convert(csvContent, eol: '\n');
      if (rows.isEmpty) {
        throw ArgumentError('CSV file is empty.');
      }

      // 3. Process Headers
      final headers = rows.first.map((h) => h.toString().toLowerCase().trim()).toList();
      final indices = _parseHeaderIndices(
        headers: headers,
        firstNameHeader: firstNameHeader,
        lastNameHeader: lastNameHeader,
        ageHeader: ageHeader,
        preferredNameHeader: preferredNameHeader,
        genderHeader: genderHeader,
        cabinHeader: cabinHeader,
      );

      // 4. Prepare for Processing
      final Set<Camper> alreadyRegistered = await registeredCampers;

      // 5. Process Each Data Row
      for (final row in rows.skip(1)) {
        if (row.length < headers.length) {
          print('Skipping malformed row (wrong column count): $row');
          continue;
        }

        // Extract and validate row data
        final camperData = _extractCamperDataFromRow(row, indices);
        if (camperData == null) {
          print('Skipping invalid row data: $row');
          continue; // Skip if basic validation failed (e.g., empty name, invalid age)
        }

        // Check for duplicates against already registered AND newly added ones
        final Set<Camper> potentialDuplicates = {
          ...alreadyRegistered,
          ...pushRequest.getObjectsOfType(),
        };
        final bool isDuplicate = await isCamperDuplicate(
          camperData['firstName'],
          camperData['lastName'],
          camperData['age'],
          potentialDuplicates,
        );

        if (isDuplicate) {
          print('Skipping duplicate camper: ${camperData['firstName']} ${camperData['lastName']}');
          continue;
        }

        // 6. Create Camper PushRequest and Update State
        try {
          await registerCamper(
            pushRequest: pushRequest,
            firstName: camperData['firstName'],
            lastName: camperData['lastName'],
            preferredName: camperData['preferredName'],
            gender: camperData['gender'],
            age: camperData['age'],
            cabinName: camperData['cabinName'],
          );

        } catch(e) {
          print('Error registering camper for row: $row. Error: $e');
          continue;
        }
      }
    } catch (e) {
      // Catch specific errors like FileSystemException, ArgumentError, StateError if needed
      print('Error during CSV import process: $e'); // Log the error
      // Rethrow or handle as appropriate for UI feedback
      throw StateError('Error importing CSV: $e');
    }
  }

  Future<String> _pickAndReadCsv() async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );
    if (result == null) {
      throw StateError('No CSV file selected.');
    }
    final Uint8List? bytes = result.files.first.bytes;
    if (bytes == null) {
      throw StateError('Unable to read CSV data.');
    }
    // Consider adding checks for file size or basic content validation here
    return String.fromCharCodes(bytes);
  }

  Map<String, int> _parseHeaderIndices({
    required List<String> headers,
    required String firstNameHeader,
    required String lastNameHeader,
    required String ageHeader,
    String? preferredNameHeader,
    String? genderHeader,
    String? cabinHeader,
  }) {
    return {
      'firstName': _findColumnIndex(headers, firstNameHeader, isRequired: true),
      'lastName': _findColumnIndex(headers, lastNameHeader, isRequired: true),
      'age': _findColumnIndex(headers, ageHeader, isRequired: true),
      'preferredName': preferredNameHeader == null ? -1 : _findColumnIndex(headers, preferredNameHeader, isRequired: false),
      'gender': genderHeader == null ? -1 : _findColumnIndex(headers, genderHeader, isRequired: false),
      'cabin': cabinHeader == null ? -1 : _findColumnIndex(headers, cabinHeader, isRequired: false),
    };
  }

  Map<String, dynamic>? _extractCamperDataFromRow(List<dynamic> row, Map<String, int> indices) {
    final String firstName = _getCellValue(row, indices['firstName']!);
    final String lastName = _getCellValue(row, indices['lastName']!);
    final String ageString = _getCellValue(row, indices['age']!);
    final int age = int.tryParse(ageString) ?? 0;

    // Basic validation
    if (firstName.isEmpty || lastName.isEmpty || age <= 0) {
      return null; // Indicate invalid data
    }

    return {
      'firstName': firstName,
      'lastName': lastName,
      'age': age,
      'preferredName': _getCellValue(row, indices['preferredName']!),
      'gender': _getCellValue(row, indices['gender']!),
      'cabinName': _getCellValue(row, indices['cabin']!),
    };
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
