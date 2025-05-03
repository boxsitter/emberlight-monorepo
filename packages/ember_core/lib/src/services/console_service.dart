import 'package:ember_core/ember_core_backend.dart';
import 'package:ember_core/ember_core_models.dart';
import 'package:ember_core/ember_core_services.dart';
import 'package:get/get.dart';

class ConsoleService extends GetxService {
  SessionRosterService sessionRosterService = Get.find<SessionRosterService>();
  static CoreBackend backend = BackendManager.instance;

  Future<CommandResult> runCommand(String input) async {
    if (input.trim().isEmpty) return CommandResult();

    final parts = input.split(' ');
    if (parts.isEmpty) return CommandResult(error: 'Invalid command');

    final baseCommand = parts.first;
    final arguments = parts.skip(1).toList();

    switch (baseCommand) {
      case 'clear':
        return CommandResult(log: '\x1B[2J\x1B[H');

      case 'importcsv':
        CommandResult commandResult = await importCsv();
        return commandResult;

      case 'deleteallcampers':
        return await deleteAllCampers();

      default:
        return CommandResult(error: 'Command not found, type "help" for a list of commands');
    }
  }

  // Future<CommandResult> addCamper(List<String> arguments) async {
  //   if (arguments.length < 2) {
  //     return CommandResult(error: "Usage: addcamper <firstName> <lastName>");
  //   }
  //
  //   await sessionRosterService.registerCamper(
  //     firstName: arguments[0],
  //     lastName: arguments[1],
  //   );
  //
  //   return CommandResult(success: "Camper added successfully");
  // }

  Future<CommandResult> importCsv() async {
    Commit commit = Commit(disarmRequirementsLevel: 0);
    await sessionRosterService.importFromCsv(
      commit: commit,
      firstNameHeader: 'First Name',
      lastNameHeader: 'Last Name',
      preferredNameHeader: 'Preferred Name',
      genderHeader: 'Gender',
      ageHeader: 'Age',
      cabinHeader: 'Cabin',
    );
    backend.commit(commit);
    return CommandResult();
  }


  Future<CommandResult> deleteAllCampers() async {
    Commit commit = Commit(disarmRequirementsLevel: 1);
    commit.addObjectsToDelete(await sessionRosterService.registeredCampers);
    backend.commit(commit);
    return CommandResult(success: "All campers deleted.");
  }
}

class CommandResult {
  final String? log;
  final String? error;
  final String? success;
  final Commit? request;

  CommandResult({this.log, this.error, this.success, this.request});
}