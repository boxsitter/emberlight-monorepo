import 'dart:async';

import 'package:ember_core/ember_core_frontend.dart';

import '../../ember_core_debug.dart';
import 'logable.dart';


class Debug {
  Debug._internal();
  static final Debug _singleton = Debug._internal();
  static Debug get instance => _singleton;

  // State
  bool _debugMode = false;
  Verbosity _verbosity = Verbosity.excessive;

  static bool get debugMode => instance._debugMode;
  static Verbosity get verbosity => instance._verbosity;

  static Future<void> setDebugMode(bool value) async {
    instance._debugMode = value;
  }

  static void setVerbosity(Verbosity verbosity) {
    instance._verbosity = verbosity;
  }

  int maxEntries = 400;

  final List<Logable> _events = <Logable>[];

  List<Logable> get events => List.unmodifiable(_events);

  final StreamController<Logable> _controller = StreamController<Logable>.broadcast();
  Stream<Logable> get onEvent => _controller.stream;

  static void handle(Object e, [StackTrace? stackTrace]) {
    instance._handle(e, stackTrace);
  }

  void _handle(Object e, [StackTrace? stackTrace]) {
    if (e is EmberInfo) {
      _handleInfo(e);
    } else {
      _handleException(e, stackTrace);
    }
  }

  void _handleException(Object e, [StackTrace? stackTrace]) {
    final EmberException exception = e.toEmberException(stackTrace);
    _push(exception);
    if (DebugModeManager.debugMode) {
      _devPrint(exception, stackTrace);
    }
    if (exception.userMessage != null) {
      FrontendManager.instance.displayError(
        title: exception.logType.userString,
        message: exception.userMessage,
      );
    }

    if (DebugModeManager.debugMode) {
      if (!exception.logType.eatMe) {
        throw Unhandleable(
          logType: exception.logType,
          devMessage: exception.devMessage,
          module: exception.module,
          metadata: exception.metadata,
        );
      } else {
        return;
      }
    }

    if (!exception.logType.eatMe) {
      Future.microtask(() {
        if (stackTrace != null) {
          Error.throwWithStackTrace(exception, stackTrace);
        } else {
          throw exception;
        }
      });
    }
  }

  void _handleInfo(EmberInfo info) {
    _push(info);
    if (DebugModeManager.debugMode) {
      if (info.verbosity.level <= DebugModeManager.verbosity.level) {
        _devPrint(info);
      }
    }
    if (info.userTitle != null) {
      FrontendManager.instance.displayInfo(title: info.userTitle, message: info.userMessage);
    }
  }

  static void logInfo(String devMessage, {Verbosity? verbosity, String? userMessage, Map<String, String>? metadata}) {
    instance._logInfo(devMessage, verbosity: verbosity, userMessage: userMessage, metadata: metadata);
  }

  static void logSuccess(String devMessage, {Verbosity? verbosity, String? userMessage, Map<String, String>? metadata}) {
    instance._logSuccess(devMessage, verbosity: verbosity, userMessage: userMessage, metadata: metadata);
  }

  static void logWarning(String devMessage, {Verbosity? verbosity, String? userMessage, Map<String, String>? metadata}) {
    instance._logWarning(devMessage, verbosity: verbosity, userMessage: userMessage, metadata: metadata);
  }

  static void logError(Object e, [StackTrace? stackTrace]) {
    handle(e, stackTrace);
  }

  static void logException(EmberException e) {
    instance._handleException(e);
  }

  void _logInfo(String devMessage, {
    Verbosity? verbosity,
    String? userMessage,
    Map<String, String>? metadata,
  }) {
    handle(Info(devMessage, verbosity: verbosity, userMessage: userMessage, metadata: metadata));
  }

  void _logSuccess( String devMessage, {
    Verbosity? verbosity,
    String? userMessage,
    Map<String, String>? metadata,
  }) {
    handle(Success(devMessage, verbosity: verbosity, userMessage: userMessage, metadata: metadata));
  }

  void _logWarning( String devMessage, {
    Verbosity? verbosity,
    String? userMessage,
    Map<String, String>? metadata,
  }) {
    handle(Warning(devMessage, verbosity: verbosity, userMessage: userMessage, metadata: metadata));
  }

  Future<T?> guard<T>(FutureOr<T> Function() action) async {
    try {
      return await Future.sync(action);
    } catch (e, st) {
      _handleException(e.toEmberException(st), st);
      return null;
    }
  }

  void _push(Logable entry) {
    if (_events.length >= maxEntries) _events.removeAt(0);
    _events.add(entry);
    _controller.add(entry);
  }

  void _devPrint(Logable entry, [StackTrace? stackTrace]) {
    print((entry.toStringColorful(stackTrace)).trim());
  }

  void dispose() => _controller.close();
}
