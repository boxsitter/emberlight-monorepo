import 'dart:io';

import 'package:get/get.dart';

import '../../../../common/data/abstract/command.dart';
import '../../../../common/data/abstract/command_set.dart';
import '../../../session_roster/controllers/session_roster_controller.dart';

class SessionRosterCommands extends CommandSet{
  SessionRosterCommands() : super(
    controller: Get.find<SessionRosterController>(),
    featureName: 'sessionroster',
  );

  @override
  void initializeCommands() {
    super.commands['createcamper'] = Createcamper();
    super.commands['roster'] = DisplayRoster();
    super.commands['importcsv'] = ImportCsv();
    super.commands['exportroster'] = ExportRoster();
  }
}

class Createcamper extends Command {
  Createcamper() : super(
      maxArgs: 3,
      minArgs: 3,
      possibleFlag: false,
      argTypes: ['String', 'String', 'int'],
      commandName: 'createcamper',
      usage: 'Usage: createcamper <firstName> <lastName> <age>'
  );

  @override
  void runCommand(dynamic controller, List<String> arguments, Map<String, String?> flags) {
    controller.createCamper(
      firstName: arguments[0],
      lastName: arguments [1],
      age: int.parse(arguments[2]),
    );
  }
}

class DisplayRoster extends Command {
  DisplayRoster() : super(
      maxArgs: 0,
      minArgs: 0,
      possibleFlag: false,
      argTypes: [],
      commandName: 'roster',
      usage: 'Usage: roster'
  );

  @override
  void runCommand(dynamic controller, List<String> arguments, Map<String, String?> flags) {
    controller.logSessionRoster();
  }
}

class ImportCsv extends Command {
  ImportCsv() : super(
      maxArgs: 0,
      minArgs: 0,
      possibleFlag: false,
      argTypes: [],
      commandName: 'importcsv',
      usage: 'Usage: importcsv'
  );

  @override
  void runCommand(dynamic controller, List<String> arguments, Map<String, String?> flags) {
    controller.importFromCsv(File('C:\\Users\\Leyto\\User Projects\\bessie\\lib\\common\\data\\test_files\\dummy_roster.csv')); // TODO: Fix hardcoding
  }
}

class ExportRoster extends Command {
  ExportRoster() : super(
      maxArgs: 0,
      minArgs: 0,
      possibleFlag: false,
      argTypes: [],
      commandName: 'exportroster',
      usage: 'Usage: exportroster'
  );

  @override
  void runCommand(dynamic controller, List<String> arguments, Map<String, String?> flags) {
    controller.exportPdf();
  }
}