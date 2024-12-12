import 'package:bessie/common/widgets/layouts/headers/header.dart';
import 'package:flutter/material.dart';
import '../../../../utils/constants/sizes.dart';

class TabletLayout extends StatelessWidget {
  const TabletLayout({super.key, this.body});

  final Widget? body;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const Drawer(),
      appBar: const BessHeader(),
      body: Padding(
        padding: const EdgeInsets.all(BessSizes.lg),
        child: body ?? const SizedBox(),
      )
    );
  }
}