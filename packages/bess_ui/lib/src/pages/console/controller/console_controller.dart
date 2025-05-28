import 'dart:async';

import 'package:ansicolor/ansicolor.dart';
import 'package:bess_ui/src/common/services/popup_service.dart';
import 'package:ember_cli_utils/ember_cli_utils.dart';
import 'package:ember_core/ember_core_utils.dart';
import 'package:get/get.dart';
import 'package:xterm/core.dart';

// Constants for ANSI escape codes
class _AnsiCodes {
  static const String cursorUp = '\x1B[A';
  static const String cursorDown = '\x1B[B';
  static const String cursorRight = '\x1B[C';
  static const String cursorLeft = '\x1B[D';
  static const String clearScreen = '\x1B[2J\x1B[H';
  static const String backspace = '\b';
  static const String delete = '\u007F';
  static const String enter = '\r';
}

class ConsoleController extends GetxController implements UserOutput, UserInput {
  PopupService popupService = Get.find<PopupService>();

  late final Terminal terminal;
  final List<String> history = [];
  int historyIndex = -1;

  // Refined prompt text handling
  final String _mainCommandPrompt = '> '; // Your default main command prompt
  String _currentPromptText = '> ';      // Holds the text of the prompt currently visually forming the line
  String? _activeInputPromptMessage;     // Stores the specific message for an active UserInput.prompt()

  String inputBuffer = '';

  bool _isAwaitingPromptInput = false;
  Completer<String>? _promptCompleter;
  FutureOr<bool> Function(String)? _currentPromptValidator;
  bool _currentPromptAllowEmpty = false;

  final AnsiPen _penError = AnsiPen()..red(bold: true);
  final AnsiPen _penWarning = AnsiPen()..yellow();
  final AnsiPen _penSuccess = AnsiPen()..green();
  final AnsiPen _penInfo = AnsiPen()..blue();
  final AnsiPen _penEmph = AnsiPen()..cyan(bold: true);
  final AnsiPen _penDim = AnsiPen()..gray(level: 0.5);

  @override
  void onInit() {
    super.onInit();
    _currentPromptText = _mainCommandPrompt; // Initialize with the main command prompt
    terminal = Terminal(
      maxLines: 10000,
      onOutput: _handleTerminalOutput,
    );
    writePrimaryPrompt();
  }

  void _handleTerminalOutput(String data) {
    if (_isAwaitingPromptInput) {
      _handlePromptKeyInput(data);
    } else {
      _handleCommandKeyInput(data);
    }
  }

  void writePrimaryPrompt() {
    terminal.write('\r\n$_mainCommandPrompt');
    _currentPromptText = _mainCommandPrompt; // Update current visual prompt text
  }

  void _writeTemporaryPrompt(String message) {
    terminal.write('\r${' ' * (_currentPromptText.length + inputBuffer.length)}\r');
    terminal.write('$message ');
    _currentPromptText = message + " "; // Update current visual prompt text to the temporary one
  }

  Future<void> _executeCommand(String command) async {
    if (command.isEmpty) return;

    if (!_isAwaitingPromptInput) {
      history.add(command);
      historyIndex = history.length;
    }

    terminal.write('\r${' ' * (_currentPromptText.length + command.length)}\r');

    try {
      if (command == 'clear') {
        terminal.write(_AnsiCodes.clearScreen);
      } else {
        void handleError(String message) {
          error(message);
        }

        ParsedCommandResult result = CommandParser.parseCommand(
            command,
            availableCommands: CoreCommands.list,
            setErrorMessage: handleError,
            initialArgs: [],
            initialFlagsAndOptions: {},
        );

        if (result.command != null) {
          await result.command!.run();
        }
      }
    } catch (e) {
      error('Failed to execute command: $command', details: e.toString());
    }
  }

  void _handleCommandKeyInput(String data) async {
    if (data == _AnsiCodes.cursorUp) {
      if (history.isNotEmpty) {
         if (historyIndex == -1) { // Not currently Browse or at the start of Browse
            historyIndex = history.length -1;
         } else if (historyIndex > 0) {
        historyIndex--;
         }
        _replaceInputBuffer(history[historyIndex]);
      }
    } else if (data == _AnsiCodes.cursorDown) {
      if (history.isNotEmpty && historyIndex < history.length - 1) {
        historyIndex++;
        _replaceInputBuffer(history[historyIndex]);
      } else if (historyIndex == history.length -1 ){
        historyIndex++;
        _replaceInputBuffer('');
      }
    } else if (data == _AnsiCodes.cursorLeft || data == _AnsiCodes.cursorRight) {
      // Left/Right arrow - could implement cursor movement within inputBuffer later
    } else {
      for (var charRune in data.runes) {
        final charStr = String.fromCharCode(charRune);
        switch (charStr) {
          case _AnsiCodes.enter:
            terminal.write('\r');
            String commandToExecute = inputBuffer;
            inputBuffer = '';
            await _executeCommand(commandToExecute);
            if (commandToExecute != 'clear') {
              terminal.write('\n');
            }
            writePrimaryPrompt();
            break;
          case _AnsiCodes.backspace:
          case _AnsiCodes.delete:
            if (inputBuffer.isNotEmpty) {
              inputBuffer = inputBuffer.substring(0, inputBuffer.length - 1);
              terminal.write('\b \b');
            }
            break;
          default:
            if (charRune >= 32 && charRune != 127) { // Printable characters
              inputBuffer += charStr;
              terminal.write(charStr);
            }
        }
      }
    }
  }

  void _handlePromptKeyInput(String data) async {
    for (var charRune in data.runes) {
      final char = String.fromCharCode(charRune);
      switch (char) {
        case _AnsiCodes.enter:
          final currentValue = inputBuffer;
          // Use _activeInputPromptMessage for re-prompting if validation fails
          final String messageForReprompt = _activeInputPromptMessage ?? _mainCommandPrompt;

          if (!_currentPromptAllowEmpty && currentValue.trim().isEmpty) {
            final String visualInputCleared = '\r${' ' * currentValue.length}\r';
            terminal.write(visualInputCleared);
            _writeWithNewlineAndPromptFix(_penError('Input cannot be empty.'));
            _writeTemporaryPrompt(messageForReprompt); // Re-show the original prompt message
            // inputBuffer is already empty or will be cleared
            return;
          }

          bool isValid = true;
          if (_currentPromptValidator != null) {
            final validationResult = _currentPromptValidator!(currentValue);
            if (validationResult is Future<bool>) {
              isValid = await validationResult;
            } else {
              isValid = validationResult;
            }
          }

          if (isValid) {
            _isAwaitingPromptInput = false;
            terminal.write('\r\n');
            _promptCompleter?.complete(currentValue);
            _promptCompleter = null;
            inputBuffer = '';
            _activeInputPromptMessage = null; // Clear active message
            writePrimaryPrompt();
          } else {
            final String visualInputCleared = '\r${' ' * currentValue.length}\r';
            terminal.write(visualInputCleared);
            inputBuffer = ''; // Clear buffer for re-entry
            _writeWithNewlineAndPromptFix(_penError('Invalid input. Please try again.'));
            _writeTemporaryPrompt(messageForReprompt); // Re-show the original prompt message
          }
          break;
        case _AnsiCodes.backspace:
        case _AnsiCodes.delete:
          if (inputBuffer.isNotEmpty) {
            inputBuffer = inputBuffer.substring(0, inputBuffer.length - 1);
            terminal.write('\b \b');
          }
          break;
        default:
          if (charRune >= 32 && charRune != 127) { // Printable characters
            inputBuffer += char;
            terminal.write(char);
          }
      }
    }
  }


  void _replaceInputBuffer(String newInput) {
    // Visually clear current inputBuffer
    for (int i = 0; i < inputBuffer.length; i++) {
        terminal.write('\b \b');
    }
    inputBuffer = newInput;
    terminal.write(newInput);
  }

  void _writeWithNewlineAndPromptFix(String text) {
    terminal.write('\r${' ' * (_currentPromptText.length + inputBuffer.length)}\r');
    terminal.write(text.replaceAll('\n', '\r\n'));
    terminal.write('\r\n');
    if (!_isAwaitingPromptInput) {
      // Restore the main command prompt and current input buffer
      terminal.write('$_mainCommandPrompt$inputBuffer');
      _currentPromptText = _mainCommandPrompt; // Ensure current visual prompt is main prompt
    } else {
      // If awaiting input, restore the temporary input prompt and current input buffer
      // Use _activeInputPromptMessage if available, otherwise _currentPromptText (which should be the temp prompt message)
      final promptToDisplay = (_activeInputPromptMessage ?? _currentPromptText) + (inputBuffer.isNotEmpty ? inputBuffer : "");
      terminal.write(promptToDisplay);
    }
  }

  @override
  void log(String message) {
    _writeWithNewlineAndPromptFix(message);
  }

  @override
  void error(String message, {String? details}) {
    String fullMessage = _penError('Error: $message');
    if (details != null && details.isNotEmpty) {
      fullMessage += '\r\n${_penDim(details)}';
    }
    _writeWithNewlineAndPromptFix(fullMessage);
  }

  @override
  void warning(String message) {
    _writeWithNewlineAndPromptFix(_penWarning('Warning: $message'));
  }

  @override
  void success(String message) {
    _writeWithNewlineAndPromptFix(_penSuccess(message));
  }

  @override
  void info(String message) {
    _writeWithNewlineAndPromptFix(_penInfo(message));
  }

  @override
  void printEmph(String message) {
    _writeWithNewlineAndPromptFix(_penEmph(message));
  }

  @override
  void printDim(String message) {
    _writeWithNewlineAndPromptFix(_penDim(message));
  }

  @override
  void printHeading(String message) {
    final heading = '${_penEmph(message.toUpperCase())}\r\n${'-' * message.length}';
    _writeWithNewlineAndPromptFix(heading);
  }

  @override
  void printProperty(String key, dynamic value) {
    _writeWithNewlineAndPromptFix('${_penEmph(key)}: $value');
  }

  @override
  void printList(List<String> items, {String title = 'Items:'}) {
    String listOutput = title;
    if (items.isEmpty) {
      listOutput += ' (No items)';
    } else {
      for (final item in items) {
        listOutput += '\r\n  - $item';
      }
    }
    _writeWithNewlineAndPromptFix(listOutput);
  }

  @override
  void printTable(List<List<String>> dataRows, {List<String>? headers}) {
    if (dataRows.isEmpty && (headers == null || headers.isEmpty)) {
      _writeWithNewlineAndPromptFix('(Empty table)');
      return;
    }

    StringBuffer sb = StringBuffer();
    List<int> columnWidths = [];

    if (headers != null && headers.isNotEmpty) {
      for (int i = 0; i < headers.length; i++) {
        columnWidths.add(headers[i].length);
      }
    }

    for (var row in dataRows) {
      for (int i = 0; i < row.length; i++) {
        if (i < columnWidths.length) {
          if (row[i].length > columnWidths[i]) {
            columnWidths[i] = row[i].length;
          }
        } else {
          columnWidths.add(row[i].length);
        }
      }
    }
    if (headers != null && headers.isNotEmpty) {
      for (int i = 0; i < headers.length; i++) {
        sb.write(_penEmph(headers[i].padRight(columnWidths[i])) + '  ');
      }
      sb.write('\r\n');
      for (int i = 0; i < headers.length; i++) {
        sb.write('-'.padRight(columnWidths[i], '-') + '  ');
      }
      sb.write('\r\n');
    }
    for (var row in dataRows) {
      for (int i = 0; i < row.length; i++) {
        sb.write(row[i].padRight(columnWidths[i]) + '  ');
      }
      sb.write('\r\n');
    }
    _writeWithNewlineAndPromptFix(sb.toString().trimRight());
  }

  @override
  Future<String> prompt(
      String message, {
        String? defaultValue,
        bool allowEmpty = false,
        FutureOr<bool> Function(String)? validator,
      }) {
    if (_isAwaitingPromptInput) {
      _promptCompleter?.completeError(StateError('Another prompt was initiated.'));
    }

    _isAwaitingPromptInput = true;
    _promptCompleter = Completer<String>();
    _currentPromptValidator = validator;
    _currentPromptAllowEmpty = allowEmpty;
    _activeInputPromptMessage = message; // Store the specific prompt message
    inputBuffer = defaultValue ?? '';

    _writeTemporaryPrompt(message); // This will set _currentPromptText to the temporary message
    terminal.write(inputBuffer);

    return _promptCompleter!.future.whenComplete(() {
      _currentPromptText = _mainCommandPrompt; // Reset visual prompt tracker to main prompt
      _activeInputPromptMessage = null; // Clear active message
    });
  }

  @override
  FutureOr<String> promptPassword(
      String message, {
        FutureOr<bool> Function(String)? validator,
      }) {
    // Note: Original file had 'home❯ ' as the default _currentPromptText,
    // this version now uses _mainCommandPrompt = '> ' as the default.
    // The reset in prompt's whenComplete was to 'home❯ '.
    // Changed to use _mainCommandPrompt for consistency if 'home❯ ' was an oversight.
    // If 'home❯ ' is specifically desired after a prompt, adjust _mainCommandPrompt or the reset logic.
    // For now, the UserInput.prompt still has its own reset.
    return prompt(message, allowEmpty: false, validator: validator);
  }

  @override
  Future<bool> confirm(String message, {bool defaultValue = false}) async {
    return await popupService.showConfirmationDialog(title: 'Confirm', message: message);
  }

  @override
  Future<String> select(
      String message, {
        required List<String> options,
        String? defaultValue,
      }) async {
    // The select method in the provided file uses .single,
    // assuming showOptionSelectionDialog returns a List<String>
    // and for single select, it's expected to have one item or handle empty.
    final result = await popupService.showOptionSelectionDialog(
        title: 'Select',
        message: message,
        options: options,
        defaultSelections: defaultValue == null ? null : [defaultValue],
        allowMultipleSelections: false,
    );
    if (result.isEmpty) {
        // Fallback logic as provided in the latest user file for select
        if (defaultValue != null && options.contains(defaultValue)) return defaultValue;
        if (options.isNotEmpty) return options.first;
        throw StateError('Selection cancelled and no valid fallback option.');
    }
    return result.single;
  }

  @override
  Future<List<String>> multiSelect(
      String message, {
        required List<String> options,
        List<String>? defaultSelection,
      }) async {
    return await popupService.showOptionSelectionDialog(
    title: 'Select multiple',
    message: message,
    options: options,
    defaultSelections: defaultSelection,
    allowMultipleSelections: true,
    );
  }

  @override
  Future<T> withSpinner<T>({
    required String inProgressMessage,
    String? completionMessage, // completionMessage from UserInput is used by GuiInput/caller
    required Future<T> Function() task,
  }) async {
    // The popupService.executeWithSpinner might show its own toast as per previous versions.
    // If UserInput's completionMessage is meant to be handled separately (e.g., by UserOutput),
    // then PopupService's executeWithSpinner shouldn't show a success toast.
    // Assuming PopupService.executeWithSpinner handles its own in-progress display and
    // the calling layer (like a GuiInput adapter) handles completionMessage.
    // The provided file calls popupService.executeWithSpinner which doesn't take completionMessage.
    return await popupService.executeWithSpinner(inProgressMessage: inProgressMessage, task: task);
  }

  @override
  Future<List<dynamic>?> promptForm(
      String formTitle,
      List<FormFieldDescriptor> fields,
      ) async {
    return await popupService.showDynamicFormDialog(
      title: formTitle,
      fields: fields,
    );
  }
}

