import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../routes/routes.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/constants/text_strings.dart';

class BessLoginForm extends StatelessWidget {
  const BessLoginForm({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Padding(padding: const EdgeInsets.symmetric(vertical: BessSizes.spaceBtwSections),
          child: Column(
            children: [
              /// Email
              TextFormField(
                decoration: const InputDecoration(
                  prefixIcon: Icon(Iconsax.sms),
                  labelText: BessTexts.email,
                ),
              ),

              const SizedBox(height: BessSizes.spaceBtwInputFields),

              /// Password
              TextFormField(
                decoration: InputDecoration(
                  prefixIcon: const Icon(Iconsax.password_check),
                  labelText: BessTexts.password,
                  suffixIcon: IconButton(onPressed: () {}, icon: const Icon(Iconsax.eye_slash)),

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
                      Checkbox(value: true, onChanged: (value){}),
                      const Text(BessTexts.rememberMe),
                    ],
                  ),

                  /// Forgot password
                  TextButton(onPressed: () => Get.toNamed(BessRoutes.forgotPassword), child: const Text(BessTexts.forgotPassword))
                ],
              ),
              const SizedBox(height: BessSizes.spaceBtwSections),

              /// Sign in button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(onPressed: (){}, child: const Text(BessTexts.signIn)),
              ),

              const SizedBox(height: BessSizes.spaceBtwInputFields / 2),

              Text(BessTexts.or, style: Theme.of(context).textTheme.bodyMedium),

              const SizedBox(height: BessSizes.spaceBtwInputFields / 2),

              /// Join button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(onPressed: (){}, child: const Text(BessTexts.joinCamp)),
              )
            ],
          )
      ),
    );
  }
}