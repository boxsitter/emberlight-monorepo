import 'package:ember_cli_utils/ember_cli_utils.dart';
import 'package:ember_core/src/commands/user_commands.dart';

import 'context_commands.dart';

class CoreCommands{
  static Map<String, EmberCommand> list = {...ContextCommands.list, ...UserCommands.list};
}