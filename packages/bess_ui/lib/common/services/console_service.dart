import 'package:bessie/common/services/session_roster_service.dart';
import 'package:bessie/data/repositories/push_repository.dart';
import 'package:get/get.dart';
import '../../../data/bess_objects/camper.dart';
import '../../data/repositories/pull_repository.dart';

class ConsoleService extends GetxService {
  SessionRosterService sessionRosterService = Get.find<SessionRosterService>();
  PullRepository bessObjectRepo = Get.find<PullRepository>();

  Future<CommandResult> runCommand(String input) async {
    if (input.trim().isEmpty) return CommandResult();

    final parts = input.split(' ');
    if (parts.isEmpty) return CommandResult(error: 'Invalid command');

    final baseCommand = parts.first;
    final arguments = parts.skip(1).toList();

    switch (baseCommand) {
      case 'clear':
        return CommandResult(log: '\x1B[2J\x1B[H');

      case 'addcamper':
        return await addCamper(arguments);

      case 'importcsv':
        return await importCsv();

      // case 'deleteallcampers':
      //   return await deleteAllCampers();

      default:
        return CommandResult(error: 'Command not found, type "help" for a list of commands');
    }
  }

  Future<CommandResult> addCamper(List<String> arguments) async {
    if (arguments.length < 2) {
      return CommandResult(error: "Usage: addcamper <firstName> <lastName>");
    }

    await sessionRosterService.registerCamper(
      firstName: arguments[0],
      lastName: arguments[1],
    );

    return CommandResult(success: "Camper added successfully");
  }

  Future<CommandResult> importCsv() async {
    await sessionRosterService.importFromCsv(
      firstNameHeader: 'First Name',
      lastNameHeader: 'Last Name',
      preferredNameHeader: 'Preferred Name',
      genderHeader: 'Gender',
      ageHeader: 'Age',
      cabinHeader: 'Cabin',
    );
    return CommandResult();
  }


  // Future<CommandResult> deleteAllCampers() async {
  //   await sessionRosterService.deleteAllCampersInSession();
  //   return CommandResult(success: "All campers deleted.");
  // }
}

class CommandResult {
  final String? log;
  final String? error;
  final String? success;

  CommandResult({this.log, this.error, this.success});
}