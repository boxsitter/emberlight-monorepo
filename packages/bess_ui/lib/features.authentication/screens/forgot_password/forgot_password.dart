import 'package:bessie/features.authentication/screens/forgot_password/widgets/header_and_form.dart';
import 'package:bessie/routes/routes.dart';
import 'package:bessie/utils/constants/sizes.dart';
import 'package:bessie/utils/constants/text_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../common/widgets/layouts/templates/center_box.dart';
import '../../../common/widgets/layouts/templates/site_layout.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key = const ValueKey('HomeScreen')});

  @override
  Widget build(BuildContext context) {
    return const BessSiteTemplate(useLayout: false, desktop: ForgotPasswordScreenDesktopTablet(), mobile: ForgotPasswordScreenMobile());
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