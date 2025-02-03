import 'package:bessie/common/widgets/layouts/templates/center_box.dart';
import 'package:bessie/features/authentication/view/reset_password/widgets/reset_password_widget.dart';
import 'package:flutter/material.dart';

import '../../../../common/constants//sizes.dart';
import '../../../../common/widgets/layouts/templates/site_layout.dart';

class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({super.key = const ValueKey('HomeScreen')});

  @override
  Widget build(BuildContext context) {
    return const BessSiteTemplate(
        useLayout: false,
        desktop: ResetPasswordScreenDesktopTablet(),
        mobile: ResetPasswordScreenMobile());
  }
}

class ResetPasswordScreenDesktopTablet extends StatelessWidget {
  const ResetPasswordScreenDesktopTablet({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const BessCenterBox(
      child: ResetPasswordWidget(),
    );
  }
}

class ResetPasswordScreenMobile extends StatelessWidget {
  const ResetPasswordScreenMobile({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(BessSizes.defaultSpace),
          child: ResetPasswordWidget(),
        ),
      ),
    );
  }
}
