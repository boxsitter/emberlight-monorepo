### Emberlight Monorepo — Architecture and Quality Audit (Dart/Flutter)

Updated: YYYY-MM-DD
Scope: Entire monorepo under `projects/*` and `packages/*`

## Executive summary
- **Overall**: Solid foundation with clear separation between app (`projects/bessie`) and shared packages (`packages/*`). However, several systemic issues reduce reliability and maintainability: workspace config drift, inconsistent dependency versions, heavy global singletons via GetX, navigation side-effects in services, and type-safety holes in repositories.
- **Top risks**: Misconfigured monorepo (`melos.yaml`), Firebase/Sentry config in source, and a generic repository returning the wrong types.
- **Focus**: Fix workspace config and versions, secure configuration, refactor critical data/repo paths for type safety, and reduce global state coupling.

## High‑priority issues (fix first)
- **Melos workspace misconfigured**
  - `melos.yaml` looks for `apps/*`, but apps are in `projects/*`. Workspace commands will miss your apps.
  - File: `melos.yaml`
  - Action: Change to include `projects/*`.

- **Dependency version drift across packages**
  - Dart SDK constraints differ: `>=3.0.0`, `>=3.3.0`, `^3.7.0`.
  - Firebase packages vary between `ember_core`, `ember_fire`, and `bessie` (e.g., `firebase_core` and `cloud_firestore` versions), risking resolution/runtime conflicts.
  - Action: Unify SDK constraints and Firebase library versions across all packages.

- **Sentry DSN is hardcoded in source**
  - File: `projects/bessie/lib/main.dart`
  - Risk: Secrets in source + environment leakage.
  - Action: Move DSN to environment/build-time config; provide fallback via compile-time env or runtime config loader.

- **Type safety bug in `LiveDataRepository.watchCollection`**
  - File: `packages/ember_core/lib/src/repositories/live_data_repository.dart`
  - Issue: API returns `Stream<Map<String, T>>` but constructs `CoreObject` ignoring `T` and the provided mapper; leads to incorrect types at runtime.
  - Action: Require a `fromJson` mapper for collections and honor generic `T` consistently.

- **Navigation performed inside core services**
  - File: `packages/ember_core/lib/src/services/context_service.dart` (`Get.offAllNamed('/')` in `migrateContext`)
  - Issue: Tight UI coupling; breaks separation of concerns and complicates testing.
  - Action: Emit events/intents from services; let presentation/controllers perform navigation.

- **Excessive global singletons**
  - Many `Get.put(..., permanent: true)` registrations for services/controllers in `EmberCore.init/onLogin` and `BessUi`.
  - Issue: Global coupling, memory footprint growth, and complex lifecycles.
  - Action: Scope controllers to routes/screens; convert to constructor injection where possible; reduce `permanent: true` usage.

- **Mixing `Navigator` and GetX navigation**
  - Files: e.g., `packages/bess_ui/lib/src/common/widgets/form_inputs/dynamic_form_fields.dart` uses `Navigator`, while app uses `GetMaterialApp`.
  - Issue: Divergent navigation stacks can cause inconsistent back behavior.
  - Action: Standardize on one navigation API per app (prefer GetX if already adopted widely).

- **Importing another package’s `src`**
  - File: `packages/bess_ui/lib/bess_ui.dart` imports `ember_cli_utils/src/io/io_interfaces.dart`.
  - Issue: Breaks encapsulation and semver guarantees.
  - Action: Re-export public APIs from `ember_cli_utils/lib/ember_cli_utils.dart` and import from there.

- **Console `print` statements in production paths**
  - Files: multiple in `ember_core` and `bess_ui` (repositories/controllers).
  - Issue: Noisy logs, performance impact, and unstructured logging.
  - Action: Replace with a logging facade integrated with Sentry; disable verbose logs in release.

## Architectural observations and deviations
- **Project structure**
  - Clean separation: `projects/bessie` (Flutter app), `packages/*` (domain, Firebase, UI, CLI utils), `projects/emdev` (CLI).
  - Deviation: `melos.yaml` does not match folder layout, limiting tooling efficiency.

- **State management & DI**
  - Heavy use of GetX service locator via `Get.find/put` and global `permanent` instances; lifecycle cleanup is manual.
  - Deviation: Constructor injection and scoped providers (e.g., Riverpod or GetX route-bound) are more testable and modular.

- **App shell & routing**
  - `ShadApp.custom` wraps a nested `GetMaterialApp` via `appBuilder`. While functional, nesting app shells can cause theme/context quirks. Prefer a single root `MaterialApp`/`GetMaterialApp` and inject toasts via `builder`.
  - `BessieFlutterApp` relies on a statically fetched navigation observer (`Get.find`), which is brittle if used out of order.

- **Error handling & logging**
  - Good: `runZonedGuarded`, `FlutterError.onError`, `PlatformDispatcher.onError` wired to an app-specific `Debug` utility.
  - Gap: `print` statements remain in repositories/services; structured logging not consistently used.

- **Data layer patterns**
  - Repositories/services use `Get.find` within classes, reducing testability.
  - `LiveDataRepository` ignores type parameter in collection watcher; parsing errors logged via `print`.

- **Testing and analysis**
  - No tests detected for `bessie`/`bess_ui`; `emdev` includes `test` dependency but no tests present.
  - Lints: `package:lints/recommended.yaml` used; for Flutter packages, prefer `flutter_lints`. Some `ignore_for_file` present (acceptable in generated files).

- **Configuration & security**
  - Sentry DSN and emulator hosts/ports hardcoded; multiple TODOs indicate pending context/domain repair logic.

## Concrete bugs and risks
- **Type mismatch in collection streams**: `Map<String, T>` constructed with `CoreObject` instances.
- **Service-direct navigation**: `Get.offAllNamed` from core service risks route desync and violates layering.
- **Observer initialization ordering**: `BessieFlutterApp` assumes `BessUi.launchFlutterApp` ran; direct instantiation would fail.
- **Version mismatch**: Inconsistent Firebase versions/SKD constraints may cause build and runtime failures.

## Inefficiencies
- Global `permanent` instances increase memory and retain state across context changes.
- Unstructured logging (`print`) hampers observability and performance.
- Manual lifecycle management in `BessUi.onNewContext` is error-prone; prefer route/controller scoping.

## Deviations from Dart/Flutter best practices
- Importing another package’s `src` internals.
- Navigation from non-UI layers (services).
- Nested app shells instead of a single root app.
- Heavy service locator usage instead of DI via constructors/providers.

## Technical debt indicators
- Numerous `TODO/FIXME/HACK` comments in core services/models, including critical domain operations (context defaults, repairs, validation).
- Minimal tests and lack of CI gates for format/analyze/test.

## Recommended remediation plan

### Phase 1 — Workspace, security, and consistency
- [ ] Fix `melos.yaml` to include `projects/*` and `packages/*`.
- [ ] Unify Dart SDK constraints across all packages (e.g., `>=3.7.0 <4.0.0`).
- [ ] Align all Firebase package versions across `ember_core`, `ember_fire`, `bessie`.
- [ ] Remove Sentry DSN from source; load via env/build flags.
- [ ] Replace `print` with a logging facade (e.g., `logger`) and add Sentry breadcrumbs.
- [ ] Add root `analysis_options.yaml` and have packages include it; use `flutter_lints` for Flutter packages.

### Phase 2 — Data layer correctness & testability
- [ ] Refactor `LiveDataRepository.watchCollection` to require `fromJson` and return `T` consistently.
- [ ] Inject repositories/services via constructors; reduce `Get.find` in class bodies where possible.
- [ ] Add unit tests for repositories/services (parsing, error handling, emulator paths).

### Phase 3 — Navigation & lifecycle hygiene
- [ ] Remove navigation from services; expose events/signals and handle navigation in controllers/widgets.
- [ ] Standardize navigation API (pick GetX or Navigator 2.0); avoid mixing within the same flow.
- [ ] Reduce `permanent: true` registrations; scope controllers to routes; rely on GetX route lifecycle or Provider/Riverpod scopes.
- [ ] Flatten app shell: use one `GetMaterialApp`/`MaterialApp.router`; apply toasts/themes via the root `builder`.

### Phase 4 — CI, testing, and cleanup
- [ ] Add melos scripts for `bootstrap`, `format`, `analyze`, `test`, `publish`.
- [ ] Introduce widget/golden tests for critical screens (auth, rosters, session manager).
- [ ] Audit and resolve high-impact TODO/FIXME; track remaining via issues.

## Suggested code changes (at a glance)
- `melos.yaml`:
  - Update:
    ```yaml
    packages:
      - projects/*
      - packages/*
    ```
- `projects/bessie/lib/main.dart`:
  - Remove hardcoded DSN; read from `String.fromEnvironment('SENTRY_DSN')` and fail closed in release if missing.
- `packages/ember_core/lib/src/repositories/live_data_repository.dart`:
  - Change `watchCollection<T>` to accept `T Function(Map<String, dynamic>) fromJson` and use it; add error handling via logger.
- `packages/ember_core/lib/src/services/context_service.dart`:
  - Remove `Get.offAllNamed` from service; instead, notify UI via an event/callback.
- `packages/bess_ui/lib/bess_ui.dart`:
  - Replace `import 'package:ember_cli_utils/src/...';` with a public export from `ember_cli_utils`.

## Appendix — Notable files
- App entry & error handling: `projects/bessie/lib/main.dart`
- App shell & routing: `packages/bess_ui/lib/src/bessie_flutter_app.dart`
- UI bootstrap and controller lifecycle: `packages/bess_ui/lib/bess_ui.dart`
- Core init & global singletons: `packages/ember_core/lib/ember_core.dart`
- Context service (navigation issue): `packages/ember_core/lib/src/services/context_service.dart`
- Live data repository (type bug): `packages/ember_core/lib/src/repositories/live_data_repository.dart`
- Melos workspace config: `melos.yaml`

---
If you want, I can apply Phase 1 changes (melos fix, dependency alignment, Sentry DSN removal, logging replacement) in a single branch and open a PR.