import 'package:bessie/common/widgets/layouts/templates/site_layout.dart';
import 'package:bessie/routes/app_routes.dart';
import 'package:bessie/routes/route_observer.dart';
import 'package:bessie/routes/routes.dart';
import 'package:bessie/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'common/widgets/containers/rounded_container.dart';
import 'utils/constants/text_strings.dart';
import 'utils/device/web_material_scroll.dart';
import 'utils/theme/theme.dart';

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
      unknownRoute: GetPage(name: '/page-not-found', page: () => const Scaffold(body: Center(child: Text('Woah there partner, that page doesn\'t exist!')))),
      navigatorObservers: [RouteObservers()],
      //defaultTransition: Transition.noTransition,

      getPages: BessAppRoute.pages,
    );
  }
}
