import 'package:bess_ui/src/common/constants/colors.dart';
import 'package:bess_ui/src/common/widgets/shimmers/shimmer.dart';
import 'package:flutter/material.dart';

import '../../styles/text_styles.dart';

class ActionInitiator extends StatelessWidget {
  const ActionInitiator({super.key, required this.onPressed, this.enabled = true, this.enabledText = '', this.disabledText = '', this.width});

  final void Function()? onPressed;
  final bool? enabled;
  final String enabledText;
  final String disabledText;
  final double? width;

  @override
  Widget build(BuildContext context) {
    if (enabled != null && enabled == true) {
      return SizedBox(
        height: 37,
        width: width ?? double.infinity,
        child: ElevatedButton(
          onPressed: onPressed,
          child: Text(enabledText, style: BessTextStyles.standardInverted),
        ),
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
            width: width ?? double.infinity,
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
