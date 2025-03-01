import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'common/routes/app_routes.dart';
import 'common/routes/route_observer.dart';
import 'common/routes/routes.dart';
import 'common/constants//text_strings.dart';
import 'common/theme/theme.dart';
import 'common/utils/device/web_material_scroll.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return ShadApp.custom(
      appBuilder: (context, shadTheme) {
        // Merge the shadcn UI theme with your custom theme by overriding specific fields.
        final mergedTheme = shadTheme.copyWith(
          brightness: BessieAppTheme.theme.brightness,
          primaryColor: BessieAppTheme.theme.primaryColor,
          scaffoldBackgroundColor: BessieAppTheme.theme.scaffoldBackgroundColor,
          // Merge the text themes so that your font settings (like 'Inter') are applied.
          textTheme: shadTheme.textTheme.merge(BessieAppTheme.theme.textTheme),
          // You can also override additional properties if needed.
        );
        return GetMaterialApp(
          title: BessTexts.appName,
          themeMode: ThemeMode.light,
          theme: mergedTheme,
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
          getPages: BessAppRoute.pages,
          builder: (context, child) {
            // Wrap with ShadToaster to support shadcn‑ui toast notifications (if you use them)
            return ShadToaster(child: child!);
          },
        );
      },
    );
  }
}
