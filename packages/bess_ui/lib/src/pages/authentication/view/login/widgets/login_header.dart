import 'package:flutter/material.dart';

import '../../../../../common/constants//image_strings.dart';
import '../../../../../common/constants//sizes.dart';
import '../../../../../common/constants//text_strings.dart';

class BessLoginHeader extends StatelessWidget {
  const BessLoginHeader({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          Image(
            width: 100,
            height: 100,
            filterQuality: FilterQuality.medium,
            isAntiAlias: true,
            fit: BoxFit.contain,
            image: AssetImage(BessImages.lightAppLogo),
          ),
          const SizedBox(height: BessSizes.xs),
          Text(BessTexts.loginTitle, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: BessSizes.sm),
          Text(BessTexts.loginSubTitle, style: Theme.of(context).textTheme.bodyMedium)
        ],
      ),
    );
  }
}
