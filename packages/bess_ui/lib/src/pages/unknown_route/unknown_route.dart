import 'package:bess_ui/src/common/constants/sizes.dart';
import 'package:bess_ui/src/common/styles/text_styles.dart';
import 'package:bess_ui/src/pages/session_manager/session_manager_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../common/widgets/buttons/inkwell_button.dart';
import '../../common/widgets/layouts/templates/site_layout.dart';

class UnknownRoute extends StatelessWidget {
  const UnknownRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('Woah there partner, the page you tried to access doesn\'t exist!', style: BessTextStyles.lightHeader, textAlign: TextAlign.center,)),
    );
  }
}