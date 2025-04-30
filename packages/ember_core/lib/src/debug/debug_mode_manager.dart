import 'package:ember_core/ember_core_debug.dart';

/// Manages a global debugMode flag, defaulting to !kReleaseMode but
/// overrideable via URL query-param or in-app toggle and persisted.
class DebugModeManager {
  static const _overrideKey = 'debug_mode_override';
  /// true if in debug mode
  static bool _debugMode = false;
  static Verbosity _verbosity = Verbosity.excessive;

  static bool get debugMode => _debugMode;
  static Verbosity get verbosity => _verbosity;

  /// Call at app startup, before anything else.
  static Future<void> init(bool isReleaseMode) async {
    _debugMode = !isReleaseMode;
  }

  /// Override debug mode and persist (true or false).
  static Future<void> setDebugMode(bool value) async {
    _debugMode = value;
  }

  static void setVerbosity(Verbosity verbosity) {
    _verbosity = verbosity;
  }

  /// Clear any override and revert to default (!kReleaseMode).
  static Future<void> clearOverride(bool isReleaseMode) async {
    _debugMode = !isReleaseMode;
  }
}
