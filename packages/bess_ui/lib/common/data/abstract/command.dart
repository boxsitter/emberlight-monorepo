import '../../../features/console/controller/console_controller.dart';

abstract class Command {
  final int maxArgs;
  final int minArgs;
  final bool possibleFlag;
  final List<String> argTypes; // e.g., ["String", "int", ...]
  final String commandName;
  final String usage;

  Command({
    required this.maxArgs,
    required this.minArgs,
    required this.possibleFlag,
    required this.argTypes,
    required this.commandName,
    required this.usage,
  });

  // Validate arguments
  void validateArguments(List<String> arguments, Map<String, String?> flags) {
    if (arguments.length > maxArgs) {
      throw ArgumentError('Too many arguments provided. Expected less than $maxArgs.');
    }

    if (arguments.length < minArgs) {
      throw ArgumentError('Too few arguments provided. Expected at least $minArgs.');
    }

    for (int i = 0; i < arguments.length; i++) {
      final argType = argTypes[i];
      switch (argType) {
        case 'int':
          if (int.tryParse(arguments[i]) == null) {
            throw ArgumentError('Argument ${i+1} should be an integer.');
          }
          break;
        case 'String':
          if (int.tryParse(arguments[i]) != null) {
            throw ArgumentError('Argument ${i+1} should be a string.');
          }
          break;
      // Add more types as needed
        default:
          throw ArgumentError('Unsupported argument type: $argType');
      }
    }

    if (!possibleFlag && flags.isNotEmpty) {
      throw ArgumentError('Flags are not allowed for this command.');
    }
  }

  void runCommand(dynamic controller, List<String> arguments, Map<String, String?> flags);

  void execute(dynamic controller, List<String> arguments, Map<String, String?> flags) {
    try {
      validateArguments(arguments, flags);
      runCommand(controller, arguments, flags);
    } catch (e) {
      ConsoleController().error('$e');
      ConsoleController().log(usage);
    }
  }
}
