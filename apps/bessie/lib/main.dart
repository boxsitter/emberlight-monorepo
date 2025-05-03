import 'dart:async';
import 'dart:io';

import 'package:bess_ui/bessie_app.dart';
import 'package:bess_ui/bessie_frontend.dart';
import 'package:bess_ui/common/services/popup_service.dart';
import 'package:bess_ui/common/widgets/layouts/sidebars/sidebar_controller.dart';
import 'package:bess_ui/common/widgets/roster_table/controllers/roster_table_controller.dart';
import 'package:bess_ui/pages/activity_preferences/controllers/activity_preferences_controller.dart';
import 'package:bess_ui/pages/console/controller/console_controller.dart';
import 'package:bess_ui/pages/schedule/schedule_page_controller.dart';
import 'package:bess_ui/pages/session_manager/session_manager_controller.dart';
import 'package:ember_core/ember_core.dart';
import 'package:ember_core/ember_core_debug.dart';
import 'package:ember_fire/ember_fire.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:window_manager/window_manager.dart';

/// Entry point of Flutter App
Future<void> main() async {
  Debug.init(kReleaseMode);
  Debug.handleInfo(Debug.getDebugStateInfo());

  if (!Debug.enableSentry) {
    await runZonedGuarded(() async {
      await initializeApp();
    }, (Object error, StackTrace stack) {
      if (error is! EmberException || !error.isHandled) {
        Debug.parseException(error, stack);
        Future<void>.microtask(() {
          Zone.current.parent?.handleUncaughtError(error, stack);
        });
      }
    });
  } else {
    await SentryFlutter.init(
      (options) {
        options.dsn = 'https://81a155539d2eb46d3a99b6fd0779bf30@o4508969385656320.ingest.us.sentry.io/4508969397190657';
        options.sendDefaultPii = true;
        options.tracesSampleRate = 1.0;
      },
      appRunner: initializeApp,
    );
  }
}

Future<void> initializeApp() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  FlutterError.onError = (FlutterErrorDetails details) {
    if (details.exception is! EmberException || !(details.exception as EmberException).isHandled) {
      Debug.parseException(details.exception, details.stack);
    }
  };
  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    if (error is! EmberException || !error.isHandled) {
      Debug.parseException(error, stack);
      return true;
    }
    return false;
  };
  try {
    await FirebaseStarter.initialize();
  } catch (e) {
    throw Exception('Firebase not initialized!');
  }

  Get.put(PopupService());
  EmberCore.initializeComponents(EmberFire(), BessieFrontend());

  if (AppConfig.recoveryMode) {
    await EmberCore.recoverEmberCore();
  } else {
    EmberCore.initializeEmberCore();
  }

  // Initialize window manager if on desktop
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    await windowManager.ensureInitialized();
    WindowOptions windowOptions = const WindowOptions(
      title: 'Bessie',
      minimumSize: Size(AppConfig.minWindowWidth, AppConfig.minWindowHeight),
    );
    await windowManager.waitUntilReadyToShow(windowOptions);
    await windowManager.show();
    await windowManager.focus();
  }
  // TODO: Find the actual minimum screen dimensions and enforce slightly larger minimum dimensions on all platforms
  // TODO: Figure out how the upscaling on mobile factors in to this

  Get.put(ConsoleController(), permanent: true);

  Get.put(SidebarController(), permanent: true);
  Get.put(RosterTableController(), permanent: true);
  Get.put(SessionManagerController(), permanent: true);
  Get.put(ActivityPreferencesController(), permanent: true);
  Get.put(SchedulePageController(), permanent: true);

  FlutterNativeSplash.remove();
  runApp(const BessieApp());
}

class AppConfig {
  static bool recoveryMode = false;

  static const double minWindowWidth = 640;
  static const double minWindowHeight = 480;

  static const Transition defaultTransitionAnimation = Transition.noTransition;
}
