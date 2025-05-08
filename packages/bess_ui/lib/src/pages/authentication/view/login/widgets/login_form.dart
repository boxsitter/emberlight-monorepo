import 'package:bess_ui/src/common/utils/validators/validation.dart';
import 'package:bess_ui/src/pages/authentication/authentication_controller.dart';
import 'package:ember_core/ember_core_debug.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../../common/constants//sizes.dart';
import '../../../../../common/constants//text_strings.dart';

class BessLoginForm extends StatelessWidget {
  const BessLoginForm({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    AuthenticationController controller = Get.find<AuthenticationController>();
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUnfocus,
      child: Padding(
          padding:
              const EdgeInsets.symmetric(vertical: BessSizes.spaceBtwSections),
          child: Column(
            children: [
              /// Email
              TextFormField(
                spellCheckConfiguration: SpellCheckConfiguration.disabled(),
                validator: (value) => BessValidator.validateEmail(value),
                controller: controller.emailController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(LucideIcons.messageCircleMore),
                  labelText: BessTexts.email,
                ),
              ),

              const SizedBox(height: BessSizes.spaceBtwInputFields),

              /// Password
              TextFormField(
                spellCheckConfiguration: SpellCheckConfiguration.disabled(),
                obscureText: true,
                obscuringCharacter: '•',
                validator: (value) => BessValidator.validatePassword(value),
                controller: controller.passwordController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(LucideIcons.lock),
                  labelText: BessTexts.password,
                  suffixIcon: IconButton(
                      onPressed: () {},
                      icon: const Icon(LucideIcons.eyeOff)
                  ),
                ),
              ),
              const SizedBox(height: BessSizes.spaceBtwInputFields / 2),

              /// Remember me & forgot password
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Checkbox(value: true, onChanged: (value) {}),
                      const Text(BessTexts.rememberMe),
                    ],
                  ),

                  // /// Forgot password
                  // TextButton(
                  //     onPressed: () => Get.toNamed(BessRoutes.forgotPassword),
                  //     child: const Text(BessTexts.forgotPassword)
                  // )
                ],
              ),
              const SizedBox(height: BessSizes.spaceBtwSections),

              /// Sign in button
              /// TODO: replace button with my custom loader action button
              SizedBox(
                width: double.infinity,
                child: Obx(() => ElevatedButton( // Obx to react to isLoading changes
                  onPressed: controller.isLoading.value ? null : () {
                    if (_formKey.currentState?.validate() ?? false) {
                      // If form is valid, attempt login
                      controller.loginUser();
                    } else {
                      Debug.logWarning('Form validation failed');
                    }
                  },
                  child: controller.isLoading.value ? const SizedBox( // Show a loader inside the button
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white, // Or your theme's button text color
                      strokeWidth: 2.0,
                    ),
                  )
                      : const Text(BessTexts.signIn),
                )),
              ),

              // const SizedBox(height: BessSizes.spaceBtwInputFields / 2),
              //
              // Text(BessTexts.or, style: Theme.of(context).textTheme.bodyMedium),
              //
              // const SizedBox(height: BessSizes.spaceBtwInputFields / 2),

              // /// Join button
              // SizedBox(
              //   width: double.infinity,
              //   child: ElevatedButton(
              //       onPressed: () {}, child: const Text(BessTexts.joinCamp)),
              // )
            ],
          )),
    );
  }
}
