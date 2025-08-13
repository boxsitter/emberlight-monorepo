// import 'dart:io';

// import 'package:ember_cli_utils/ember_cli_utils.dart';
// import 'package:emdev/src/commands/config_commands.dart';
// import 'package:path/path.dart' as p;

// import 'config_service.dart';

// class PathService {
//   final ConfigService configService;
//   final UserOutput userOutput;
//   final UserInput userInput;

//   String? _emdevProjectPath;
//   String? _monorepoBasePath;

//   PathService({required this.userOutput, required this.userInput, required this.configService});

//   String get emdevProjectPath {
//     if (_emdevProjectPath == null) {
//       throw StateError(
//           'PathService not initialized or emdevProjectPath is not set. Please run configuration.');
//     }
//     return _emdevProjectPath!;
//   }

//   String get monorepoBasePath {
//     if (_monorepoBasePath == null) {
//       throw StateError(
//           'PathService not initialized or monorepoBasePath is not set. Please run configuration.');
//     }
//     return _monorepoBasePath!;
//   }

//   /// Initializes the PathService.
//   /// Attempts to load and validate the path from config.
//   /// If not found or invalid, it triggers interactive configuration.
//   Future<void> initialize() async {
//     if (!await _tryLoadAndValidatePath()) {
//       userOutput.warning('Emdev project path is not configured or is invalid.');
//       await SetWorkingDirectory(userInput: userInput, userOutput: userOutput).run();
//     }
//   }

//   Future<bool> _tryLoadAndValidatePath() async {
//     final storedPath = await configService.getEmdevProjectPath();
//     if (storedPath == null || storedPath.isEmpty) {
//       return false;
//     }

//     if (await _isValidEmdevProjectPath(storedPath)) {
//       _emdevProjectPath = storedPath;
//       _monorepoBasePath = p.dirname(
//           p.dirname(storedPath)); // projects/emdev -> projects -> monorepo_root
//       userOutput.info('Using emdev project path: $_emdevProjectPath');
//       return true;
//     }
//     return false;
//   }

//   Future<bool> _isValidEmdevProjectPath(String path) async {
//     final emdevDir = Directory(path);
//     if (!await emdevDir.exists()) {
//       userOutput.error('Path does not exist: $path');
//       return false;
//     }
//     if (FileSystemEntityType.directory != await FileSystemEntity.type(path)) {
//       userOutput.error('Path is not a directory: $path');
//       return false;
//     }

//     if (p.basename(path) != 'emdev') {
//       userOutput.error('Directory name is not "emdev": ${p.basename(path)}');
//       return false;
//     }

//     final projectsPath = p.dirname(path);
//     if (p.basename(projectsPath) != 'projects') {
//       userOutput.error(
//           'Parent directory is not "projects": ${p.basename(projectsPath)}');
//       return false;
//     }

//     final monorepoRootPath = p.dirname(projectsPath);
//     // We can make this check more robust if needed, e.g., by looking for a specific file like melos.yaml
//     if (p
//         .basename(monorepoRootPath)
//         .isEmpty) { // A simple check for a valid parent
//       userOutput.error('Invalid monorepo root structure for path: $path');
//       return false;
//     }

//     return true;
//   }

//   Future<bool> trySetPath(String potentialEmdevPath, String monorepoRootInput) async {
//     if (await _isValidEmdevProjectPath(potentialEmdevPath)) {
//       _emdevProjectPath = potentialEmdevPath;
//       _monorepoBasePath = monorepoRootInput;
//       await configService.saveEmdevProjectPath(_emdevProjectPath!);
//       userOutput.success('Emdev project path configured successfully to: $_emdevProjectPath');
//       return true;
//     } else {
//       userOutput.error(
//           'The path provided does not lead to a valid "emberlight-monorepo/projects/emdev" structure. Please check the path and try again.'
//       );
//       return false;
//     }
//   }

//   /// Resolves a path relative to the emdev project directory.
//   String resolve(String relativePath) {
//     return p.join(emdevProjectPath, relativePath);
//   }

//   /// Resolves a path relative to the monorepo root directory.
//   String resolveFromMonorepoRoot(String relativePath) {
//     return p.join(monorepoBasePath, relativePath);
//   }
// }