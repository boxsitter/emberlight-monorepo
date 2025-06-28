import 'package:bess_ui/src/common/styles/text_styles.dart';
import 'package:bess_ui/src/common/widgets/buttons/card_button.dart';
import 'package:flutter/material.dart';

import '../../common/constants/colors.dart';
import '../../common/constants/sizes.dart';
import '../../common/widgets/header/menu_bar.dart';
import '../../common/widgets/layouts/templates/site_layout.dart';

class DevTesting extends StatelessWidget {
  const DevTesting({super.key = const ValueKey('DevTesting')});

  @override
  Widget build(BuildContext context) {
    return const BessSiteTemplate(
      desktop: DevTestingDesktop(),
      menuBar: BessMenuBar(),
    );
  }
}

class DevTestingDesktop extends StatelessWidget {
  const DevTestingDesktop({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CardButton(
          child: Center(child: Text('BIG BUTTON')),
          width: 600,
          height: 400,
          baseTint: BessColors.green,
          onTap: () => {},
        ),

        SizedBox(width: BessSizes.spaceBtwItems,),

        CardButton(
          child: Center(child: Text('Small Button')),
          width: 150,
          height: 60,
          baseTint: BessColors.green,
          onTap: () => {},
        ),

        SizedBox(width: BessSizes.spaceBtwItems,),

        CardButton(
          child: Center(child: Text('Wide Button')),
          width: 300,
          height: 70,
          baseTint: BessColors.green,
          onTap: () => {},
        ),

        SizedBox(width: BessSizes.spaceBtwItems,),

        CardButton(
          child: Center(child: Text('Tiny Button', style: BessTextStyles.standard.copyWith(fontSize: 8),)),
          width: 150,
          height: 30,
          baseTint: BessColors.green,
          onTap: () => {},
          padding: EdgeInsets.all(0),
        ),
      ],
    );
  }
}
