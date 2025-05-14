import 'dart:io';

import 'package:ember_cli_utils/ember_cli_utils.dart';
import 'package:emdev/src/constants.dart';

class FilesService {
  late Map<String, String> allProjectNamesToPaths;
  late String selectedProjectName;
  late String selectedProjectPath;

  late Map<String, String> relevantPackageNamesToPaths;

  Future<void> init(CliInput input) async {
    allProjectNamesToPaths = {};
    relevantPackageNamesToPaths = {};

    // --- Populate project names and paths map ---
    final projectsRoot = Directory(_projectsDirAbs);
    if (!await projectsRoot.exists()) {
      print('Error: Projects directory not found at ${_projectsDirAbs}');
      // Potentially throw an error or exit
      return;
    }

    final projectEntities = projectsRoot.list();
    await for (final entity in projectEntities) {
      if (entity is Directory) {
        final projectPath = entity.path;
        final pubspecFile = File(p.join(projectPath, 'pubspec.yaml'));
        if (await pubspecFile.exists()) {
          try {
            final pubspecContent = await pubspecFile.readAsString();
            final pubspecYaml = loadYaml(pubspecContent) as YamlMap;
            final projectName = pubspecYaml['name'] as String?;
            if (projectName != null && projectName.isNotEmpty) {
              allProjectNamesToPaths[projectName] = projectPath;
            } else {
              print('Warning: Could not find project name in ${pubspecFile.path}');
            }
          } catch (e) {
            print('Error reading or parsing ${pubspecFile.path}: $e');
          }
        }
      }
    }

    if (allProjectNamesToPaths.isEmpty) {
      print('No projects found in ${_projectsDirAbs}. Please check the path and project structures.');
      // You might want to exit or throw an error here
      return;
    }

    selectedProjectName = input.select(
      'Select a project to manage',
      options: allProjectNamesToPaths.keys.toList(),
    );
    selectedProjectPath = allProjectNamesToPaths[selectedProjectName]!;

    // --- Populate relevantPackageNamesToPaths ---
    final selectedProjectPubspecFile = File(p.join(selectedProjectPath, 'pubspec.yaml'));
    if (!await selectedProjectPubspecFile.exists()) {
      print('Error: pubspec.yaml not found for selected project at ${selectedProjectPubspecFile.path}');
      return;
    }

    try {
      final selectedPubspecContent = await selectedProjectPubspecFile.readAsString();
      final selectedPubspecYaml = loadYaml(selectedPubspecContent) as YamlMap;

      final dependencies = selectedPubspecYaml['dependencies'] as YamlMap?;
      if (dependencies != null) {
        for (final entry in dependencies.entries) {
          final packageName = entry.key as String;
          final packageValue = entry.value;

          if (packageValue is YamlMap && packageValue.containsKey('path')) {
            // This is a local path dependency, likely a monorepo package
            final relativePath = packageValue['path'] as String;
            // The path in pubspec.yaml is relative to the pubspec.yaml file itself.
            // Example: ../../packages/ember_core from apps/bessie/pubspec.yaml
            // This needs to be resolved to an absolute path or a path relative to the monorepo root.
            final packagePath = p.normalize(p.join(selectedProjectPath, relativePath));

            // We should also verify this package exists in the main packages directory (_packagesDirAbs)
            // and get its pubspec name, as the directory name might differ.
            final packagePubspecFile = File(p.join(packagePath, 'pubspec.yaml'));
            if (await packagePubspecFile.exists()) {
              final packagePubspecContent = await packagePubspecFile.readAsString();
              final packagePubspecYaml = loadYaml(packagePubspecContent) as YamlMap;
              final actualPackageName = packagePubspecYaml['name'] as String?;

              if (actualPackageName != null) {
                // Storing path to the package directory.
                relevantPackageNamesToPaths[actualPackageName] = packagePath;
              } else {
                print('Warning: Could not determine pubspec name for package at $packagePath');
              }
            } else {
              print('Warning: Referenced local package pubspec.yaml not found at $packagePath (dependency: $packageName)');
            }
          }
        }
      }
    } catch (e) {
      print('Error reading or parsing selected project pubspec ${selectedProjectPubspecFile.path}: $e');
    }

    // For debugging:
    print('\n--- Initialization Complete ---');
    print('Found projects: $allProjectNamesToPaths');
    print('Selected project: $selectedProjectName at $selectedProjectPath');
    print('Relevant packages for $selectedProjectName: $relevantPackageNamesToPaths');
    print('-----------------------------\n');
  }
}