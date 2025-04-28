import 'package:shared_preferences/shared_preferences.dart';

/// Manages a global debugMode flag, defaulting to !kReleaseMode but
/// overrideable via URL query-param or in-app toggle and persisted.
class DebugModeManager {
  static const _overrideKey = 'debug_mode_override';
  /// true if in debug mode
  static late bool debugMode;

  /// Call at app startup, before anything else.
  static Future<void> init(bool isReleaseMode) async {
    final prefs = await SharedPreferences.getInstance();
    final override = prefs.getBool(_overrideKey);
    if (override != null) {
      debugMode = override;
    } else {
      debugMode = !isReleaseMode;
    }
  }

  /// Override debug mode and persist (true or false).
  static Future<void> setDebugMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value) {
      await prefs.setBool(_overrideKey, true);
    } else {
      await prefs.setBool(_overrideKey, false);
    }
    debugMode = value;
    // you might want to notify listeners here if you build UI around it
  }

  /// Clear any override and revert to default (!kReleaseMode).
  static Future<void> clearOverride(bool isReleaseMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_overrideKey);
    debugMode = !isReleaseMode;
  }
}
