import 'package:get/get.dart';
import 'package:xterm/core.dart';
import '../../../common/services/console_service.dart';

class ConsoleController extends GetxController {
  late ConsoleService consoleService;

  late final Terminal terminal;
  final List<String> history = [];
  int historyIndex = -1;
  String _prompt = 'home❯ ';
  String inputBuffer = '';

  @override
  void onInit() {
    super.onInit();

    terminal = Terminal(
      maxLines: 10000,
      onOutput: (String key) {
        if (key == '\x1B[A') {
          if (history.isNotEmpty && historyIndex > 0) {
            historyIndex--;
            _replaceInputBuffer(history[historyIndex]);
          }
        } else if (key == '\x1B[B') {
          if (history.isNotEmpty && historyIndex < history.length - 1) {
            historyIndex++;
            _replaceInputBuffer(history[historyIndex]);
          } else if (historyIndex == history.length - 1) {
            historyIndex++;
            _replaceInputBuffer('');
          }
        } else if (key == '\x1B[D' || key == '\x1B[C') {
          // Do nothing for left and right arrows
        } else {
          _handleInput(key);
        }
      },
    );
    writePrompt();
  }

  void setConsoleService() {
    consoleService = Get.find<ConsoleService>();
  }

  void writePrompt() {
    terminal.write('\r');
    terminal.write('\x1B[1;32m$_prompt\x1B[0m');
  }

  Future<void> _handleInput(String data) async {
    for (var char in data.split('')) {
      switch (char) {
        case '\r':
          terminal.write('\r');
          await _executeCommand(inputBuffer);
          if (inputBuffer != 'clear') {
            terminal.write('\n');
          }
          inputBuffer = '';
          writePrompt();
          break;

        case '\b':
        case '\u007F':
          if (inputBuffer.isNotEmpty) {
            inputBuffer = inputBuffer.substring(0, inputBuffer.length - 1);
            terminal.write('\b \b');
          }
          break;

        default:
          inputBuffer += char;
          terminal.write(char);
      }
    }
  }

  void _replaceInputBuffer(String newInput) {
    while (inputBuffer.isNotEmpty) {
      terminal.write('\b \b');
      inputBuffer = inputBuffer.substring(0, inputBuffer.length - 1);
    }
    inputBuffer = newInput;
    terminal.write(newInput);
  }

  void log(String text) {
    final adjustedText = text.replaceAll('\n', '\r\n ');
    terminal.write('\r\n\x1B[96m $adjustedText\x1B[0m');
  }

  void error(String text) {
    final adjustedText = text.replaceAll('\n', '\r\n ');
    terminal.write('\r\n\x1B[91m $adjustedText\x1B[0m');
  }

  void success(String text) {
    final adjustedText = text.replaceAll('\n', '\r\n ');
    terminal.write('\r\n\x1B[92m $adjustedText\x1B[0m');
  }

  set prompt(String value) {
    _prompt = '$value❯ ';
  }

  Future<void> _executeCommand(String input) async {
    final result = await consoleService.runCommand(input);
    if (result.log != null) log(result.log!);
    if (result.error != null) error(result.error!);
    if (result.success != null) success(result.success!);
  }
}
