import 'package:flutter/material.dart';

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
    return const Center(child: Text('Home Screen'));
  }
}

// class HomeScreenTablet extends StatelessWidget {
//   const HomeScreenTablet({
//     super.key,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return
//   }
// }

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