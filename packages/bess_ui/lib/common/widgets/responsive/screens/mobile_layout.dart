import 'package:bessie/common/widgets/layouts/sidebars/sidebar.dart';
import 'package:bessie/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import '../../layouts/headers/header.dart';

class MobileLayout extends StatelessWidget {
  MobileLayout({super.key, this.body});

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
      )
    );
  }
}