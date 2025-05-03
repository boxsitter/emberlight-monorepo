import 'package:bessie/common/widgets/layouts/templates/center_box.dart';
import 'package:bessie/pages/authentication/view/login/widgets/login_form.dart';
import 'package:bessie/pages/authentication/view/login/widgets/login_header.dart';
import 'package:flutter/material.dart';

import '../../../../common/constants//sizes.dart';
import '../../../../common/widgets/layouts/templates/site_layout.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const BessSiteTemplate(
        useLayout: false,
        desktop: LoginScreenDesktopTablet(),
        mobile: LoginScreenMobile());
  }
}

class LoginScreenDesktopTablet extends StatelessWidget {
  const LoginScreenDesktopTablet({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const BessCenterBox(
      child: Column(
        children: [
          // Header
          BessLoginHeader(),
          // Form
          BessLoginForm(),
        ],
      ),
    );
  }
}

class LoginScreenMobile extends StatelessWidget {
  const LoginScreenMobile({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(BessSizes.defaultSpace),
            child: Column(
              children: [
                // Header
                BessLoginHeader(),
                // Form
                BessLoginForm(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
