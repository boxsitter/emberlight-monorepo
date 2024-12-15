import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../routes/routes.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/constants/text_strings.dart';

class BessHeaderAndForm extends StatelessWidget {
  const BessHeaderAndForm({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Header
        IconButton(onPressed: () => Get.back(), icon: const Icon(Iconsax.arrow_left)),
        const SizedBox(height: BessSizes.spaceBtwItems),
        Text(BessTexts.forgotPasswordTitle, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: BessSizes.spaceBtwItems),
        Text(BessTexts.forgotPasswordSubTitle, style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: BessSizes.spaceBtwItems * 2),

        /// Form
        Form(
          child: TextFormField(
            decoration: const InputDecoration(labelText: BessTexts.email, prefixIcon: Icon(Iconsax.sms)),
          ),
        ),
        const SizedBox(height: BessSizes.spaceBtwItems * 2),

        /// Submit Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(onPressed: () => Get.toNamed(BessRoutes.resetPassword, arguments: 'some@email.com'), child: const Text(BessTexts.submit)),
        ),
        const SizedBox(height: BessSizes.spaceBtwItems * 2),
      ],
    );
  }
}