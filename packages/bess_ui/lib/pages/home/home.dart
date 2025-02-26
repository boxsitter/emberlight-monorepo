import 'package:bessie/common/constants/sizes.dart';
import 'package:bessie/common/widgets/text/light_title.dart';
import 'package:bessie/pages/home/widgets/home_screen_nav_card.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../common/widgets/layouts/templates/site_layout.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key = const ValueKey('HomeScreen')});

  @override
  Widget build(BuildContext context) {
    return const BessSiteTemplate(desktop: HomeScreenDesktop());
  }
}

class HomeScreenDesktop extends StatelessWidget {
  const HomeScreenDesktop({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LightTitle(text: "Welcome To Bessie"),

        SizedBox(height: BessSizes.spaceBtwItems),

        Row(
          children: [
            Expanded(
              child: HomeScreenNavCard(
                  title: 'Session Roster',
                  icon: Iconsax.note_21,
                  description: 'View and manage the master roster of all participants assigned to the selected session'
              ),
            ),

            SizedBox(width: BessSizes.md),

            Expanded(
              child: HomeScreenNavCard(
                  title: 'Console',
                  icon: Iconsax.code,
                  description: 'Developer terminal with tools for testing and debugging'
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// class HomeScreenMobile extends StatelessWidget {
//   const HomeScreenMobile({
//     super.key,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return
//   }
//
// }