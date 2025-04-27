import 'frontend_interface.dart';

class FrontendManager {
  static CoreFrontend? _frontend;

  /// Sets the frontend implementation (called during initialization).
  static void setFrontend(CoreFrontend frontend) {
    _frontend = frontend;
    print("Frontend set to: ${frontend.runtimeType}");
  }

  /// Gets the current frontend instance.
  static CoreFrontend get instance {
    if (_frontend == null) {
      throw StateError('Frontend not initialized. Call setFrontend() first.');
    }
    return _frontend!;
  }
}