import 'package:bess_ui/src/pages/authentication/view/forgot_password/widgets/header_and_form.dart';
import 'package:flutter/material.dart';

import '../../../../common/constants//sizes.dart';
import '../../../../common/widgets/layouts/templates/center_box.dart';
import '../../../../common/widgets/layouts/templates/site_layout.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key = const ValueKey('HomeScreen')});

  @override
  Widget build(BuildContext context) {
    return const BessSiteTemplate(
        useLayout: false,
        desktop: ForgotPasswordScreenDesktopTablet(),
        mobile: ForgotPasswordScreenMobile());
  }
}

class ForgotPasswordScreenDesktopTablet extends StatelessWidget {
  const ForgotPasswordScreenDesktopTablet({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const BessCenterBox(
      child: BessHeaderAndForm(),
    );
  }
}

class ForgotPasswordScreenMobile extends StatelessWidget {
  const ForgotPasswordScreenMobile({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(BessSizes.defaultSpace),
          child: BessHeaderAndForm(),
        ),
      ),
    );
  }
}
