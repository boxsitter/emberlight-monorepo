import 'package:ember_cli_utils/ember_cli_utils.dart';
import 'package:ember_core/src/commands/dev_commands.dart';
import 'package:ember_core/src/commands/user_commands.dart';

import 'setup_commands.dart';

class CoreCommands{
  static Map<String, EmberCommand> list = {...SetupCommands.list, ...UserCommands.list, ... DevCommands.list};
}