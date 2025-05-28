import 'dart:convert';
import 'dart:io';

import 'package:ember_cli_utils/ember_cli_utils.dart';
import 'package:path/path.dart' as p;

import '../constants.dart';

class ConfigService {
  late final File _configFile;
  final UserOutput userOutput;

  ConfigService({required this.userOutput}) {
    _initializeConfigFile();
  }

  void _initializeConfigFile() {
    String? homePath;
    if (Platform.isWindows) {
      homePath = Platform.environment['USERPROFILE'];
    } else {
      homePath = Platform.environment['HOME'];
    }

    if (homePath == null) {
      throw StateError(
          'Could not determine home directory. Please ensure HOME or USERPROFILE environment variable is set.');
    }

    final configDirPath = p.join(homePath, Constants.configDirName);
    final configDir = Directory(configDirPath);

    if (!configDir.existsSync()) {
      configDir.createSync(recursive: true);
    }
    _configFile = File(p.join(configDirPath, Constants.configFileName));
  }

  Future<Map<String, dynamic>> loadConfig() async {
    if (await _configFile.exists()) {
      try {
        final content = await _configFile.readAsString();
        if (content.isNotEmpty) {
          return jsonDecode(content) as Map<String, dynamic>;
        }
      } catch (e) {
        // Log error or handle corrupted file, for now, return empty
        userOutput.error('Error reading config file: $e. Starting with a fresh config.');
      }
    }
    return {};
  }

  Future<void> saveConfig(Map<String, dynamic> config) async {
    try {
      await _configFile.writeAsString(jsonEncode(config));
    } catch (e) {
      userOutput.error('Error writing config file: $e');
      // Potentially re-throw or handle more gracefully
      rethrow;
    }
  }

  Future<String?> getEmdevProjectPath() async {
    final config = await loadConfig();
    return config[Constants.emdevProjectPathKey] as String?;
  }

  Future<void> saveEmdevProjectPath(String path) async {
    final config = await loadConfig();
    config[Constants.emdevProjectPathKey] = path;
    await saveConfig(config);
  }
}