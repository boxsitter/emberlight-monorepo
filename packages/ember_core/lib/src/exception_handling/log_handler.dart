import 'dart:async';

import 'package:ember_core/ember_core_frontend.dart';
import 'package:ember_core/src/exception_handling/logable.dart';

import '../../ember_core_debug.dart';
import 'ember_exception.dart';
import 'ember_info.dart';


class LogHandler {
  LogHandler._internal();
  static final LogHandler _singleton = LogHandler._internal();
  static LogHandler get instance => _singleton;

  int maxEntries = 400;

  final List<Logable> _events = <Logable>[];

  List<Logable> get events => List.unmodifiable(_events);

  final StreamController<Logable> _controller = StreamController<Logable>.broadcast();
  Stream<Logable> get onEvent => _controller.stream;


  void handleException(Object e, [StackTrace? stackTrace]) {
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
        throw exception;
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

  void handleInfo(EmberInfo info) {
    _push(info);
    if (DebugModeManager.debugMode) {
      _devPrint(info);
    }
    if (info.userTitle != null) {
      FrontendManager.instance.displayInfo(title: info.userTitle, message: info.userMessage);
    }
  }

  void quickLog(String message) {
    handleInfo(QuickLog(message));
  }

  Future<T?> guard<T>(FutureOr<T> Function() action) async {
    try {
      return await Future.sync(action);
    } catch (e, st) {
      handleException(e.toEmberException(st), st);
      return null;
    }
  }

  void _push(Logable entry) {
    if (_events.length >= maxEntries) _events.removeAt(0);
    _events.add(entry);
    _controller.add(entry);
  }

  void _devPrint(Logable entry, [StackTrace? stackTrace]) {
    print(entry.toStringColorful(stackTrace));
  }

  void dispose() => _controller.close();
}
