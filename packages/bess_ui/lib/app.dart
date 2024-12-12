import 'package:bessie/common/widgets/layouts/templates/site_layout.dart';
import 'package:bessie/routes/app_routes.dart';
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

      getPages: BessAppRoute.pages,
    );
  }
}

class ResponsiveDesignScreen extends StatelessWidget {
  const ResponsiveDesignScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const BessSiteTemplate(desktop: Desktop(), mobile: Mobile());
  }
}

class Desktop extends StatelessWidget {
  const Desktop({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch, // Ensure uniformity
      children: [
        // FIRST ROW
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: BessRoundedContainer(
                height: 450,
                backgroundColor: Colors.red.withValues(alpha: 0.5),
                child: const Center(child: Text('Widget 1')),
              ),
            ),
            const SizedBox(width: BessSizes.md),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  BessRoundedContainer(
                    height: 215,
                    backgroundColor: Colors.orange.withValues(alpha: 0.5),
                    child: const Center(child: Text('Widget 2')),
                  ),
                  const SizedBox(height: BessSizes.md),
                  Row(
                    children: [
                      Expanded(
                        child: BessRoundedContainer(
                          height: 215,
                          backgroundColor: Colors.amber.withValues(alpha: 0.5),
                          child: const Center(child: Text('Widget 3')),
                        ),
                      ),
                      const SizedBox(width: BessSizes.md),
                      Expanded(
                        child: BessRoundedContainer(
                          height: 215,
                          backgroundColor: Colors.green.withValues(alpha: 0.5),
                          child: const Center(child: Text('Widget 4')),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: BessSizes.md), // Space between rows

        // SECOND ROW
        Row(
          children: [
            Expanded(
              flex: 2,
              child: BessRoundedContainer(
                height: 220,
                backgroundColor: Colors.blue.withValues(alpha: 0.5),
                child: const Center(child: Text('Widget 5')),
              ),
            ),
            const SizedBox(width: BessSizes.md),
            Expanded(
              child: BessRoundedContainer(
                height: 220,
                backgroundColor: Colors.purple.withValues(alpha: 0.5),
                child: const Center(child: Text('Widget 6')),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class Tablet extends StatelessWidget {
  const Tablet({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 20,
      children: [
        // FIRST ROW
        Row (
          children: [
            Expanded(
              flex: 2,
              child: BessRoundedContainer(
                height: 450,
                backgroundColor: Colors.red.withValues(alpha: 0.5),
                child: const Center(child: Text('Widget 1')),
              ),
            ),

            const SizedBox(width: BessSizes.md),

            Expanded(
              flex: 2,
              child: Column(
                spacing: 20,
                children: [
                  BessRoundedContainer(
                    height: 215,
                    backgroundColor: Colors.orange.withValues(alpha: 0.5),
                    child: const Center(child: Text('Widget 2')),
                  ),

                  Row(
                    children: [
                      Expanded(
                        child: BessRoundedContainer(
                          height: 215,
                          backgroundColor: Colors.amber.withValues(alpha: 0.5),
                          child: const Center(child: Text('Widget 3')),
                        ),
                      ),
                      const SizedBox(width: BessSizes.md),
                      Expanded(
                        child: BessRoundedContainer(
                          height: 215,
                          backgroundColor: Colors.green.withValues(alpha: 0.5),
                          child: const Center(child: Text('Widget 4')),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),

        // SECOND ROW
        Column(
          spacing: 10,
          mainAxisSize: MainAxisSize.min,
          children: [
            BessRoundedContainer(
              height: 220,
              width: double.infinity,
              backgroundColor: Colors.blue.withValues(alpha: 0.2),
              child: const Center(child: Text('Widget 5')),
            ),
            const SizedBox(width: BessSizes.md),
            BessRoundedContainer(
                height: 220,
                width: double.infinity,
                backgroundColor: Colors.purple.withValues(alpha: 0.2),
                child: const Center(child: Text('Widget 6')),
            ),
          ],
        ),
      ],
    );
  }

}

class Mobile extends StatelessWidget {
  const Mobile({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        spacing: 20,
        children: [
              BessRoundedContainer(
              height: 200,
              backgroundColor: Colors.red.withValues(alpha: 0.5),
              child: const Center(child: Text('Widget 1')),
            ),
      
            BessRoundedContainer(
              height: 200,
              backgroundColor: Colors.orange.withValues(alpha: 0.5),
              child: const Center(child: Text('Widget 2')),
            ),
      
            BessRoundedContainer(
              height: 200,
              backgroundColor: Colors.amber.withValues(alpha: 0.5),
              child: const Center(child: Text('Widget 3')),
            ),
      
            BessRoundedContainer(
              height: 200,
              backgroundColor: Colors.green.withValues(alpha: 0.5),
              child: const Center(child: Text('Widget 4')),
            ),
            
            BessRoundedContainer(
              height: 200,
              backgroundColor: Colors.blue.withValues(alpha: 0.5),
              child: const Center(child: Text('Widget 5')),
            ),
            
            BessRoundedContainer(
              height: 200,
              backgroundColor: Colors.purple.withValues(alpha: 0.5),
              child: const Center(child: Text('Widget 6')),
            ),
        ],
      ),
    );
  }

}
