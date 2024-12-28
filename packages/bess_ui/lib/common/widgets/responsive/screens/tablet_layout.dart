import 'package:bessie/common/widgets/layouts/headers/header.dart';
import 'package:flutter/material.dart';

import '../../../utils/constants/sizes.dart';
import '../../layouts/sidebars/sidebar.dart';

class TabletLayout extends StatelessWidget {
  TabletLayout({super.key, this.body});

  final Widget? body;

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: scaffoldKey,
        drawer: const BessSidebar(),
        appBar: BessHeader(scaffoldKey: scaffoldKey),
        body: Padding(
          padding: const EdgeInsets.all(BessSizes.lg),
          child: body ?? const SizedBox(),
        ));
  }
}
