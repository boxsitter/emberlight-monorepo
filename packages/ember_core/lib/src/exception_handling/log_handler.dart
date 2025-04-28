import 'dart:async';

import 'package:ember_core/ember_core_frontend.dart';
import 'package:ember_core/src/exception_handling/logable.dart';

import '../../ember_core_debug.dart';
import 'ember_exception.dart';
import 'ember_info.dart';


class LogHandler {
  /* ---------- singleton boilerplate ---------- */
  LogHandler._internal();
  static final LogHandler _singleton = LogHandler._internal();
  static LogHandler get instance => _singleton;

  /* ---------- public config / toggles ---------- */

  static bool debugMode = DebugModeManager.debugMode;

  /// Max events kept in memory. Overridden early if you need a larger ring.
  int maxEntries = 400;

  /* ---------- in-memory ring buffer ---------- */
  final List<Logable> _events = <Logable>[];

  /// Snapshot of the current buffer (useful for UI viewers).
  /// No reactive magic – poll or attach [onEvent] listener.
  List<Logable> get events => List.unmodifiable(_events);

  /* ---------- broadcast for widgets / dev console ---------- */
  final StreamController<Logable> _controller = StreamController<Logable>.broadcast();
  Stream<Logable> get onEvent => _controller.stream;

  /* ======================================================================= */
  /*  Public API                                                             */
  /* ======================================================================= */

  void handleException(Object e, [StackTrace? stackTrace]) {
    EmberException exception = e.toEmberException();
    _push(exception);
    _devPrint(exception, stackTrace);
    FrontendManager.instance.displayError(title: exception.userMessage, message: exception.userMessage);

    // Sentry forwarding
    if (exception.severity == ErrorSeverity.error || exception.severity == ErrorSeverity.critical) {
      Future.microtask(() {
        if (stackTrace != null) Error.throwWithStackTrace(exception, stackTrace);
        throw exception;
      });
    }
  }

  void handleInfo(EmberInfo info) {
    _push(info);
    _devPrint(info);
    if (info.userTitle != null) {
      FrontendManager.instance.displayInfo(title: info.userTitle, message: info.userMessage);
    }
  }

  /* ======================================================================= */
  /*  Convenience helpers                                                    */
  /* ======================================================================= */

  /// Wrap arbitrary code so *any* thrown object ends up in the log.
  /// Usage: `await EmberLog.instance.guard(() { dangerousStuff(); });`
  Future<T?> guard<T>(FutureOr<T> Function() action) async {
    try {
      return await Future.sync(action);
    } catch (e, st) {
      handleException(e.toEmberException(), st);
      return null;
    }
  }

  /* ======================================================================= */
  /*  internals                                                              */
  /* ======================================================================= */

  void _push(Logable entry) {
    if (_events.length >= maxEntries) _events.removeAt(0);
    _events.add(entry);
    _controller.add(entry); // notify listeners
  }

  void _devPrint(Logable entry, [StackTrace? st]) {
    if (debugMode) {
      print(entry); // TODO: Pretty print this with colors
      if (st != null) print(st);
    }
  }

  /* ------------------------------------------------------------------ */
  /*  Disposal – rarely needed in a singleton but handy for tests       */
  /* ------------------------------------------------------------------ */
  void dispose() => _controller.close();
}
