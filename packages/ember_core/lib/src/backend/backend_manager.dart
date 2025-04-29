import 'package:ember_core/ember_core_backend.dart';

import '../../ember_core_debug.dart';

class BackendManager {
  static CoreBackend? _backend;

  /// Sets the backend implementation (called during initialization).
  static void setBackend(CoreBackend backend) {
    _backend = backend;
    Debug.logInfo("Backend set to: ${backend.backendName}");
  }

  /// Gets the current backend instance.
  static CoreBackend get instance {
    if (_backend == null) {
      throw CoreUninitializedError('Backend not initialized. Call setBackend() first');
    }
    return _backend!;
  }
}