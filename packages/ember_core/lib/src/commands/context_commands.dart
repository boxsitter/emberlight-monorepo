import 'dart:async';
import 'dart:convert';

import 'package:ember_cli_utils/ember_cli_utils.dart';
import 'package:ember_core/ember_core_frontend.dart';

class ContextCommands {
  static Map<String, EmberCommand> list = {
    'con': ViewContext(
      userInput: FrontendManager.instance.getUserInputImplementation(),
      userOutput: FrontendManager.instance.getUserOutputImplementation(),
    ),
    'orgs': ListOrganizations(
      userInput: FrontendManager.instance.getUserInputImplementation(),
      userOutput: FrontendManager.instance.getUserOutputImplementation(),
    ),
    'brns': ListBranches(
      userInput: FrontendManager.instance.getUserInputImplementation(),
      userOutput: FrontendManager.instance.getUserOutputImplementation(),
    ),
    'seas': ListSeasons(
      userInput: FrontendManager.instance.getUserInputImplementation(),
      userOutput: FrontendManager.instance.getUserOutputImplementation(),
    ),
    'sess': ListSessions(
      userInput: FrontendManager.instance.getUserInputImplementation(),
      userOutput: FrontendManager.instance.getUserOutputImplementation(),
    ),
    'migcon': MigrateContext(
      userInput: FrontendManager.instance.getUserInputImplementation(),
      userOutput: FrontendManager.instance.getUserOutputImplementation(),
    ),
  };
}

///  extends EmberCommand to view the current client context.
class ViewContext extends EmberCommand {
  @override
  final String name = 'con';
  @override
  final String description = 'Displays the current client context (organization, branch, season, session).';
  @override
  String get invocationDetails => 'con';
  @override
  List<String> get examples => ['con'];

  ViewContext({
    required super.userInput,
    required super.userOutput,
  });

  @override
  FutureOr<void> run() {
    // TODO: Implement run method
    // 1. Get current context from ClientContextService.
    // 2. Format and display the context details using userOutput.
    userOutput.info('ViewContext extends EmberCommand run: Not yet implemented.');
    userOutput.printProperty('Current Organization', 'TODO');
    userOutput.printProperty('Current Branch', 'TODO');
    userOutput.printProperty('Current Season', 'TODO');
    userOutput.printProperty('Current Session', 'TODO');
  }
}

///  extends EmberCommand to list available organizations.
class ListOrganizations extends EmberCommand {
  @override
  final String name = 'orgs';
  @override
  final String description = 'Lists all available organizations.';
  @override
  String get invocationDetails => 'orgs';
  @override
  List<String> get examples => ['orgs'];

  ListOrganizations({
    required super.userInput,
    required super.userOutput,
    // required ClientContextService clientContextService
  });

  @override
  Future<void> run() async {
    userOutput.info('ListOrganizations extends EmberCommand run: Initiating form prompt.');
    final List<FormFieldDescriptor> formFieldDescriptors = [
      TextFormFieldDescriptor(label: 'Enter Text', hintText: 'Some hint text', isRequired: false),
      BooleanFormFieldDescriptor(label: 'Select Boolean', defaultValue: false, isRequired: false),
      SelectFormFieldDescriptor(
        label: 'Select Option',
          options: ['Option 1', 'Option 2', 'Option 3'],
        optionLabelBuilder: (String value) => value, // Kept as String Function(String)
        isRequired: false,
      ),
      MultiSelectFormFieldDescriptor(
        label: 'Select Multiple Options',
        options: ['Option A', 'Option B', 'Option C'],
        optionLabelBuilder: (String value) => value, // Kept as String Function(String)
          isRequired: false
      ),
    ];
    final promptOutput = await userInput.promptForm('Test Form from ListOrganizations', formFieldDescriptors);

    userOutput.printList(promptOutput!.map((e) => e.toString()).toList());
  }
}

///  extends EmberCommand to list available branches within the current/specified organization.
class ListBranches extends EmberCommand {
  @override
  final String name = 'brns';
  @override
  final String description = 'Lists available branches for the current or a specified organization.';
  @override
  String get invocationDetails => 'brns';
  @override
  List<String> get examples => ['brns'];

  ListBranches({
    required super.userInput,
    required super.userOutput,
    // required ClientContextService clientContextService
  });

  @override
  FutureOr<void> run() {
    // TODO: Implement run method
    // 1. Get orgId from args or current context.
    // 2. Fetch branches for that org.
    // 3. Display them.
    userOutput.info('ListBranches extends EmberCommand run: Not yet implemented.');
  }
}

// Similar commands would follow for Season and Session:
// - `season list [--branchId <branchId>]`
// - `season set <seasonId>`
// - `session list [--seasonId <seasonId>]`
// - `session set <sessionId>`

///  extends EmberCommand to list available seasons for the current/specified branch.
class ListSeasons extends EmberCommand {
  @override
  final String name = 'seas';
  @override
  final String description = 'Lists available seasons for the current or a specified branch.';
  @override
  String get invocationDetails => 'seas';
  @override
  List<String> get examples => ['seas'];

  ListSeasons({
    required super.userInput,
    required super.userOutput,
  });

  @override
  FutureOr<void> run() {
    userOutput.info('ListSeasons extends EmberCommand run: Not yet implemented.');
  }
}

///  extends EmberCommand to list available sessions for the current/specified season.
class ListSessions extends EmberCommand {
  @override
  final String name = 'sess';
  @override
  final String description = 'Lists available sessions for the current or a specified season.';
  @override
  String get invocationDetails => 'sess';
  @override
  List<String> get examples => ['sess'];

  ListSessions({
    required super.userInput,
    required super.userOutput,
  });

  @override
  FutureOr<void> run() {
    userOutput.info('ListSessions extends EmberCommand run: Not yet implemented.');
  }
}

///  extends EmberCommand to list available sessions for the current/specified season.
class MigrateContext extends EmberCommand {
  @override
  final String name = 'migcon';
  @override
  final String description = 'Attempts to migrate the user to a new context';
  @override
  String get invocationDetails => 'migcon';
  @override
  List<String> get examples => ['migcon'];

  MigrateContext({
    required super.userInput,
    required super.userOutput,
  });

  @override
  FutureOr<void> run() {
    userOutput.info('Attempts to migrate the user to a new context');
  }
}