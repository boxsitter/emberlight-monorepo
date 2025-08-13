// import 'dart:async';

// import 'package:ember_cli_utils/ember_cli_utils.dart';
// import 'package:emdev/src/services/path_service.dart';
// import 'package:path/path.dart' as p;

// class ConfigCommands {
//   UserInput userInput;
//   UserOutput userOutput;
//   final List<EmberCommand> list = [];

//   ConfigCommands({required this.userInput, required this.userOutput}) {
//     // Populate the list in the constructor's body
//     list.addAll([
//       SetWorkingDirectory(userInput: userInput, userOutput: userOutput),
//       // You can add more commands to this list here
//       // e.g., AnotherConfigCommand(userInput: userInput, userOutput: userOutput),
//     ]);
//   }
// }

// class SetWorkingDirectory extends EmberCommand<void> {
//   @override
//   final String name = 'setwd';

//   @override
//   final String description = 'Sets emdev\'s working directory';

//   SetWorkingDirectory({required super.userInput, required super.userOutput});

//   @override
//   FutureOr<void> run() async {
//     PathService pathService = Get.find<PathService>();
//     String? monorepoRootInput;
//     bool configured = false;

//     while (!configured) {
//       monorepoRootInput = await userInput.prompt(
//         'Enter the absolute path to your "emberlight-monorepo" directory:',
//         allowEmpty: false,
//       );

//       final potentialEmdevPath = p.join(monorepoRootInput, 'projects', 'emdev');

//       if (await pathService.trySetPath(potentialEmdevPath, monorepoRootInput)) {
//         configured = true;
//       } else {
//         final retry = await userInput.confirm('Do you want to try again?', defaultValue: true);
//         if (!retry) {
//           userOutput.error('Path configuration cancelled by user.');
//           throw StateError('Emdev project path configuration is required to continue.');
//         }
//       }
//     }
//   }
// }