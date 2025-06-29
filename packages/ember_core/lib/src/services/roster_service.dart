import 'dart:async';
import 'dart:typed_data';

import 'package:csv/csv.dart';
import 'package:ember_core/src/repositories/live_data_repository.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../ember_core.dart';
import '../debug/service_exceptions.dart';
import '../repositories/pull_repository.dart';

class RosterService extends GetxService {
  PullRepository pullRepo = Get.find<PullRepository>();
  LiveDataRepository liveDataRepo = Get.find<LiveDataRepository>();
  CabinService cabinsService = Get.find<CabinService>();
  ContextService clientContextService = Get.find<ContextService>();
  CommitService requestService = Get.find<CommitService>();

  Future<Set<Camper>> get registeredCampers async =>
      (await pullRepo.getObjectsInCollection<Camper>('camper', 'ses')).values.toSet();
  Future<Stream<Map<String, Camper>>> get camperStream async =>
      await liveDataRepo.watchCollection(collectionName: 'camper', domain: 'ses');

  Future<void> registerCamper({
    required Commit commit,
    required String firstName,
    required String lastName,
    String preferredName = '',
    String gender = '',
    required DateTime birthdate,
    String cabinName = '',
    String note = '',
    String? ultracampId,
  }) async {
    String? cabinRef;
    // need to fetch cabin by name from the active cabins for the selected session
    if (cabinName.isNotEmpty) {
      cabinRef = await cabinsService.getCabinDependentIdByName(cabinName, commit);
    }

    // TODO: Error checking here, validate stuff
    Camper camperToAdd = Camper(
      firstName: firstName,
      lastName: lastName,
      preferredName: preferredName,
      gender: gender,
      birthdate: birthdate,
      note: note,
      ultracampId: ultracampId,
    );

    initCamperPreference(commit, camperToAdd);
    Debug.logInfo('Camper: ${camperToAdd.fullName} added');
    commit.addObjectToPush(camperToAdd);

    try {
      if (cabinRef != null) {
        CabinDependent cabinDependent = commit.getObject(cabinRef) ?? await pullRepo.getObject(cabinRef);
        await cabinsService.addCamperToCabin(commit, cabinDependent, camperToAdd);
      }
    } on Exception catch (e) {
      throw CamperRegistrationError(
        'Error registering camper: $e',
        'Something went wrong trying to register camper: $firstName, to cabin $cabinName. Make sure $cabinName is active for this session.',
      );
    }
  }

  Future<void> initCamperPreference(Commit commit, Camper camper) async {
    Schedule schedule = commit.getObjectOfType() ?? await clientContextService.schedule;

    for (PrincipalActivityId uniqueActivityTypeRef in schedule.principalActivityRefs) {
      camper.preferenceRefs[uniqueActivityTypeRef] = null;
      camper.preferenceWeightRefs[uniqueActivityTypeRef] = 0;
    }
    Session session = commit.getObjectOfType() ?? await clientContextService.session;

    commit.addObjectsToPush({schedule, session});
  }

  Future<bool> isCamperDuplicate(String firstName, String lastName, Set<Camper> checkAgainst) async {
    for (Camper camper in checkAgainst) {
      if (camper.firstName.toLowerCase() == firstName.toLowerCase() && camper.lastName.toLowerCase() == lastName.toLowerCase()) {
        return true;
      }
    }
    return false;
  }

  Future<Commit> importFromCsv() async {
    final List<RosterField> expectedColumns = [
      RosterField.firstName,
      RosterField.preferredName,
      RosterField.lastName,
      RosterField.gender,
      RosterField.birthdate,
      RosterField.cabinName,
      RosterField.ultracampId,
    ];

    try {
      final csvContent = await _pickAndReadCsv();
      final List<List<dynamic>> rows = const CsvToListConverter().convert(csvContent, eol: '\n');
      if (rows.length < 2) {
        // Must have at least a header and one data row
        throw CsvError(
          'CSV file has less than 2 rows (header + data).',
          'The CSV file is empty or missing data rows. Please ensure it has a header row and at least one camper entry.',
        );
      }

      final headers = rows.first.map((h) => h.toString().toLowerCase().trim()).toList();
      final Map<RosterField, int> headerIndices = _parseHeaderIndices(headers, expectedColumns);

      final List<Map<RosterField, dynamic>> campersToRegisterData = [];
      final Set<Camper> existingCampers = await registeredCampers;
      final Set<String> newCampersUniqueKeys = {}; // To track campers from the current CSV

      for (int i = 1; i < rows.length; i++) {
        final row = rows[i];
        // Skip empty rows
        if (row.every((cell) => cell == null || cell.toString().trim().isEmpty)) {
          Debug.logInfo('Skipping empty row ${i + 1}.');
          continue;
        }
        if (row.length != headers.length) {
          throw CsvError(
            'Row ${i + 1} has ${row.length} columns, expected ${headers.length}.',
            'Row ${i + 1} has an incorrect number of columns. Please ensure all rows have the same number of columns as the header.',
          );
        }
        // Pass 'i' as rowIndex for better error messages
        final camperData = _extractCamperDataFromRow(row, headerIndices, expectedColumns, i);

        // Duplicate Checking
        final String firstName = camperData[RosterField.firstName];
        final String lastName = camperData[RosterField.lastName];
        final DateTime birthdate = camperData[RosterField.birthdate];

        final String currentCamperKey = '${firstName.toLowerCase()}_${lastName.toLowerCase()}_$birthdate';

        if (await isCamperDuplicate(firstName, lastName, existingCampers)) {
          Debug.logInfo(
            'Skipping duplicate (already registered): $firstName $lastName Row: ${i + 1}',
            userMessage: 'Skipping duplicate (already registered): $firstName $lastName',
          );
          continue;
        }

        if (newCampersUniqueKeys.contains(currentCamperKey)) {
          Debug.logInfo('Skipping duplicate (within CSV): $firstName $lastName, Row: ${i + 1}');
          continue;
        }

        newCampersUniqueKeys.add(currentCamperKey);
        campersToRegisterData.add(camperData);
      }

      final Commit commit = Commit(disarmRequirementsLevel: 0);
      for (final camperData in campersToRegisterData) {
        await registerCamper(
          commit: commit,
          firstName: camperData[RosterField.firstName],
          lastName: camperData[RosterField.lastName],
          preferredName: camperData[RosterField.preferredName] ?? '',
          gender: camperData[RosterField.gender],
          birthdate: camperData[RosterField.birthdate],
          cabinName: camperData[RosterField.cabinName] ?? '',
          ultracampId: camperData[RosterField.ultracampId],
        );
      }
      return commit;
    } on CsvError catch (e, st) {
      Error.throwWithStackTrace(Debug.parseException(e), st);
      // To make the userMessage accessible to the UI, the UI's error handling
      // would need to check if the caught error is a CsvError and then access e.userMessage.
      // For now, rethrowing like this is fine for GetX to handle.
      rethrow;
    } catch (e, st) {
      // Catch any other unexpected errors
      throw CsvError(
        'An unexpected error occurred during the CSV import process: $e',
        'An unexpected error occurred. Please try again.',
      );
    }
  }

  Future<String> _pickAndReadCsv() async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['csv']);
    if (result == null) {
      throw CsvError('No CSV file selected by the user.', 'No CSV file was selected. Please try again and choose a .csv file.');
    }
    final Uint8List? bytes = result.files.first.bytes;
    if (bytes == null) {
      throw CsvError(
        'Unable to read CSV data (file bytes are null).',
        'Could not read the selected file. It might be corrupted or empty.',
      );
    }
    return String.fromCharCodes(bytes);
  }

  Map<RosterField, int> _parseHeaderIndices(List<String> headers, List<RosterField> expectedColumns) {
    final Map<RosterField, int> indices = {};
    for (final field in expectedColumns) {
      int index = -1;
      if (field.csvHeader != null) {
        index = headers.indexOf(field.csvHeader!.toLowerCase().trim());
      }
      if (index == -1 && field.csvHeaderAlt != null) {
        index = headers.indexOf(field.csvHeaderAlt!.toLowerCase().trim());
      }

      if (index == -1 && field.required) {
        throw CsvError(
          'Required column "${field.title}" (expected: "${field.csvHeader}" or "${field.csvHeaderAlt}") not found.',
          'The required column "${field.title}" is missing. Please check your CSV file.',
        );
      }
      indices[field] = index;
    }
    return indices;
  }

  Map<RosterField, dynamic> _extractCamperDataFromRow(
    List<dynamic> row,
    Map<RosterField, int> indices,
    List<RosterField> expectedColumns,
    int rowIndex,
  ) {
    final Map<RosterField, dynamic> camperData = {};

    for (final field in expectedColumns) {
      final index = indices[field]!;
      final cellValue = (index != -1 && index < row.length) ? row[index]?.toString().trim() : null;

      if (field.required && (cellValue == null || cellValue.isEmpty)) {
        throw CsvError(
          'Missing required value for "${field.title}" in row ${rowIndex + 1}. Cell value is "$cellValue".',
          'Row ${rowIndex + 1} is missing a required value for the "${field.title}" column. Please ensure all required cells have data.',
        );
      }

      switch (field.name) {
        case 'gender':
          camperData[field] = _parseGender(cellValue);
          break;
        case 'birthdate':
          // cellValue is guaranteed to be non-null here due to the required check above
          camperData[field] = _parseBirthdate(cellValue!, rowIndex);
          break;
        case 'cabinName':
          // TODO: Implement cabinName parsing
          camperData[field] = cellValue;
          break;
        default:
          camperData[field] = cellValue;
      }
    }
    return camperData;
  }

  String _parseGender(String? value) {
    if (value == null || value.isEmpty) return '';
    switch (value.toLowerCase()) {
      case 'male':
        return 'M';
      case 'female':
        return 'F';
      case 'non-binary':
      case 'nonbinary':
        return 'NB';
      default:
        // Consider if an error should be thrown for unrecognized, non-empty gender values
        // For now, returning empty as per previous logic for unrecognized values.
        return '';
    }
  }

  DateTime _parseBirthdate(String dateString, int rowIndex) {
    try {
      // Attempt to parse with time first, as in "MM/DD/YYYY HH:MM:SS AM/PM"
      try {
        final DateFormat formatWithTime = DateFormat('M/d/yyyy h:mm:ss a');
        final DateTime date = formatWithTime.parseUtc(dateString);
        return DateTime.utc(date.year, date.month, date.day, 21, 0, 0);
      } catch (_) {
        // Fallback to parsing without time, then set time
        final DateFormat formatWithoutTime = DateFormat('M/d/yyyy');
        final DateTime date = formatWithoutTime.parseUtc(dateString);
        return DateTime.utc(date.year, date.month, date.day, 21, 0, 0);
      }
    } catch (e) {
      throw CsvError(
        'Invalid birthdate format for "$dateString" in row ${rowIndex + 1}. Expected MM/DD/YYYY or MM/DD/YYYY HH:MM:SS AM/PM. Error: $e',
        'The birthdate "$dateString" in row ${rowIndex + 1} is not in the correct format. Please use MM/DD/YYYY.',
      );
    }
  }

  /// Attempts to assign a specific camper to a specific activity.
  /// Checks capacity, handles re-assignment within the same block, and updates objects in the commit.
  /// Returns true if successful, false otherwise.
  Future<bool> assignCamperToActivity(Commit commit, String camperId, String activityDepId) async {
    // 1. Fetch objects needed
    Camper camper = commit.getObject<Camper>(camperId) ?? await pullRepo.getObject<Camper>(camperId);
    ActivityDependent activityDep =
        commit.getObject<ActivityDependent>(activityDepId) ?? await pullRepo.getObject<ActivityDependent>(activityDepId);

    // Fetch the PrincipalActivity to get capacity and name
    PrincipalActivity? principalActivity =
        commit.getObject<PrincipalActivity>(activityDep.principalPar) ??
        await pullRepo.getObject<PrincipalActivity>(activityDep.principalPar);

    String activityName = principalActivity.name;
    bool alreadyInRoster = activityDep.camperRefs.contains(camperId);

    // 2. Handle potential reassignment within the same block
    String blockId = activityDep.blockRef;
    if (camper.activityAssignmentRefs.containsKey(blockId)) {
      String? currentAssignedActivityId = camper.activityAssignmentRefs[blockId];

      if (currentAssignedActivityId == activityDepId) {
        // Already assigned to this exact activity. Consider it success.
        Debug.logInfo(
          'Info: ${camper.fullName} is already assigned to $activityName ($activityDepId). No action needed.',
          userMessage:
              '${camper.fullName} is already in $activityName. No changes were made.',
        );
        return true;
      }

      if (currentAssignedActivityId != null) {
        // Camper is assigned to a *different* activity in this block, remove them first.
        Debug.logInfo(
          'Info: ${camper.fullName} is currently in activity $currentAssignedActivityId, removing before assigning to $activityName ($activityDepId).',
          userMessage:
              '${camper.fullName} is being moved to $activityName from another activity in the same block.',
        );
        bool removed = await removeCamperFromActivity(commit, camperId, currentAssignedActivityId);
        if (!removed) {
          Debug.logInfo(
            'Error: Failed to remove ${camper.fullName} from previous activity $currentAssignedActivityId. Assignment to $activityDepId aborted.',
            userMessage:
                'Could not remove ${camper.fullName} from their previous activity. The new assignment to $activityName was cancelled.',
          );
          return false;
        }
        // Re-fetch camper object as it was modified in the commit by removeCamperFromActivity
        camper = commit.getObject<Camper>(camperId)!;
      }
    }

    // 4. Perform the assignment
    if (!alreadyInRoster) {
      activityDep.camperRefs.add(camperId);
    }
    camper.activityAssignmentRefs[blockId] = activityDepId;

    // 5. Add the modified objects to the commit
    commit.addObjectsToPush({camper, activityDep});

    Debug.logInfo(
        '${camper.fullName} successfully assigned to $activityName ($activityDepId)',
        userMessage:
            'Success! ${camper.fullName} has been assigned to $activityName.');
    return true;
  }

  /// Removes a camper from a specific activity's roster and updates their assignment map.
  ///
  /// Modifies objects within the commit. Returns true on success or if state was already correct.
  Future<bool> removeCamperFromActivity(Commit commit, String camperId, String activityDepId) async {
    Camper camper = commit.getObject<Camper>(camperId) ?? await pullRepo.getObject<Camper>(camperId);
    ActivityDependent activityDep =
        commit.getObject<ActivityDependent>(activityDepId) ?? await pullRepo.getObject<ActivityDependent>(activityDepId);

    // Fetch Principal name for logging clarity
    PrincipalActivity principalActivity =
        commit.getObject<PrincipalActivity>(activityDep.principalPar) ??
        await pullRepo.getObject<PrincipalActivity>(activityDep.principalPar);
    String activityName = principalActivity.name;

    String blockId = activityDep.blockRef;
    bool changed = false;

    // Remove camper from activity roster
    if (activityDep.camperRefs.remove(camperId)) {
      changed = true;
    }

    // Remove assignment from camper object
    if (camper.activityAssignmentRefs.containsKey(blockId) && camper.activityAssignmentRefs[blockId] == activityDepId) {
      camper.activityAssignmentRefs.remove(blockId);
      changed = true;
    }

    if (changed) {
      // Add modified objects to commit ONLY if changes were made
      commit.addObjectsToPush({camper, activityDep});
      Debug.logInfo(
        '${camper.fullName} removed from $activityName ($activityDepId)',
        userMessage:
            'Success! ${camper.fullName} has been removed from $activityName.',
      );
    } else {
      Debug.logInfo(
        'Warning: Attempted to remove ${camper.fullName} from $activityName ($activityDepId), but they were not assigned to it.',
        userMessage:
            '${camper.fullName} was not in $activityName, so no changes were needed.',
      );
    }
    // Return true because the desired state (camper not assigned) is achieved.
    return true;
  }

  /// Safely unassigns a camper from their activity in a specific AMA block.
  ///
  /// Returns true if the unassignment was successful or if the camper was not
  /// assigned to any activity in that block to begin with.
  Future<bool> unassignCamperFromAmaBlock(
      Commit commit, String camperId, String amaBlockId) async {
    // 1. Fetch the camper object to access their activity assignments.
    Camper camper = commit.getObject<Camper>(camperId) ?? await pullRepo.getObject<Camper>(camperId);

    // 2. Check if the camper is assigned to an activity in the specified block.
    if (camper.activityAssignmentRefs.containsKey(amaBlockId)) {
      final String? activityDepId = camper.activityAssignmentRefs[amaBlockId];

      if (activityDepId != null) {
        Debug.logInfo(
          'Info: Camper ${camper.fullName} is assigned to activity $activityDepId in block $amaBlockId. Proceeding with removal.',
          userMessage:
              'Found ${camper.fullName} in an activity for this block. Proceeding with removal.',
        );
        return await removeCamperFromActivity(commit, camperId, activityDepId);
      }
    }

    // 3. If the camper was not assigned to any activity in this block, no action is needed.
    Debug.logInfo(
      'Info: Camper ${camper.fullName} was not assigned to an activity in block $amaBlockId. No action needed.',
      userMessage:
          '${camper.fullName} was not assigned to an activity in this block. No changes were made.',
    );
    return true;
  }

  /// Removes a camper from all of their assigned activities.
  ///
  /// Iterates through the camper's activity assignments and calls
  /// [unassignCamperFromAmaBlock] for each one.
  Future<bool> removeAllActivitiesFromCamper(Commit commit, String camperId) async {
    // 1. Fetch the camper to get their list of current activities.
    Camper camper = commit.getObject<Camper>(camperId) ?? await pullRepo.getObject<Camper>(camperId);

    // 2. Create a copy of the block IDs to prevent issues with modifying the collection while iterating.
    final List<String> blockIds = camper.activityAssignmentRefs.keys.toList();

    if (blockIds.isEmpty) {
      Debug.logInfo(
        'Info: Camper ${camper.fullName} is not assigned to any activities. No action needed.',
        userMessage:
            '${camper.fullName} has no activity assignments to remove.',
      );
      return true;
    }

    Debug.logInfo(
      'Info: Starting removal of all ${blockIds.length} activities for camper ${camper.fullName}.',
      userMessage:
          'Starting to remove ${camper.fullName} from all activities.',
    );

    // 3. Loop through the copied list and unassign the camper from each block.
    for (final String amaId in blockIds) {
      final bool success = await unassignCamperFromAmaBlock(commit, camperId, amaId);
      if (!success) {
        // If any removal fails, log the error and abort the process.
        Debug.logInfo(
          'Error: Failed to unassign ${camper.fullName} from block $amaId. Aborting removal of all activities.',
          userMessage:
              'An error occurred while removing ${camper.fullName} from an activity. The process was not completed.',
        );
        return false;
      }
    }

    Debug.logInfo(
      'Success: ${camper.fullName} has been removed from all activities.',
      userMessage: 'Success! ${camper.fullName} has been removed from all activities.',
    );
    return true;
  }
}
