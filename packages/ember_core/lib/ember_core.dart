import 'package:ember_core/ember_core_backend.dart';

/// Ember Core - The core logic and business layer for Emberlight software
///
/// This package contains the core business logic, models models, and service interfaces
/// for Emberlight software. It is completely platform-agnostic and does not directly
/// depend on any frontend or backend specific code. All backend operations are
/// abstracted within the backend repository layer.
///
/// Usage:
/// Import this package in your UI layer to access business logic and service methods.
void initializeEmberCore (BackendInterface backendInterface) {
  BackendManager.setBackend(backendInterface);
}