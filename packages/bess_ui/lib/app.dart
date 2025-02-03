import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'common/routes/app_routes.dart';
import 'common/routes/route_observer.dart';
import 'common/routes/routes.dart';
import 'common/constants//text_strings.dart';
import 'common/utils/device/web_material_scroll.dart';
import 'common/utils/theme/theme.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: BessTexts.appName,
      themeMode: ThemeMode.light,
      theme: BessieAppTheme.lightTheme,
      darkTheme: BessieAppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      scrollBehavior: MyCustomScrollBehavior(),
      initialRoute: BessRoutes.responsiveDesignExample,
      unknownRoute: GetPage(
          name: '/page-not-found',
          page: () => const Scaffold(
              body: Center(
                  child:
                      Text('Woah there partner, that page doesn\'t exist!')))),
      navigatorObservers: [RouteObservers()],
      defaultTransition: Transition.noTransition,
      getPages: BessAppRoute.pages,
    );
  }
}
