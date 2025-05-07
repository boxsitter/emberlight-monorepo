import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'common/constants/text_strings.dart';
import 'common/routes/route_observer.dart';
import 'common/routes/routes.dart';
import 'common/theme/shad_theme.dart';
import 'common/theme/theme.dart';
import 'common/utils/device/web_material_scroll.dart';

class BessieFlutterApp extends StatelessWidget {
  const BessieFlutterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ShadApp.custom(
      themeMode: ThemeMode.light,
      theme: BessShadTheme.shadThemeData,
      appBuilder: (context, shadTheme) {
        return GetMaterialApp(
          title: BessTexts.appName,
          themeMode: ThemeMode.light,
          theme: BessieAppTheme.theme,
          //darkTheme: BessieAppTheme.darkTheme,
          debugShowCheckedModeBanner: false,
          scrollBehavior: MyCustomScrollBehavior(),
          initialRoute: BessRoutes.home,
          unknownRoute: GetPage(
            name: '/page-not-found',
            page: () => const Scaffold(
              body: Center(
                child: Text("Woah there partner, that page doesn't exist!"),
              ),
            ),
          ),
          navigatorObservers: [RouteObservers()],
          defaultTransition: Transition.noTransition,
          getPages: BessRoutes.pages,
          builder: (context, child) {
            return ShadSonner(visibleToastsAmount: 3, child: child!);
          },
        );
      },
    );
  }
}
