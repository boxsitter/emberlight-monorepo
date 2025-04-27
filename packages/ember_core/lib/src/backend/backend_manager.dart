import 'package:ember_core/ember_core_backend.dart';

class BackendManager {
  static CoreBackend? _backend;

  /// Sets the backend implementation (called during initialization).
  static void setBackend(CoreBackend backend) {
    _backend = backend;
    print("Backend set to: ${backend.runtimeType}");
  }

  /// Gets the current backend instance.
  static CoreBackend get instance {
    if (_backend == null) {
      throw StateError('Backend not initialized. Call setBackend() first.');
    }
    return _backend!;
  }
}