import 'package:bessie/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import '../../layouts/headers/header.dart';

class MobileLayout extends StatelessWidget {
  const MobileLayout({super.key, this.body});

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