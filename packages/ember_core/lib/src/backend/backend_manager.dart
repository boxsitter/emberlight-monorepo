import 'package:ember_core/ember_core_backend.dart';

class BackendManager {
  static BackendInterface? _backend;

  /// Sets the backend implementation (called during initialization).
  static void setBackend(BackendInterface backend) {
    _backend = backend;
    print("Backend set to: ${backend.runtimeType}");
  }

  /// Gets the current backend instance.
  static BackendInterface get instance {
    if (_backend == null) {
      throw StateError('Backend not initialized. Call setBackend() first.');
    }
    return _backend!;
  }
}