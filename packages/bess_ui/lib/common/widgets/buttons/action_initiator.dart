import 'package:bessie/common/constants/colors.dart';
import 'package:bessie/common/widgets/shimmers/shimmer.dart';
import 'package:flutter/material.dart';

import '../../constants/sizes.dart';
import '../../styles/text_styles.dart';
import '../../theme/widget_themes/elevated_button_theme.dart';

class ActionInitiator extends StatelessWidget {
  const ActionInitiator({super.key, required this.onPressed, this.enabled = true, this.enabledText = '', this.disabledText = ''});

  final void Function()? onPressed;
  final bool? enabled;
  final String enabledText;
  final String disabledText;

  @override
  Widget build(BuildContext context) {
    if (enabled != null && enabled == true) {
      return ElevatedButton(
        onPressed: onPressed,
        child: Text(enabledText, style: BessTextStyles.standardInverted),
      );
    } else {
      return Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Positioned.fill(
            child: BessShimmerWrapper(
              period: Duration(milliseconds: 800),
              child: ElevatedButton(
                onPressed: null,
                child: Text(disabledText, style: BessTextStyles.standardInverted),
              ),
            ),
          ),

          SizedBox(
            height: 37,
            child: Center(
              child: Text(
                disabledText,
                style: BessTextStyles.standardInverted.copyWith(
                  color: BessColors.textInverted.withAlpha(150),
                ),
              ),
            ),
          ),
        ],
      );
    }



  }
}
