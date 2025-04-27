import 'package:bessie/common/constants/sizes.dart';
import 'package:bessie/pages/home/widgets/home_screen_nav_card.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../common/styles/text_styles.dart';
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome To Bessie!',
          style: BessTextStyles.lightTitle,
          overflow: TextOverflow.clip,
          maxLines: 1,
        ),

        const SizedBox(height: BessSizes.spaceBtwItems),

        Row(
          children: [
            const Expanded(
              child: HomeScreenNavCard(
                  title: 'Session Roster',
                  icon: LucideIcons.layoutPanelLeft,
                  description: 'View and manage the master roster of all participants assigned to the selected session'
              ),
            ),

            const SizedBox(width: BessSizes.md),

            const Expanded(
              child: HomeScreenNavCard(
                  title: 'Console',
                  icon: LucideIcons.squareTerminal,
                  description: 'Developer terminal with tools for testing and debugging'
              ),
            ),

            const SizedBox(width: BessSizes.md),

            TextButton(
              onPressed: () => throw Exception(),
              child: const Text("Throw Test Exception"),
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