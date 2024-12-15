import 'package:bessie/common/widgets/layouts/templates/center_box.dart';
import 'package:bessie/features.authentication/screens/reset_password/widgets/reset_password_widget.dart';
import 'package:bessie/routes/routes.dart';
import 'package:bessie/utils/constants/image_strings.dart';
import 'package:bessie/utils/constants/sizes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../common/widgets/layouts/templates/site_layout.dart';
import '../../../utils/constants/text_strings.dart';

class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({super.key = const ValueKey('HomeScreen')});

  @override
  Widget build(BuildContext context) {
    return const BessSiteTemplate(useLayout: false, desktop: ResetPasswordScreenDesktopTablet(), mobile: ResetPasswordScreenMobile());
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